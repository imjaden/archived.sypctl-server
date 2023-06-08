# encoding: utf-8
# 
# 三级备份策略:
# - 一级备份: 阿里云ECS(AliyunECS)
# - 二级备份: MacMini(MacMini)
# - 三级备份: 移动硬盘(HardDisk)
#
# 备份目录下配置:
#
# {
#   "backup_root": "/data",
#   "backup_level": "AliyunECS"
# }
#
require 'json'
require 'digest/md5'

unless File.exist?('sypctl-backup.json')
  puts "请配置 sypctl-backup.json"
  exit(1)
end

sypctl_backup_config = JSON.parse(File.read('sypctl-backup.json'))

backup_level = sypctl_backup_config['backup_level']
backup_root = sypctl_backup_config['backup_root']

file_backup_path = File.join(backup_root, 'file-backups')
mysql_backup_path = File.join(backup_root, 'mysql-backups')
gitlab_backup_path = File.join(backup_root, 'gitlab-backups')

def generate_local_backup_db(backup_type, backup_root, backup_level)
  backup_path = File.join(backup_root, backup_type)
  files = `find #{backup_path} -type f`.split(/\n/)
    .map do |filepath|
      path = filepath.sub(backup_root, '')
      size = File.size(filepath)
      md5 =  Digest::MD5.file(filepath).hexdigest
      "#{path},#{md5},#{size}"
    end

  # 备份文档的快照列表，用以对比文档差异
  snapshot_name = "#{backup_level}-#{backup_type}.snapshot"
  File.open(snapshot_name, "w:utf-8") do |file|
    file.puts(files.join("\n"))
  end
  File.open("#{snapshot_name}.md5", "w:utf-8") do |file|
    file.puts(Digest::MD5.file(snapshot_name).hexdigest)
  end
  `gzip -c #{snapshot_name} > #{snapshot_name}.gz`
end

%w(file-backups mysql-backups gitlab-backups).each do |backup_type|
  generate_local_backup_db(backup_type, backup_root, backup_level)
end

case backup_level
when 'AliyunECS' then
  # 避免下载过慢
  `rm -f *.snapshot`
  # 检测最近一天是否有备份增量
  # 若有备份增量，则执行清理过期备份，否则无操作
when 'MacMini' then 
  # 下载 AliyunECS db/snapshot
  `scp root@gitlab.idata.mobi:/data/sypctl-backups/AliyunECS-* ./`
  # 检测对比 snapshot
  # 下载增量备份
  %w(file-backups mysql-backups gitlab-backups).each do |backup_type|
    snapshot_name = "MacMini-#{backup_type}.snapshot"
    `gunzip -c "#{snapshot_name}.gz" > #{snapshot_name}`
     backup_type_md5 = Digest::MD5.file(snapshot_name).hexdigest
     if backup_type_md5 == File.read("#{snapshot_name}.md5")
       puts "#{snapshot_name} MD5 一致, #{backup_type_md5}"
     else
       puts "#{snapshot_name} MD5 不一致, 跳过"
       next
     end

    local_snapshot = File.read("MacMini-#{backup_type}.snapshot").split("\n")
    aliyun_snapshot = File.read("AliyunECS-#{backup_type}.snapshot").split("\n")
    new_files = aliyun_snapshot - local_snapshot
    unless new_files.empty?
      new_files.each do |line|
        path, md5, size = line.split('.')
        localpath = "#{backup_root}/#{path}"
        `mkdir -p #{File.dirname(localpath)}`
        `scp root@gitlab.idata.mobi:/data/#{path} #{localpath}`
      end
    end
  end
  # 调用 HardDisk 同步
when 'HardDisk' then 
  # 下载 AliyunECS/MacMini db/snapshot
  # 检测对比 snapshot
  # 拷贝增量备份
end

