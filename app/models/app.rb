# encoding: utf-8
require 'sinatra/activerecord'

# 应用表
class App < ActiveRecord::Base
  self.table_name = 'sys_apps'
end