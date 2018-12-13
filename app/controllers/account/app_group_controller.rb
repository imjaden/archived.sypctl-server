# encoding: utf-8
module Account
  class AppGroupController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/app_groups')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '分组管理'
    end

    get '/' do
      @records = AppGroup.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = AppGroup.new

      haml :new, layout: settings.layout
    end

    post '/' do
      record = AppGroup.new(params[:app_group])
      record.uuid ||= generate_uuid

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to('/')
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to('/new')
      end
    end

    get '/:uuid' do
      unless @record = AppGroup.find_by(uuid: params[:uuid])
        @record = AppGroup.new
        @record.name = '分组不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:uuid/edit' do
      @record = AppGroup.find_by(uuid: params[:uuid])

      haml :edit, layout: settings.layout
    end

    post '/:uuid' do
      record = AppGroup.find_by(uuid: params[:uuid])
        
      if record.update_attributes(params[:app_group])
        flash[:success] = '更新成功'
        redirect to("/?uuid=#{params[:uuid]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?uuid=#{params[:uuid]}")
      end
    end

    delete '/:uuid' do
      if record = AppGroup.find_by(uuid: params[:uuid])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.name}」删除成功"}, 201)
    end

    get '/:uuid/apps' do
      @record = AppGroup.find_by(uuid: params[:uuid])
      @records = @record.apps.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :apps, layout: settings.layout
    end

    get '/:uuid/apps/add' do
      @record = AppGroup.find_by(uuid: params[:uuid])
      @records = App.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :apps_add, layout: settings.layout
    end

    post '/apps/state' do
      record = App.find_by(uuid: params[:uuid])
      record.update_attributes({app_group_uuid: (params[:state].to_s == 'true' ? params[:app_group_uuid] : nil)})

      respond_with_json({data: "successfully"}, 201)
    end
  end
end