# encoding: utf-8
require 'geetest'
require 'digest/md5'
require 'sinatra/multi_route'
require 'sinatra/url_for'
require 'will_paginate'
require 'will_paginate/active_record'
require 'lib/sinatra/markup_plugin'

class ApplicationController < Sinatra::Base
  register Sinatra::Reloader unless ENV['RACK_ENV'].eql?('production')
  register Sinatra::MultiRoute
  register Sinatra::Logger
  register Sinatra::Flash
  register Sinatra::MarkupPlugin
  register Sinatra::ActiveRecordExtension
  register WillPaginate::Sinatra

  helpers ApplicationHelper
  helpers Sinatra::UrlForHelper

  use AssetHandler
  use ExceptionHandling

  WillPaginate.per_page = 15
  
  set :root, ENV['APP_ROOT_PATH']
  set :views, File.join(ENV['APP_ROOT_PATH'], 'app/views/home')
  set :rack_env, ENV['RACK_ENV']
  set :startup_time, Time.now
  set :logger_level, :info # :fatal or :error, :warn, :info, :debug
  set :layout, :'../layouts/layout'
  enable :sessions, :logging, :static, :method_override
  enable :dump_errors, :raise_errors, :show_exceptions unless ENV['RACK_ENV'].eql?('production')

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'origin, x-csrftoken, content-type, accept'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST'
    response.headers["P3P"] = "CP='IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT'"

    request_hash = request_params
    @params = request_hash.is_a?(Hash) ? params.merge(request_hash) : params
    @params[:ip] ||= request.ip
    @params[:browser] ||= request.user_agent
    @params.deep_symbolize_keys!

    print_format_logger
  end

  get '/', '/login' do
    @user = User.new

    haml :index, layout: settings.layout
  end

  post '/login' do
    status, response = User.authen_with_api(params[:user])

    if status
      flash[:success] = '登录成功'
      set_login_cookie('authen', params[:user][:user_num])

      redirect to("/account")
    else
      flash[:danger] = response
      redirect to('/')
    end
  end

  # geetest3 captcha
  # GET /geetest3/register
  get '/geetest3/register' do
    gt = Geetest::SDK3.new(Setting.geetest.captcha_id, Setting.geetest.private_key)
    session[gt.session_key] = gt.pre_process
    session['token'] = params[:avoid_cache_token]
    gt.response_str
  end

  # POST /geetest3/validate
  post '/geetest3/validate' do
    gt = Geetest::SDK3.new(Setting.geetest.captcha_id, Setting.geetest.private_key)
    challenge = params[gt.fn_challenge.to_sym]
    validate = params[gt.fn_validate.to_sym]
    seccode = params[gt.fn_seccode.to_sym]

    if session[gt.session_key]
      result = gt.success_validate(challenge, validate, seccode, session['token'])
      hash = { status: result, challenge: gt.response_str }
    else
      result = gt.failback_validate(challenge, validate, seccode)
      hash = { status: result }
    end

    respond_with_json(hash)
  end

  def current_user
    @current_user ||= User.find_by(user_num: request.cookies['authen'] || '')
  end

  def request_params(raw_body = request.body)
    body = case raw_body
    when StringIO
     raw_body.string
    when Tempfile,
     # gem#unicorn
     #     change the strtucture of REQUEST
     (defined?(Unicorn) && Unicorn::TeeInput),
     # gem#passenger is ugly!
     #     change the structure of REQUEST
     #     detail at: https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/utils/tee_input.rb
     (defined?(PhusionPassenger) && PhusionPassenger::Utils::TeeInput),
     (defined?(Rack) && Rack::Lint::InputWrapper)

     raw_body.read # if body.respond_to?(:read)
    else
     raw_body.to_str
    end.to_s.strip

    JSON.parse(body) if !body.empty? && body.start_with?('{') && body.end_with?('}')
  rescue => e
    logger.error %(request_params - #{e.message})
  end

  def print_format_logger
    logger.info <<-EOF.strip_heredoc
      #{request.request_method} #{request.path} for #{request.ip} at #{Time.now}
      Parameters:
        #{@params}
    EOF
  end

  def respond_with_json(response_hash = {}, code = 200)
    response_hash[:code] ||= code
    logger.info response_hash.to_json

    content_type 'application/json', charset: 'utf-8'
    body response_hash.to_json
    status code
  end

  def halt_with_json(response_hash = {}, code = 200)
    response_hash[:code] ||= code
    logger.info response_hash.to_json

    content_type 'application/json', charset: 'utf-8'
    halt(code, {'Content-Type' => 'application/json;charset=utf-8'}, response_hash.to_json)
  end

  def authenticate!
    return if request.cookies['authen']

    response.set_cookie 'path', value: request.url, path: '/', max_age: '600'
    flash[:danger] = '继续操作前请登录.'
    redirect '/login', 302
  end

  def app_root_join(path)
    File.join(settings.root, path)
  end

  def app_tmp_join(path)
    File.join(settings.root, 'tmp', path)
  end

  def md5(something)
    Digest::MD5.hexdigest(something.to_s)
  end

  def digest_file_md5(filepath)
    Digest::MD5.file(filepath).hexdigest
  end

  private

  def set_login_cookie(cookie_name = 'authen', cookie_value = '')
    response.set_cookie cookie_name, value: cookie_value, path: '/', max_age: '28800'
  end
end