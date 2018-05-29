# encoding: utf-8
require 'sinatra/activerecord'

# 应用版本表
class Version < ActiveRecord::Base
  self.table_name = 'sys_versions'

  belongs_to :app
  
  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end
end