# encoding: utf-8
module Account
  class DeviceController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/devices')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '主机管理'
    end

    get '/' do
      @records = Device.paginate(page: params[:page], per_page: 15).order(updated_at: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = Device.new
      @record.ssh_port = 22

      haml :new, layout: settings.layout
    end

    post '/' do
      record = Device.new(params[:device])

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to('/')
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to('/new')
      end
    end

    get '/:id' do
      unless @record = Device.find_by(id: params[:id])
        @record = Device.new
        @record.name = '版本不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = Device.find_by(id: params[:id])

      haml :edit, layout: settings.layout
    end

    post '/:id' do
      record = Device.find_by(id: params[:id])
        
      if record.update_attributes(params[:device])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    get '/:id/records' do
      @device = Device.find_by(id: params[:id])
      @records = @device.records.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :records, layout: settings.layout
    end
  end
end