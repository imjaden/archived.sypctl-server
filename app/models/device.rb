# encoding: utf-8
require 'timeout'
require 'lib/utils/device.rb'
require 'sinatra/activerecord'

# 设备表（服务器）
class Device < ActiveRecord::Base
  self.table_name = 'sys_devices'

  has_many :records, primary_key: :uuid, foreign_key: :uuid
  belongs_to :device_group
  has_one :service, primary_key: :uuid, foreign_key: :uuid

  after_create :validate_ssh_state
  after_update :validate_ssh_state

  def validate_ssh_state
    update_columns({human_name: self.hostname}) if self.human_name.blank?

    return if self.ssh_ip.blank? || self.ssh_port.blank? || self.ssh_username.blank? || self.ssh_password.blank?

    ::Timeout::timeout(5) do 
      ::Net::SSH.start(self.ssh_ip, self.ssh_username, port: self.ssh_port, password: self.ssh_password) do |ssh|
        update_columns({ssh_state: true})

        ssh.exec!('/sbin/blkid -s UUID') do |_, stream, data|
          device_uuid = ::Utils::Linux._device_uuid(data)
          update_columns({uuid: device_uuid}) if device_uuid.length > 16
        end if self.uuid.blank?

        # ssh.exec!("/usr/bin/nohup curl -sS http://gitlab.ibi.ren/syp-apps/sypctl/raw/dev-0.0.1/env.sh | bash &") { |_, stream, data| puts data }
      end
    end
  rescue => e
    puts "#{__FILE__}@#{__LINE__}: #{e.message}"
    update_columns({ssh_state: false})
  end

  def latest_record
    if record = self.records.order(id: :desc).first
      record.to_hash
    else
      ::Record.default_hash
    end
  end
  
  def to_hash
    result = self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%y/%m/%d %H:%M:%S') : value)
    end
    result[:human_name] ||= result[:hostname]
    result
  end
end