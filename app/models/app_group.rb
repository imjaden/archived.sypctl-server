# encoding: utf-8
require 'sinatra/activerecord'

# 应用分组表
class AppGroup < ActiveRecord::Base
  self.table_name = 'sys_app_groups'

  has_many :apps, primary_key: :id, foreign_key: :app_group_id
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end
end