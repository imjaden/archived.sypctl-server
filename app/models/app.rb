# encoding: utf-8
require 'sinatra/activerecord'

# 应用表
class App < ActiveRecord::Base
  self.table_name = 'sys_apps'

  has_many :versions, primary_key: :id, foreign_key: :app_id
  belongs_to :app_group

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      hsh[column_name.to_sym] = send(column_name)
    end
  end
end