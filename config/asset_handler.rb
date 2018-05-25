# encoding: utf-8
require 'fileutils'
require 'digest/md5'
require 'lib/utils/boot.rb'

include Utils::Boot
class AssetHandler < Sinatra::Base
  configure do
    enable :logging, :static, :sessions
    enable :method_override
    enable :coffeescript

    # Logger.class_eval { alias :write :'<<' }
    # logger_file = File.join(ENV['APP_ROOT_PATH'], 'log/#{ENV['RACK_ENV']}.log')
    # logger = ::Logger.new(::File.new(logger_file, 'a+'))
    # use Rack::CommonLogger, logger

    set :root,  ENV['APP_ROOT_PATH']
    set :views, ENV['VIEW_PATH']
    set :public_folder, ENV['APP_ROOT_PATH'] + '/app/assets'
    set :js_dir,  ENV['APP_ROOT_PATH'] +  '/app/assets/javascripts'
    set :css_dir, ENV['APP_ROOT_PATH'] + '/app/assets/stylesheets'

    # set :erb, :layout_engine => :erb, :layout => :layout
    set :haml, layout_engine: :haml, layout: :'/app/views/layouts/layout'
    set :cssengine, 'css'
  end

  require 'database.rb'
end

# bug: mysql 中断时有访问，mysql 再连接依然报错@2016-01-04
class ExceptionHandling
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call env
  rescue => ex
    env['rack.errors'].puts ex
    env['rack.errors'].puts ex.backtrace
    env['rack.errors'].flush

    hash = { message: ex.to_s }

    # deal with Mysql2::Error
    if ex.to_s.include?('Mysql2::Error')
      defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
      hash[:special_info] = 'has reconnect mysql for active record base'
    end

    if ENV['RACK_ENV'].eql?('development')
      hash[:backtrace] = ex.backtrace
    end

    [500, { 'Content-Type' => 'application/json' }, [hash.to_json]]
  end
end
