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

    # post /api/v1/register
    post '/register' do
      api_authen_params([:device])

      if device = Device.find_by(uuid: params[:device][:uuid])
        device.update_attributes(params[:device])
      else
        device = Device.create(params[:device])
      end
      device.update_attribute(:api_token, Digest::MD5.hexdigest(SecureRandom.uuid))
   
      respond_with_json({api_token: device.api_token}, 201)
    end

    # post /api/v1/receiver
    post '/receiver' do
      api_authen_params([:device])

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

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end
  end
end