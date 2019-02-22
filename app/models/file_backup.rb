# encoding: utf-8
require 'json'
require 'fileutils'
require 'digest/md5'
require 'sinatra/activerecord'

# 文件备份
class FileBackup < ActiveRecord::Base
  self.table_name = 'sys_file_backups'
  
  after_create :refresh_file_backup_cache
  after_update :refresh_file_backup_cache
  after_destroy :refresh_file_backup_cache

  def to_hash
    self.class.column_names.each_with_object({}) do |column_name, hsh|
      value = send(column_name)
      hsh[column_name.to_sym] = (value.is_a?(Time) ? value.strftime('%Y/%m/%d %H:%M:%S') : value)
    end
  end

  def refresh_file_backup_cache
    self.class.refresh_file_backup_cache
  end

  def self.refresh_file_backup_cache
    records = FileBackup.all.order(id: :desc).map { |fb| { uuid: fb.uuid, file_path: fb.file_path, description: fb.description }}.to_json

    cache_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/file-backups')
    FileUtils.mkdir_p(cache_path) unless File.exists?(cache_path)

    hash_path = File.join(cache_path, 'db.hash')
    json_path = File.join(cache_path, 'db.json')
    
    File.open(json_path, 'w:utf-8') { |file| file.puts(records) }
    File.open(hash_path, 'w:utf-8') { |file| file.puts(Digest::MD5.hexdigest(records)) }
  end

  def self.db_hash
    cache_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/file-backups')
    hash_path = File.join(cache_path, 'db.hash')
    refresh_file_backup_cache unless File.exists?(hash_path)

    File.read(hash_path).strip
  end

  def self.db_mtime
    cache_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/file-backups')
    hash_path = File.join(cache_path, 'db.json')
    refresh_file_backup_cache unless File.exists?(hash_path)

    File.mtime(hash_path).strftime('%Y/%m/%d %H:%M:%S')
  end

  def self.db_json
    cache_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/file-backups')
    json_path = File.join(cache_path, 'db.json')
    refresh_file_backup_cache unless File.exists?(json_path)

    JSON.parse(File.read(json_path))
  end

  def self.db_info
    {
      db_mtime: db_mtime,
      db_hash: db_hash,
      db_json: db_json}
  end
end