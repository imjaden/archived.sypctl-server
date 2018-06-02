# encoding: utf-8
require 'timeout'
require 'sinatra/activerecord'

# model: 50 管理员行为记录表
class OperationLog < ActiveRecord::Base
  self.table_name = 'sys_operation_logs'
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%y/%m/%d %H:%M:%S') : value)
    end
  end
end
