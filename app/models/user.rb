# encoding: utf-8
require 'json'
require 'digest/md5'
require 'sinatra/activerecord'

# 用户表，与生意+ 同源
class User < ActiveRecord::Base
  self.table_name = 'sys_users'

  def self.authen_with_api(params)
    options = {
      api_token: 'a6ae82369ba3ea2be6a733cf970a7dbb',
      user_num: params[:user_num],
      password: ::Digest::MD5.hexdigest(params[:user_pass])
    }
    if user = find_by(user_num: params[:user_num], user_pass: ::Digest::MD5.hexdigest(params[:user_pass]))
      [user, "登录成功"]
    else
      [nil, "用户不存在或密码错误"]
    end
    # response = HTTParty.post "http://shengyiplus.com/api/v1.1/user/authentication", body: options.to_json
    # if response.code == 200
    #   res_hash = ::JSON.parse(response.body)['data']
    #   if user = find_by(user_num: params[:user_num])
    #     user.update_columns({user_name: res_hash['user_name'], user_pass: res_hash['user_pass']})
    #   else
    #     user = create({user_num: res_hash['user_num'], user_name: res_hash['user_name'], user_pass: res_hash['user_pass']})
    #   end
    #   [user, "登录成功"]
    # else
    #   [nil, response.body]
    # end
  end
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end