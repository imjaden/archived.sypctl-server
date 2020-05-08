# encoding: utf-8
require 'securerandom'
require 'sinatra/activerecord'

# 文档表
class Document < ActiveRecord::Base
  self.table_name = 'sys_documents'

  def create_history_snapshot
    hsh = self.to_hash
    hsh[:uuid] = SecureRandom.uuid.gsub('-', '')
    hsh[:document_uuid] = hsh[:uuid]
    hsh.delete(:id)
    hsh.delete(:history_count)
    ::DocumentHistory.create(hsh)
    self.update_attribute(:history_count, ::DocumentHistory.where(document_uuid: self.uuid).count)
  end

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end
end