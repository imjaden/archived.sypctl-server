# encoding: utf-8
# require 'sinatra/activerecord'

# 应用表
class App < ActiveRecord::Base
  self.table_name = 'sys_apps'

  has_many :versions, primary_key: :uuid, foreign_key: :app_uuid
  belongs_to :app_group

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end