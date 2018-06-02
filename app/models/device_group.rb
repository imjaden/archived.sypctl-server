# encoding: utf-8
require 'sinatra/activerecord'

# 设备分组表
class DeviceGroup < ActiveRecord::Base
  self.table_name = 'sys_device_groups'

  has_many :devices, primary_key: :id, foreign_key: :device_group_id
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%y/%m/%d %H:%M:%S') : value)
    end
  end
end