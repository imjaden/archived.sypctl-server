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
      @record.uuid = "random-#{generate_uuid}"

      haml :new, layout: settings.layout
    end

    post '/' do
      record = Device.new(params[:device])
      record.uuid ||= generate_uuid

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to("/#{record.id}")
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

    get '/uuid/:uuid' do
      unless @record = Device.find_by(uuid: params[:uuid])
        @record = Device.new
        @record.name = '版本不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = Device.find_by(id: params[:id])
      @record.uuid = "random-#{generate_uuid}" unless @record.uuid

      haml :edit, layout: settings.layout
    end

    post '/monitor-state' do
      record = Device.find_by(id: params[:id])
      record.update_columns({monitor_state: !record.monitor_state})
      
      respond_with_json({data: record.monitor_state}, 201)
    end

    post '/:id' do
      record = Device.find_by(id: params[:id])
        
      if record.update_attributes(params[:device])
        flash[:success] = '更新成功'
        redirect to("/#{record.id}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/#{record.id}/edit")
      end
    end

    delete '/:id' do
      if record = Device.find_by(id: params[:id])
        record.destroy
      end
      
      respond_with_json({message: "删除成功"}, 201)
    end

    get '/:id/records' do
      @device = Device.find_by(id: params[:id])
      @records = @device.records.paginate(page: params[:page], per_page: 20).order(id: :desc)

      haml :'records/index', layout: settings.layout
    end

    get '/:id/create_job' do
      device = Device.find_by(id: params[:id])
      Job.create(
        uuid: generate_uuid,
        title: "重新提交代理主机信息",
        device_uuid: device.uuid,
        device_name: device.human_name || device.hostname,
        command: "rm -f /opt/scripts/sypctl/agent/db/agent.json\necho '删除代理端服务器配置档'\nsypctl bundle exec rake agent:submitor\necho '重新提交代理设备信息完成'",
        state: "waiting"
      )

      flash[:success] = "15 分钟后刷新页面查看状态"
      redirect to("/")
    end

    get '/device_group/:device_group_id' do
      @device_group = DeviceGroup.find_by(id: params[:device_group_id])
      @records = @device_group.devices.order(order_index: :asc)
      
      haml :'device_group/index', layout: settings.layout
    end
  end
end