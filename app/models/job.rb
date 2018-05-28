# encoding: utf-8
require 'sinatra/activerecord'

# 任务表
class Job < ActiveRecord::Base
  self.table_name = 'sys_jobs'

  def to_hash
    {
      uuid: self.uuid,
      title: self.title,
      description: self.description,
      app_id: self.app_id,
      app_name: self.app_name,
      version_id: self.version_id,
      version_name: self.version_name,
      device_uuid: self.device_uuid,
      device_name: self.device_name,
      command: self.command,
      output: self.output,
      state: self.state,
      executed_at: self.executed_at
    }
  end
end