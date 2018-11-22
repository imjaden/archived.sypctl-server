# encoding: utf-8
require 'sinatra/activerecord'

# 任务模板表
class JobTemplate < ActiveRecord::Base
  self.table_name = 'sys_job_templates'

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end