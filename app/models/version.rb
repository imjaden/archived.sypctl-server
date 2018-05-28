# encoding: utf-8
require 'sinatra/activerecord'

# 应用版本表
class Version < ActiveRecord::Base
  self.table_name = 'sys_versions'

  belongs_to :app
end