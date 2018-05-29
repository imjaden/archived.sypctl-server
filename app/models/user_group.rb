# encoding: utf-8
require 'sinatra/activerecord'

# 用户分组表
class UserGroup < ActiveRecord::Base
  self.table_name = 'sys_user_groups'
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end
end