# encoding: utf-8
module Account
  class ApplicationController < ::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/home')
    set :layout, :'../../layouts/layout'

    helpers Account::ApplicationHelper

    before do
      authenticate!
      @page_title = '应用列表'
    end

    get '/' do
      @records = App.paginate(page: params[:page]).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/refresh' do
      settings.startup_time = Time.now
      redirect to('/')
    end

    post '/delete_cache' do
      scan_key = %(*/mobile/*/#{params[:cache_type]}@*)
      cache_keys = redis.keys(scan_key)
      redis.del(cache_keys) unless cache_keys.empty?
      redis_cache_num = redis.keys(scan_key).count

      settings.startup_time = Time.now
      respond_with_json({ redis_cache_num: redis_cache_num }, 200)
    end

    get '/operation_logs' do
      @records = OperationLog.paginate(page: params[:page], per_page: 20).order(id: :desc)

      haml :operation_logs, layout: settings.layout
    end

    get '/agent_behavior_logs' do
      @records = AgentBehaviorLog.paginate(page: params[:page], per_page: 20).order(id: :desc)

      haml :agent_behavior_logs, layout: settings.layout
    end
  end
end
