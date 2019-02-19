# encoding: utf-8
require 'digest/md5'
require 'securerandom'

#
# sypctl 代理使用
#
module API
  class V1Controller < API::ApplicationController

    before do
      # halt_with_format_json({message: '接口验证失败：请提供 api_token'}, 401) unless params[:api_token]
      # halt_with_format_json({message: '接口验证失败：api_token 错误'}, 401) unless authen_api_token(params[:api_token])
      if request.request_method.downcase == 'get'
        params[:page], params[:page_size] = (params[:page] || 0).to_i, (params[:page_size] || 15).to_i
      end
    end

    #
    # 注册接口有两种方式：
    # 1. 在代理服务器端主动注册(直接创建)，执行命令 sypctl bundle exec agent:submitor
    #    参数格式为: { device: { field: field_value }}
    # 2. 管理平台创建主机，然后在代理服务器声明随机分配的 uuid, 代理提交时作为查询主键
    #    参数格式为: { uuid: 服务器随机 UUID, device: { field: field_value }}
    #
    # 主机的 uuid 命令规范：
    # `/sbin/blkid -s UUID` 列表，sda*/xvda* 优先，匹配出第一个设备 UUID 作为该主机 UUID
    # 比如：
    #
    # $ /sbin/blkid -s UUID
    # /dev/sda1: UUID="db30250c-d0aa-4883-9667-223f85d7c6be"
    # /dev/sda2: UUID="gBMj47-0jzt-BDHc-GZ9Q-8glh-x0LJ-jVJIaw"
    # /dev/sdb1: UUID="SwoEDH-AqKe-Bg4u-BOgV-q7Mo-eWlC-4GbSgf"
    #
    # 避免主机 UUID 作为参数与 URL 规范冲突，`/` 替换为 `_`，示例主机的 UUID 为:
    # _dev_sda1-db30250c-d0aa-4883-9667-223f85d7c6be
    #
    # post /api/v1/register
    post '/register' do
      api_authen_params([:device])

      params[:device][:api_token] = Digest::MD5.hexdigest(generate_uuid)
      params[:device][:request_ip] = request.ip
      params[:device][:request_agent] = request.user_agent
      
      if params[:uuid]
        device = Device.find_by(uuid: params[:uuid])
        device = Device.find_by(uuid: params[:device][:uuid]) unless device
      else
        device = Device.find_by(uuid: params[:device][:uuid])
      end

      if device
        device.update_attributes(params[:device])
      else
        device = Device.create(params[:device])
      end
   
      respond_with_json(device.to_hash, 201)
    end

    # post /api/v1/receiver
    post '/receiver' do
      api_authen_params([:device])

      params[:device][:request_ip] = request.ip
      params[:device][:request_agent] = request.user_agent

      jobs, file_backups = [], []
      record = Record.create(params[:device])
      if device = Device.find_by(uuid: params[:device][:uuid])
        device.update_attributes({record_count: device.record_count + 1})
        jobs = Job.where(device_uuid: device.uuid, state: 'waiting').map(&:to_hash)
      end

      puts "FileBackup.db_hash: #{FileBackup.db_hash}"
      puts "params[:file_backup_db_hash]: #{params[:file_backup_db_hash]}"
      puts params[:file_backup_db_hash] == FileBackup.db_hash
      if params[:file_backup_db_hash].present? && params[:file_backup_db_hash] != FileBackup.db_hash
        file_backups = FileBackup.db_json
      end

      respond_with_json({id: record.id, jobs: jobs, file_backups: file_backups}, 201)
    end

    # post /api/v1/job
    post '/job' do
      api_authen_params([:job])

      if job = Job.find_by(uuid: params[:job][:uuid])
        job.update_attributes(params[:job])
        job.update_job_group_state if %w(dealing done).include?(params[:job][:state])
      end

      respond_with_json({data: job.to_hash, message: '更新任务成功'}, 201)
    end

    post '/operation/logger' do
      message = '接收成功'
      begin
        params[:operation_log][:ip] = request.ip
        params[:operation_log][:browser] = request.user_agent
        OperationLog.create(params[:operation_log])
      rescue => e
        message = "接收异常，#{e.message}"
      end

      respond_with_formt_json({message: message}, 201)
    end

    get '/job_templates' do
      records = JobTemplate.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(JobTemplate, records, params)
    end

    # 二级排序：先按设备组序号升序、再按设备序号升序
    #
    # select 
    #   sdg.name, sdg.order_index, sd.human_name, sd.order_index 
    # from sys_devices as sd
    # left join sys_device_groups as sdg on sdg.id = sd.device_group_id
    # order by 
    #   if(isnull(sdg.order_index), 1000, sdg.order_index) asc, 
    #   if(isnull(sd.order_index), 1000, sd.order_index)

    get '/devices' do
      records = Device.order("if(isnull(order_index), 1000, order_index) asc").offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(Device, records, params)
    end

    get '/apps' do
      records = App.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(Device, records, params)
    end

    get '/app' do
      api_authen_params([:uuid])

      app = App.find_by(uuid: params[:uuid])

      respond_with_formt_json({data: app.to_hash, message: '查询成功'}, 200)
    end

    get '/app/latest_version' do
      api_authen_params([:uuid])
      
      version = Version.find_by(uuid: params[:uuid])
      halt_with_format_json({data: {}, message: '查询失败'}, 200) unless version

      respond_with_formt_json({data: version.to_hash, message: '查询成功'}, 200)
    end

    get '/app/versions' do
      api_authen_params([:uuid])

      app = App.find_by(uuid: params[:uuid])
      records = app.versions.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(app.versions, records, params)
    end

    get '/app/version' do
      api_authen_params([:uuid])

      version = Version.find_by(uuid: params[:uuid])
      data = version.to_hash
      data[:download_path] = "/download-version/#{version.app_uuid}/#{version.file_name}"

      respond_with_formt_json({data: data, message: '查询成功'}, 200)
    end

    get '/download/version' do
      api_authen_params([:app_uuid, :version_file_name])

      version_file_path = File.join(Setting.path.version, params[:app_uuid], params[:version_file_name])
      halt_with_format_json({data: {}, message: '版本文件不存在', code: 403}, 403) unless File.exists?(version_file_path)

      send_file(version_file_path, type: 'application/java-archive', filename: File.basename(version_file_path), disposition: 'attachment')
    end

    post '/upload/file_backup' do
      api_authen_params([:device_uuid, :file_uuid, :archive_file_name, :backup_file])

      message = upload_file_backup(params)
      respond_with_formt_json({message: message, code: 201}, 201)
    end

    post '/upload/file_backup' do
      api_authen_params([:device_uuid, :file_uuid, :archive_file_name, :backup_file])

      message = upload_file_backup(params)
      respond_with_formt_json({message: message, code: 201}, 201)
    end
    
    post '/update/file_backup' do
      api_authen_params([:device_uuid, :file_backup_config, :file_backup_monitor])

      record = Device.find_by(uuid: params[:device_uuid])
      halt_with_format_json({message: "查询设备失败,#{params[:device_uuid]}"}, 200) unless record

      record.update_attributes({
        file_backup_config: params[:file_backup_config],
        file_backup_monitor: params[:file_backup_monitor],
        file_backup_updated_at: Time.now.strftime('%Y/%m/%d %H:%M:%S')
      })
      respond_with_formt_json({message: '更新成功', code: 201}, 201)
    end

    get '/ifconfig.me' do
      request.ip
    end

    get '/linux.date' do
      `date +'%s'`.strip
    end

    post '/service' do
      api_authen_params([:uuid])

      if service = Service.find_by(uuid: params[:uuid])
        service.update_attributes(params[:service])
      else
        service = Service.create(params[:service])
      end

      device = Device.find_by(uuid: params[:uuid])
      device.update_attributes({
        service_state: true,
        service_config: params[:service][:config],
        service_monitor: params[:service][:monitor],
        service_count: params[:service][:total_count],
        service_stopped_count: params[:service][:stopped_count],
        service_updated_at: Time.now.strftime('%Y/%m/%d %H:%M:%S')
      }) if device

      respond_with_formt_json({message: '接收成功'}, 201)
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end

    def upload_file_backup(params)
      device_path = File.join(Setting.path.file_backup, params[:device_uuid], params[:file_uuid])
      FileUtils.mkdir_p(device_path) unless File.exists?(device_path)
      backup_path = File.join(device_path, params[:archive_file_name])

      temp_file = params[:backup_file][:tempfile]
      File.open(backup_path, "wb") { |file| file.write(temp_file.read) }
      "上传成功"
    rescue => e
      puts e.backtrace.select { |line| line.include?(ENV['APP_ROOT_PATH']) }
      "上传失败, #{__FILE__}@#{__LINE__} - #{e.message}"
    end
  end
end