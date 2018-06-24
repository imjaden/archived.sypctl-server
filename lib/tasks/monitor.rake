# encoding: utf-8
require 'erb'
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

    include Mail::Methods

    output_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/device.html')
    template_path = File.join(ENV['APP_ROOT_PATH'], 'lib/tasks/templates/device.erb')
    File.open(output_path, "w:utf-8") do |file|
      file.puts ERB.new(File.read(template_path)).result(binding)
    end

    response = send_email(Setting.notify.sender, Setting.notify.receivers, "设备异常报告 #{Time.now.strftime('%y%m%m%H%M')}", File.read(output_path))
    puts Time.now
    puts response.inspect
  end
end