# encoding: utf-8
require 'sinatra/activerecord'

# 设备表（服务器）
class Device < ActiveRecord::Base
  self.table_name = 'sys_devices'

  has_many :records, primary_key: :uuid, foreign_key: :uuid
end