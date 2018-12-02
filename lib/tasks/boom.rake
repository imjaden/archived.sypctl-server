# encoding: utf-8
require 'yaml'
require 'json'
namespace :boom do
  def check_setting_has_key?(keystr, delimit = '.')
    parts = keystr.split(delimit)
    instance = ::Setting
    has_key = true
    while has_key & p = parts.shift
      has_key = instance.has_key?(p)
      instance = instance.send(p) if has_key
    end
    has_key
  end

  def check_dirpath_writable(dirpath, prompt)
    unless File.exists?(dirpath)
      puts "ERROR: #{prompt}: #{dirpath} 路径不存在"
      return false
    end

    begin
      writable_filepath = "#{dirpath}/writable.txt"
      File.open(writable_filepath, "w:utf-8") { |file| file.puts(Time.now.to_i) }
      FileUtils.rm(writable_filepath)
    rescue => e
      puts "ERROR: #{prompt}: #{dirpath} 不可写入文件"
      puts e.message
      return false
    end

    begin
      writable_dirpath = "#{dirpath}/writable"
      FileUtils.mkdir(writable_dirpath)
      FileUtils.rmdir(writable_dirpath)
    rescue => e
      puts "ERROR: #{prompt}: #{dirpath} 不可创建目录"
      puts e.message
      return false
    end
  end

  def check_sidekiq_configuration
    yaml_path = app_root_join("config/sidekiq.yaml")
    yaml_hash = YAML.load(IO.read(yaml_path))
    queues = yaml_hash["queues"] || yaml_hash[:queues] || []
    if ENV['sidekiq.queue'].empty?
      puts "Error - 请配置 config/settings.yaml 中 sidekiq.queue 参数"
      return false
    else
      unless queues.include?(ENV['sidekiq.queue'])
        puts "Error - 请配置 config/sidekiq.yaml 中 queues 参数包含配置的 queue 名称："
        puts <<-EOF

# config/sidekiq.yaml
:queues:
  - #{ENV['sidekiq.queue']}
  - default
        EOF
        return false
      end
    end

    puts "sidekiq: 配置正确"
  end

  desc 'check config/setting.yaml necessary keys'
  task setting: :environment do
    {
      'Redis' => ['redis_url'],
      '应用配置' => ['website.shortcut', 'website.slogan', 'website.title', 'website.domain', 'website.api_key'],
      '极验验证' => ['geetest.captcha_id', 'geetest.private_key'],
      '进程管理' => ['unicorn.timeout', 'unicorn.worker_processes'],
      'API 验证' => ['api_keys'],
      '微信小程序' => ['wxmp.app_id', 'wxmp.app_secret']
    }.each_pair do |key, array|
      not_exist_keys = array.find_all { |key_string| !check_setting_has_key?(key_string) }
      puts %(【#{key}】缺失下述字段:\n#{not_exist_keys.join("\n")}) unless not_exist_keys.empty?
    end

    # check_sidekiq_configuration
    # check_dirpath_writable(Setting.database_backup_path, 'database_backup_path')
  end
end
