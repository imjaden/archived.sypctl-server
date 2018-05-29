# encoding: utf-8
require 'sinatra/activerecord'

# 应用分组表
class AppGroup < ActiveRecord::Base
  self.table_name = 'sys_app_groups'

  has_many :apps, primary_key: :id, foreign_key: :app_group_id
end