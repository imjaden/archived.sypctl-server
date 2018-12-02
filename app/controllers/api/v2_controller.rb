# encoding: utf-8
require 'digest/md5'
require 'securerandom'

#
# portal ui 使用
#
module API
  class V2Controller < API::ApplicationController

    before do
      if Setting.website.api_key
        halt_with_format_json({message: '接口验证失败：请提供 api_token'}, 401) unless params[:api_token]
        halt_with_format_json({message: '接口验证失败：api_token 错误'}, 401) unless authen_api_token(params[:api_token])
      end
      params[:page], params[:page_size] = (params[:page] || 1).to_i, (params[:page_size] || 15).to_i if request.request_method.downcase == 'get'
    end

    options '/*' do
      respond_with_formt_json({message: '接收成功'}, 201)
    end

    post '/login' do
      user, message = User.authen_with_api({user_num: params[:username], user_pass: params[:password]})
      
      if user
        respond_with_formt_json({data: user.user_num, message: message}, 200)
      else
        respond_with_formt_json({message: message}, 401)
      end
    end

    get '/user' do
      respond_with_formt_json({message: '接收成功'}, 201)

      user, message = User.find_by(user_num: params[:token])
      data = {
        roles: ['admin'],
        name: user.user_num,
        avatar: '',
        introduction: 'hey'
      }
      respond_with_formt_json({data: data, message: '查询成功'}, 200)
    end

    get '/device-group/list' do
      records = DeviceGroup.paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(id: :desc)

      respond_with_formt_json({data: {items: records.map(&:to_hash), total: DeviceGroup.count}, message: '接收成功'}, 201)
    end

    get '/device/list' do
      records = Device.paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(updated_at: :desc)

      respond_with_formt_json({data: {items: records.map(&:to_hash), total: Device.count}, message: '接收成功'}, 201)
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end
  end
end