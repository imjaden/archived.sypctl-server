# encoding: utf-8
require 'sinatra/activerecord'

# 用户分组表
class UserGroup < ActiveRecord::Base
  self.table_name = 'sys_user_groups'
end