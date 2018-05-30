# encoding: utf-8
require 'timeout'
require 'sinatra/activerecord'

# model: 50 管理员行为记录表
class OperationLog < ActiveRecord::Base
  self.table_name = 'sys_operation_logs'
end
