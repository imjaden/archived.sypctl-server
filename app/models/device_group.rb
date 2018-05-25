# encoding: utf-8
require 'sinatra/activerecord'

# 设备分组表
class DeviceGroup < ActiveRecord::Base
  self.table_name = 'sys_device_groups'
end