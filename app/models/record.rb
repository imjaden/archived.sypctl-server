# encoding: utf-8
require 'sinatra/activerecord'

# 代理请求记录表
class Record < ActiveRecord::Base
  self.table_name = 'sys_records'

  belongs_to :device
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end

  def self.default_hash
    column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = "无值"
    end
  end
end