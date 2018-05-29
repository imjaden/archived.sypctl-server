# encoding: utf-8
require 'sinatra/activerecord'

# 任务表
class Job < ActiveRecord::Base
  self.table_name = 'sys_jobs'

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end
end