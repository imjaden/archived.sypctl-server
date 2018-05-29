# encoding: utf-8
require 'lib/sinatra/extension_redis'
module API
  class ApplicationController < ::ApplicationController
    register Sinatra::Redis

    get '/' do
      'hey: why are you here?'
    end

    protected

    def respond_with_json(response_hash = {}, code = 200)
      response_hash[:code] ||= code
      logger.info response_hash.to_json

      content_type 'application/json', charset: 'utf-8'
      body response_hash.to_json
      status code
    end

    def respond_with_formt_json(data_hash = {}, code = 200)
      data_hash[:code] = 200 unless data_hash.has_key?(:code)
      data_hash[:data] = {} unless data_hash.has_key?(:data)
      data_hash[:message] = 'default successfully' unless data_hash.has_key?(:message)
      respond_with_json(data_hash, code)
    end

    def halt_with_json(response_hash = {}, code = 200)
      response_hash[:code] ||= code
      logger.info response_hash.to_json

      content_type 'application/json', charset: 'utf-8'
      halt(code, {'Content-Type' => 'application/json;charset=utf-8'}, response_hash.to_json)
    end

    def halt_with_format_json(data_hash = {}, code = 200)
      data_hash[:code] = 401 unless data_hash.has_key?(:code)
      data_hash[:message] = 'default halt message' unless data_hash.has_key?(:message)

      if data_hash[:code] == 200
        data_hash[:data] = {} unless data_hash.has_key?(:data)
      else
        data_hash.delete(:data) if data_hash.has_key?(:data)
      end
      halt_with_json(data_hash, code)
    end
    
    def respond_with_paginate(klass, data_list, params)
      total_count = klass.count

      respond_with_json({
        code: 200,
        message: "获取数据列表成功",
        curr_page: params[:page],
        current_page: params[:page],
        page_size: params[:page_size],
        total_page: (1.0*total_count/params[:page_size]).ceil,
        total_count: total_count,
        data: data_list
      })
    end

    def api_authen_params(keys)
      halt_with_json({message: "参数不足：请提供 #{keys.join(' ,')}"}, 401) if keys.any? { |key| !params.has_key?(key) }
    end
  end
end
