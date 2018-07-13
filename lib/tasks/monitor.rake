# encoding: utf-8
require 'erb'
require 'httparty'
require 'lib/utils/mail_sender.rb'

namespace :monitor do
  task device: :environment do

    @devices = Device.where(monitor_state: true).map do |device|
      device if (Time.now.to_i - device.updated_at.to_i) > 600
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
    end

    begin
      @devices.each do |device|
        device_group = device.device_group

        options = {
          "api_token": Setting.notify.push_api_token,
          "user_nums": Setting.notify.push_receivers,
          "title": "监控设备通知",
          "content": "#{device_group ? device_group.name : '未配置分组'}，#{device.human_name || device.hostname} 运行异常，请及时运维，点击查看明细...",
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
    end
  end
end