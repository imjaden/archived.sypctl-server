# encoding: utf-8
require 'cgi'
# require 'json'
require 'fileutils'
require 'digest/md5'
require 'securerandom'

#
# weixin mp 使用
#
module API
  class V3Controller < API::ApplicationController

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

    get '/wxmp_access_token' do
      access_token = get_wxmp_access_token

      respond_with_formt_json({data: access_token, message: '获取成功'}, 200)
    end

    get '/wxmp_acode' do
      api_authen_params([:page, :scene])

      image_path = get_weixin_acode(params[:scene])
      send_file(image_path, type: 'image/png', filename: File.basename(image_path), disposition: 'inline')
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
      records = DeviceGroup.where(publicly: true).paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(order_index: :asc)

      respond_with_formt_json({data: records.map(&:to_wx_hash), total: DeviceGroup.count, message: '接收成功'}, 201)
    end

    get '/device/list' do
      api_authen_params([:device_group_id])
      records = Device.where(device_group_id: params[:device_group_id]).paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(order_index: :asc)

      respond_with_formt_json({data: records.map(&:to_wx_hash), total: Device.count, message: '接收成功'}, 201)
    end

    get '/device/info' do
      api_authen_params([:device_id])

      record = Device.find_by(id: params[:device_id])
      halt_with_format_json({data: record, message: '查询结果为空', code: 404}, 404) unless record

      respond_with_formt_json({data: record.to_wx_hash, message: '接收成功'}, 201)
    end

    #
    # 微信小程序接口
    #

    # 登录凭证校验
    post '/wxmp/jscode2session' do
      api_authen_params([:code])

      url_template = "https://api.weixin.qq.com/sns/jscode2session?appid=%s&secret=%s&js_code=%s&grant_type=authorization_code"
      url = format(url_template, Setting.wxmp.app_id, Setting.wxmp.app_secret, params[:code])
      puts url
      res = HTTParty.get(url)
      puts res.body, res.code, res.message, res.headers.inspect

      respond_with_json({message: "获取成功", data: res.body}, 200)
    end

    # 创建或更新微信用户信息
    post '/wxmp/user' do
      api_authen_params([:user])

      params[:user][:name] = params[:user][:name].to_s.escape_emoji
      params[:user][:nick_name] = params[:user][:nick_name].to_s.escape_emoji
      if record = WxUser.find_by(openid: params[:user][:openid])
        record.update_attributes(params[:user])
      else
        params[:user][:uuid] ||= generate_uuid
        record = WxUser.create(params[:user])
      end

      respond_with_formt_json({data: record.to_hash, message: '创建/更新成功'}, 201)
    end

    # 提交 formid
    post '/wxmp/formid' do
      api_authen_params([:openid, :formid])
    
      redis_key = 'wxmp/formid'
      expired_timestamp = Time.now.to_f + 7 * 24 * 60
      redis_hkey = "#{params[:openid]}@#{expired_timestamp}"
      redis.hset(redis_key, redis_hkey, params[:formid])

      redis_hkey = "count@#{params[:openid]}"
      redis.hincrby(redis_key, redis_hkey, 1)
      formid_count = redis.hget(redis_key, redis_hkey) || 0
      
      respond_with_formt_json({data: formid_count, message: '提交成功'}, 201)
    end

    get '/wxmp/formid_count' do
      api_authen_params([:openid])

      redis_key = 'wxmp/formid'
      redis_hkey = "count@#{params[:openid]}"
      formid_count = redis.hget(redis_key, redis_hkey) || 0
      
      respond_with_formt_json({data: formid_count, message: '获取成功'}, 200)
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end

    def get_wxmp_access_token
      redis_key = 'wxmp/access-token'
      return redis.get(redis_key) if redis.exists(redis_key)

      res = HTTParty.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{Setting.wxmp.app_id}&secret=#{Setting.wxmp.app_secret}")
      puts res.code
      puts res.message
      puts res.body
      if res.code == 200
        hsh = JSON.parse(res.body)
        redis.set(redis_key, hsh['access_token'])
        redis.expire(redis_key, hsh['expires_in'] - 60)
        return redis.get(redis_key)
      else
        return res.message
      end
    end

    def get_weixin_acode(scene)
      image_folder = app_root_join('public/images/wxacode')
      FileUtils.mkdir_p(image_folder) unless File.exist?(image_folder)

      image_name = scene.gsub('=', '-').gsub('&', '_') + '.png'
      image_path = File.join(image_folder, image_name)

      unless File.exist?(image_path)
        access_token = get_wxmp_access_token
        options = {
          page: 'pages/group-list/main',
          scene: CGI.unescape(scene),
          auto_color: false,
          line_color: {
            r: 128,
            g: 0,
            b: 128
          },
          is_hyaline: true
        }
        headers = {
          'Content-Type' => 'application/json;charset=UTF-8;'
        }
        res = HTTParty.post("https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=#{access_token}", headers: headers, body: JSON.generate(options))
        puts "res.code: #{res.code}"
        puts "res.message: #{res.message}"

        puts res.body if res.body.length < 1000
        File.open(image_path, 'w:utf-8') { |file| file.puts(res.body.force_encoding('utf-8')) }
      end

      image_path
    end
  end
end