# encoding: utf-8
require 'sinatra/activerecord'

# 任务模板表
class JobTemplate < ActiveRecord::Base
  self.table_name = 'sys_job_templates'
end