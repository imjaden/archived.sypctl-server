# encoding: utf-8
require 'sinatra/activerecord'

# 应用表
class App < ActiveRecord::Base
  self.table_name = 'sys_apps'

  has_many :versions, primary_key: :id, foreign_key: :app_id
  belongs_to :app_group
end