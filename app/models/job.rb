# encoding: utf-8
require 'sinatra/activerecord'

# 任务表
class Job < ActiveRecord::Base
  self.table_name = 'sys_jobs'
end