# encoding: utf-8
require 'sinatra/activerecord'

# 任务表
class Job < ActiveRecord::Base
  self.table_name = 'sys_jobs'

  has_one :job_group, primary_key: :job_group_uuid, foreign_key: :uuid

  def update_job_group_state

    if record = self.job_group
      if is_done = record.jobs.all? { |job| job.state == 'done' }
        record.update_attributes({state: 'done'})
      elsif %w(dealing done).include?(self.state)
        record.update_attributes({state: 'dealing'})
      end
    end
  end

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end