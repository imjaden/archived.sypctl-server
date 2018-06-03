# encoding: utf-8
require 'digest/md5'
require 'securerandom'

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

      params[:device][:api_token] = Digest::MD5.hexdigest(SecureRandom.uuid)
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

      jobs = []
      record = Record.create(params[:device])
      if device = Device.find_by(uuid: params[:device][:uuid])
        device.update_attributes({record_count: device.record_count + 1})
        jobs = Job.where(device_uuid: device.uuid, state: 'waiting').map(&:to_hash)
      end

      respond_with_json({id: record.id, jobs: jobs}, 201)
    end

    # post /api/v1/job
    post '/job' do
      api_authen_params([:job])

      if record = Job.find_by(uuid: params[:job][:uuid])
        record.update_attributes(params[:job])
      end

      respond_with_json({id: record.id}, 201)
    end

    post '/operation/logger' do
      params[:operation_log][:ip] = request.ip
      params[:operation_log][:browser] = request.user_agent
      OperationLog.create(params[:operation_log])

      respond_with_formt_json({message: '接收成功'}, 201)
    end

    get '/job_templates' do
      records = JobTemplate.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(JobTemplate, records, params)
    end

    get '/devices' do
      records = Device.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(Device, records, params)
    end

    get '/apps' do
      records = App.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(Device, records, params)
    end

    get '/:app_id/versions' do
      app = App.find_by(id: params[:app_id])
      records = app.versions.order(id: :desc).offset(params[:page]*params[:page_size]).limit(params[:page_size]).map(&:to_hash)

      respond_with_paginate(app.versions, records, params)
    end

    get '/ifconfig.me' do
      request.ip
    end

    get '/linux.date' do
      `date +'%z %m/%d/%y %H:%M:%S'`.strip
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end
  end
end