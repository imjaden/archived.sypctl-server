# encoding: utf-8
require 'digest/md5'
require 'securerandom'

module API
  class V1Controller < API::ApplicationController

    before do
      # halt_with_format_json({message: '接口验证失败：请提供 api_token'}, 401) unless params[:api_token]
      # halt_with_format_json({message: '接口验证失败：api_token 错误'}, 401) unless authen_api_token(params[:api_token])
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

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end
  end
end