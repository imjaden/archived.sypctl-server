# encoding: utf-8
require 'uri'
require 'erb'
require 'httparty'
require 'lib/utils/mail_sender.rb'
require 'lib/sinatra/extension_redis'

namespace :monitor do
  def get_wxmp_access_token(redis)
    redis_key = 'wxmp/access-token'
    return redis.get(redis_key) if redis.exists(redis_key)

    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{Setting.wxmp.app_id}&secret=#{Setting.wxmp.app_secret}"
    res = HTTParty.get(url)
    return res.message if res.code != 200
      
    hsh = JSON.parse(res.body)
    redis.set(redis_key, hsh['access_token'])
    redis.expire(redis_key, hsh['expires_in'] - 60)
    return redis.get(redis_key)
  end

  def post_wxmp_message(redis, alarm_hash, wxuser)
    # 设备编号: 100001
    # 设备名称: 友靠智能柜
    # 解决方法: 请打开小程序进行修复
    # 故障信息: 该设备 XX 配件已损坏
    # 异常时间: 2015-12-14 10:20
    access_token = get_wxmp_access_token(redis)
    url = "https://api.weixin.qq.com/cgi-bin/message/wxopen/template/send?access_token=#{access_token}"
    options = {
      access_token: access_token,
      touser: wxuser[:openid],
      form_id: wxuser[:formid],
      template_id: Setting.wxmp.template_id.device_exception,
      page: 'pages/group-list/main',
      data: {
        keyword1: {
          value: alarm_hash[:ip]
        },
        keyword2: {
          value: alarm_hash[:name]
        },
        keyword3: {
          value: '请尽快登录系统人工运维'
        },
        keyword4: {
          value: alarm_hash[:exceptions]
        },
        keyword5: {
          value: Time.now.strftime('%Y-%m-%d %H:%M')
        }
      }
    }

    res = HTTParty.post(url, body: options.to_json)
    puts JSON.pretty_generate(options)
    puts res.code
    puts res.message
    puts res.body
  end

  desc '定时扫描所有设置'
  task device: :environment do
    register Sinatra::Redis

    Device.where(monitor_state: true).each do |device|
      exceptions = []
      exceptions.push("提交时间超出10分钟可能宕机") if (Time.now.to_i - device.updated_at.to_i) > 600
      record_hash = device.latest_record
      exceptions.push("内存>90") if record_hash[:memory_usage] && record_hash[:memory_usage].to_i > 90
      exceptions.push("磁盘>90") if record_hash[:disk_usage] && record_hash[:disk_usage].to_i > 90
      next if exceptions.empty?
      
      alarm_hash = {
        ip: device.wan_ip,
        name: device.human_name,
        exceptions: exceptions.join(';')
      }
      WxUser.where('openid is not null').each do |wx_user|
        openid = wx_user.openid
        redis_key = 'wxmp/formid'
        redis_hkey = 'count@' + openid
        cursor, result = redis.hscan(redis_key, 0, match: openid+'*', count: 1)
        if result && !result.empty?
          post_wxmp_message(redis, alarm_hash, {openid: openid, formid: result[0][1]})
          redis.hdel(redis_key, result[0][0])
          redis.hincrby(redis_key, redis_hkey, -1)
        end
      end
    end
  end

  task deprecated: :environment do
    begin
      include Mail::Methods

      output_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/device.html')
      template_path = File.join(ENV['APP_ROOT_PATH'], 'lib/tasks/templates/device.erb')
      File.open(output_path, "w:utf-8") do |file|
        file.puts ERB.new(File.read(template_path)).result(binding)
      end

      response = send_email(Setting.notify.sender, Setting.notify.email_receivers, "设备异常报告 #{Time.now.strftime('%y%m%m%H%M')}", File.read(output_path))
      puts Time.now
      puts response.inspect
    rescue => e
      puts "#{File.basename(__FILE__)}:#{__LINE__} - #{e.message}"
      puts e.message
    end

    begin
      @devices.each do |device|
        device_group = device.device_group
        alarm_items = alarm_hash[device.id]

        options = {
          "api_token": Setting.notify.push_api_token,
          "user_nums": Setting.notify.push_receivers,
          "title": "设备异常通知",
          "content": "#{device_group ? device_group.name : '未配置分组'}，#{device.human_name || device.hostname} #{alarm_items.join(',')}，请及时运维，点击查看...",
          "template_id": -1,
          "extra_params": {
            "type": "toolbox",
            "template_id": -1,
            "title": "监控设备列表",
            "url": "http://sypctl.ibi.ren/monitor",
            "obj_id": 1004,
            "obj_type": 6
          }
        }
        response = HTTParty.post("http://shengyiplus.com/api/v2/users/push_message", body: options.to_json)
        puts options.to_json
        puts response.inspect
      end
    rescue => e
      puts "#{File.basename(__FILE__)}:#{__LINE__} - #{e.message}"
      puts e.message
    end
  end
end