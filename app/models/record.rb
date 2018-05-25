# encoding: utf-8
require 'sinatra/activerecord'

# 代理请求记录表
class Record < ActiveRecord::Base
  self.table_name = 'sys_records'

  belongs_to :device
end