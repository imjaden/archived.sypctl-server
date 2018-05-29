# encoding: utf-8
module Account
  class DeviceGroupController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/device_groups')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '分组管理'
    end

    get '/' do
      @records = DeviceGroup.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = DeviceGroup.new

      haml :new, layout: settings.layout
    end

    post '/' do
      record = DeviceGroup.new(params[:device_group])

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to('/')
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to('/new')
      end
    end

    get '/:id' do
      unless @record = DeviceGroup.find_by(id: params[:id])
        @record = DeviceGroup.new
        @record.name = '分组不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = DeviceGroup.find_by(id: params[:id])

      haml :edit, layout: settings.layout
    end

    post '/:id' do
      record = DeviceGroup.find_by(id: params[:id])
        
      if record.update_attributes(params[:device_group])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    delete '/:id' do
      if record = DeviceGroup.find_by(id: params[:id])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.name}」删除成功"}, 201)
    end
  end
end