# encoding: utf-8
require 'sinatra/activerecord'

# 设备分组表
class DeviceGroup < ActiveRecord::Base
  self.table_name = 'sys_device_groups'

  has_many :devices, primary_key: :id, foreign_key: :device_group_id
end