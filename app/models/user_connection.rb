# encoding: utf-8
require "active_record"

# 用户与分组的关联表
class UserConnection < ActiveRecord::Base
  self.table_name = 'sys_user_connections'

  has_many :users, -> { where(user_type: 'user') }, primary_key: :user_uuid, foreign_key: :uuid
  has_many :wx_users, -> { where(user_type: 'wx_user') }, primary_key: :user_uuid, foreign_key: :uuid

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end