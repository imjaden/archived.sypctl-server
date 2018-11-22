# encoding: utf-8
require 'sinatra/activerecord'

# 设备分组表
class DeviceGroup < ActiveRecord::Base
  self.table_name = 'sys_device_groups'

  has_many :devices, primary_key: :id, foreign_key: :device_group_id
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end

  def to_wx_hash
    hsh = to_hash
    hsh[:device_count] = self.devices.count
    hsh[:device_unhealth_count] = self.devices.count { |device| device.health_value >= 3 }
    hsh[:health_type] = health_type(hsh[:device_count], hsh[:device_unhealth_count])
    hsh[:health_value] = health_map[hsh[:health_type].to_sym]

    return hsh
  end

  def health_map
    {
      success: 0,
      blue: 1,
      info: 2,
      warning: 3,
      error: 4
    }
  end

  # const error = "#ED1111";
  # const warning = "#FF9900";
  # const info = "#11A50A";
  # const blue = "#108EE9";
  # const success = "#19BE6B";
  def health_type(device_count, device_unhealth_count)
    if device_count <= 0
      return 'blue'
    elsif device_unhealth_count <= 0
      return 'success'
    elsif device_unhealth_count*1.0/device_count >= 0.75
      return 'error'
    elsif device_unhealth_count*1.0/device_count >= 0.5
      return 'blue'
    elsif device_unhealth_count*1.0/device_count >= 0.25
      return 'info'
    else
      return 'warning'
    end
  rescue => e
    puts "device_count: #{device_count}, device_unhealth_count: #{device_unhealth_count}, exception: #{e.message}"
    'error'
  end

  def health_value
    to_wx_hash[:health_value]
  end
end