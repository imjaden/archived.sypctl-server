# encoding: utf-8
# require 'sinatra/activerecord'

# 每日备份 MySQL 数据元信息
class BackupMysqlMeta < ActiveRecord::Base
  self.table_name = 'sys_backup_mysql_meta'

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end