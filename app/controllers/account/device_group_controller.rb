# encoding: utf-8
module Account
  class DeviceGroupController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/device_groups')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '分组管理'
    end

    get '/' do
      @records = DeviceGroup.order(order_index: :asc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = DeviceGroup.new

      haml :new, layout: settings.layout
    end

    post '/' do
      record = DeviceGroup.new(params[:device_group])
      record.uuid ||= generate_uuid

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
      @record.uuid = generate_uuid unless @record.uuid

      haml :edit, layout: settings.layout
    end

    post '/order' do
      (params[:ids] || []).each_with_index do |id, index|
        if device = DeviceGroup.find_by(id: id)
          device.update_attributes({order_index: index+1})
        end
      end

      flash[:success] = "更新排序成功"
      respond_with_json({data: "successfully"}, 201)
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

    get '/:id/devices' do
      @record = DeviceGroup.find_by(id: params[:id])
      @records = @record.devices.order(order_index: :asc)

      haml :devices, layout: settings.layout
    end

    get '/:id/devices/add' do
      @record = DeviceGroup.find_by(id: params[:id])
      @records = Device.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :devices_add, layout: settings.layout
    end

    post '/devices/state' do
      record = Device.find_by(id: params[:id])
      record.update_attributes({device_group_id: (params[:state].to_s == 'true' ? params[:device_group_id] : nil)})

      respond_with_json({data: "successfully"}, 201)
    end

    post '/devices/order' do
      (params[:ids] || []).each_with_index do |id, index|
        if device = Device.find_by(id: id)
          device.update_attributes({order_index: index+1})
        end
      end

      flash[:success] = "更新排序成功"
      respond_with_json({data: "successfully"}, 201)
    end
  end
end