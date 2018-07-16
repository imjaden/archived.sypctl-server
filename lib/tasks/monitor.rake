# encoding: utf-8
require 'erb'
require 'httparty'
require 'lib/utils/mail_sender.rb'

namespace :monitor do
  task device: :environment do

    alarm_hash = {}
    @devices = Device.where(monitor_state: true).map do |device|
      alarm_hash[device.id] = []
      alarm_hash[device.id].push("宕机") if (Time.now.to_i - device.updated_at.to_i) > 600
      record_hash = device.latest_record
      alarm_hash[device.id].push("内存>90%") if record_hash[:memory_usage] && record_hash[:memory_usage].to_i > 90
      alarm_hash[device.id].push("磁盘>95%") if record_hash[:disk_usage] && record_hash[:disk_usage].to_i > 95

      device unless alarm_hash[device.id].empty?
    end.compact

    if @devices.empty?
      puts "所有监控设备运行正常"
      exit
    end

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
      puts e.backtrace
    end

    exit
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
        puts Time.now
        puts response.inspect
      end
    rescue => e
      puts "#{File.basename(__FILE__)}:#{__LINE__} - #{e.message}"
      puts e.message
      puts e.backtrace
    end
  end
end