# encoding: utf-8
require 'geetest'
require 'digest/md5'
require 'sinatra/base'
require "sinatra/cookies"
require 'sinatra/url_for'
require 'sinatra/multi_route'
require 'will_paginate'
require 'will_paginate/active_record'
require 'lib/sinatra/markup_plugin'

class ApplicationController < Sinatra::Base
  set :root, ENV['APP_ROOT_PATH']
  set :views, File.join(ENV['APP_ROOT_PATH'], 'app/views/home')
  set :rack_env, ENV['RACK_ENV']
  set :logger_level, :info # :fatal or :error, :warn, :info, :debug
  set :layout, :'../layouts/layout'
  enable :sessions, :logging, :static, :method_override
  enable :dump_errors, :raise_errors, :show_exceptions unless ENV['RACK_ENV'].eql?('production')
  set :protection, :allow_if => lambda { |env|
    if (env.has_key?('HTTP_REFERER') && env['HTTP_REFERER'] == "https://servicewechat.com/#{ENV['wxmp_app_id']}/devtools/page-frame.html") ||
       (env['HTTP_ORIGIN'] || env['HTTP_X_ORIGIN']).nil?
      true
    else
      false
    end
  }

  register Sinatra::Reloader unless ENV['RACK_ENV'].eql?('production')
  register Sinatra::MultiRoute
  register Sinatra::Logger
  register Sinatra::Flash
  register Sinatra::MarkupPlugin
  register Sinatra::ActiveRecordExtension
  register WillPaginate::Sinatra
  WillPaginate.per_page = 15

  helpers Sinatra::Cookies
  helpers Sinatra::UrlForHelper
  helpers ApplicationHelper
  helpers AssetSprocketsHelpers

  use AssetsHandler
  use ExceptionHandler

  # rake-mini-profiler
  use Rack::MiniProfiler
  Rack::MiniProfiler.config.position = 'top-right'
  Rack::MiniProfiler.config.start_hidden = false
  Rack::MiniProfiler.config.disable_caching = false
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::FileStore
  Rack::MiniProfiler.config.storage_options = {path: File.join(ENV['APP_ROOT_PATH'], 'tmp/mini-profiler')}

  # sprockets
  set :sprockets, Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) }
  set :precompile, [ /\w+\.(?!js|css).+/, /dist.(css|js)$/ ]
  set :assets_prefix, 'assets'
  set :assets_path, File.join(root, 'public', assets_prefix)
  configure do
    set :digest_assets,   true
    set :manifest_assets, true

    sprockets.cache = Sprockets::Cache::FileStore.new('./tmp')
    sprockets.register_compressor 'application/javascript', :uglify, Sprockets::UglifierCompressor.new(harmony: true)
    sprockets.js_compressor = :uglify
    sprockets.css_compressor = YUI::CssCompressor.new

    sprockets.append_path(File.join(root, 'app/assets/stylesheets'))
    sprockets.append_path(File.join(root, 'app/assets/javascripts'))

    sprockets.context_class.instance_eval do
      include AssetSprocketsHelpers
    end
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'origin, x-csrftoken, content-type, accept'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers["P3P"] = "CP='IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT'"

    request_hash = request_params
    @params = request_hash.is_a?(Hash) ? params.merge(request_hash) : params
    @params[:ip] ||= request.ip
    @params[:browser] ||= request.user_agent
    @params.deep_symbolize_keys!

    print_format_logger
    
    Rack::MiniProfiler.authorize_request if @current_user
  end
  
  not_found do
    if request.path_info.start_with?('/images/')
      send_file(app_root_join('/app/assets/images/404-small.png'), type: 'image/png', filename: '404.png', disposition: 'inline')
    else
      flash[:warning] = "路由不存在，#{request.request_method} #{request.url}"
      redirect to('/')
    end
  end

  get '/', '/login' do
    # redirect to('/account/jobs') if cookies[cookie_name].present?
    @user = User.new(user_num: cookies[cookie_name] || '')

    haml :index, layout: settings.layout
  end

  get "/assets/*" do
    env['PATH_INFO'].sub!(%r{^/assets}, '')
    settings.sprockets.call(env)
  end

  post '/login' do
    user, message = User.authen_with_api(params[:user])

    if user
      flash[:success] = message
      set_login_cookie(params[:user][:user_num])

      redirect to("/account/jobs?#{append_params_when_login(user)}")
    else
      flash[:waning] = message
      redirect to('/login')
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

  get '/dashboard/:uuid' do
    @device_group = DeviceGroup.find_by(uuid: params[:uuid])
    @records = @device_group.devices.order(order_index: :asc)
    
    haml :dashboard, layout: settings.layout
  end

  get '/monitor' do
    timestamp = Device.maximum(:updated_at)
    cache_with_custom_defined([timestamp])

    @records = Device.where(monitor_state: true).order(order_index: :asc)

    template = mobile? ? :'monitor@mobile' : :'monitor@pc'
    haml template, layout: settings.layout
  end

  # GET /logout
  get '/logout' do
    url = "/login?#{append_params_when_logout}"
    set_login_cookie(nil)

    flash[:success] = '登出成功'
    redirect to(url)
  end

  def authenticate!
    return if cookies[cookie_name].present? && current_user

    cookies['path_before_login']= request.url
    flash[:danger] = '继续操作前请登录.'
    redirect '/login', 302
  end

  def current_user
    @current_user ||= begin
      user = User.find_by(user_num: cookies[cookie_name])
      set_login_cookie(nil) if !user
      user
    end
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

  def generate_uuid
    SecureRandom.uuid.gsub('-', '')
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

  def cache_with_custom_defined(timestamps = [], etag_content = nil)
    return if ENV['RACK_ENV'] == 'development'

    timestamp = timestamps.compact.max
    timestamp ||= (ENV['STARTUP'] || Time.now)

    last_modified timestamp
    etag md5(etag_content || timestamp)
  end

  protected

  def respond_with_json(response_hash = {}, code = 200)
    response_hash[:code] ||= code
    logger.info response_hash.to_json

    content_type 'application/json', charset: 'utf-8'
    body response_hash.to_json
    status code
  end

  def respond_with_formt_json(data_hash = {}, code = 200)
    data_hash[:code] = 200 unless data_hash.has_key?(:code)
    data_hash[:data] = {} unless data_hash.has_key?(:data)
    data_hash[:message] = 'default successfully' unless data_hash.has_key?(:message)
    respond_with_json(data_hash, code)
  end

  def halt_with_json(response_hash = {}, code = 200)
    response_hash[:code] ||= code
    logger.info response_hash.to_json

    content_type 'application/json', charset: 'utf-8'
    halt(code, {'Content-Type' => 'application/json;charset=utf-8'}, response_hash.to_json)
  end

  def halt_with_format_json(data_hash = {}, code = 200)
    data_hash[:code] = 401 unless data_hash.has_key?(:code)
    data_hash[:message] = 'default halt message' unless data_hash.has_key?(:message)

    if data_hash[:code] == 200
      data_hash[:data] = {} unless data_hash.has_key?(:data)
    else
      data_hash.delete(:data) if data_hash.has_key?(:data)
    end
    halt_with_json(data_hash, code)
  end
  
  def respond_with_paginate(klass, data_list, params)
    total_count = klass.count

    respond_with_json({
      code: 200,
      message: "获取数据列表成功",
      curr_page: params[:page],
      current_page: params[:page],
      page_size: params[:page_size],
      total_page: (1.0*total_count/params[:page_size]).ceil,
      total_count: total_count,
      data: data_list
    })
  end

  def api_authen_params(keys)
    halt_with_json({message: "参数不足：请提供 #{keys.join(' ,')}"}, 401) if keys.any? { |key| !params.has_key?(key) }
  end

  private

  def set_login_cookie(_cookie_value = '')
    if _cookie_value
      cookies[cookie_name] = _cookie_value
    else
      cookies.delete(cookie_name)
    end
  end

  def append_params_when_login(user)
    bsession = ((0..100).to_a + ('a'..'z').to_a).sample(128).join
    "bsession=#{bsession}&user_num=#{user.user_num}&user_name=#{URI.encode(user.user_name)}&login_authen_to_redirect=true"
  end

  def append_params_when_logout
    bsession = ((0..100).to_a + ('a'..'z').to_a).sample(128).join
    "bsession=#{bsession}&user_num=#{current_user.user_num}&user_name=#{URI.encode(current_user.user_name)}&logout_authen_to_redirect=true"
  end

  def cookie_name
    @cookie_name ||= begin
      version_major = ENV['APP_VERSION'].split('.').first(2).join('.')
      "authen-#{Setting.app_name}-#{ENV['RACK_ENV']}-#{version_major}"
    end
  end
end