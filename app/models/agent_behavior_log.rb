# encoding: utf-8
# require 'json'
require 'digest/md5'
# require 'sinatra/activerecord'

# 代理端行为记录表
class AgentBehaviorLog < ActiveRecord::Base
  self.table_name = 'sys_agent_behavior_logs'
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end