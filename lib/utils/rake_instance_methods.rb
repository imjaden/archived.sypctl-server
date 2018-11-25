# encoding: utf-8
require 'securerandom'
require 'digest/md5'

def digest_string_md5(something)
  Digest::MD5.hexdigest(something.to_s)
end

def digest_file_md5(filepath)
  Digest::MD5.file(filepath).hexdigest
end

def rake_task_process_defender(pid_file, redis_status_key, task_name)
  pid_state = check_pid_state(pid_file)
  if !pid_state && redis.exists(redis_status_key) && redis.hget(redis_status_key, 'status') == 'running'
    redis.hmset(redis_status_key, ['status', 'killed', 'time_end', Time.now.to_i])
    puts format(%(%s: %s(%s) - was killed), Time.now, task_name, redis_status_key)
  end
rescue => e
  puts format('%s - pid: %s, redis-key: %s, task-name:%s, exception: %s', Time.now, pid_file, redis_status_key, task_name, e.message)
end

def check_pid_state(file_name)
  pid_state, file_path = false, tmp_pid_path(file_name)
  if File.exist?(file_path)
    pid_value = File.read(file_path).strip
    if `uname -s`.strip.eql?('Darwin')
      pid_state = !`ps -p #{pid_value} | grep -v 'PID' | wc -l`.to_i.zero?
    else
      pid_state = !`ps --no-heading #{pid_value} | wc -l`.to_i.zero?
    end
    unless pid_state
      puts %(#{Time.now}: unkown pid file removed: #{file_name}(#{File.read(file_path).strip}))
      File.delete(file_path)
    end
  end
  pid_state
end

def runtime_block(info, &block)
  bint = Time.now
  yield
  eint = Time.now
  puts %(#{eint}: #{info} done - #{eint - bint}s)
end

def runtime_block_within_thread(thread_index, info, &block)
  bint = Time.now
  yield
  eint = Time.now
  puts %(Thread(#{thread_index}): #{bint} - #{info} run #{eint - bint}s)
end

def exit_when(is_exit, info)
  if is_exit
    puts info
    exit
  end
end

def return_when(is_return, info)
  if is_return
    puts info
    return true
  end
end

def app_root_join(path)
  File.join(ENV['APP_ROOT_PATH'] || Dir.pwd, path)
end

def app_tmp_join(path)
  File.join(ENV['APP_ROOT_PATH'] || Dir.pwd, 'tmp', path)
end

def tmp_pid_path(pid_file_name)
  app_tmp_join(%(pids/#{pid_file_name}.pid))
end

def generate_pid_file(file_name, pid = Process.pid)
  File.open(tmp_pid_path(file_name), 'w:utf-8') { |file| file.puts(pid) }
end

def delete_pid_file(file_name)
  file_path = tmp_pid_path(file_name)
  File.delete(file_path) if File.exist?(file_path)
end

def exit_when_redis_not_match(redis_key, key_name, expect_value)
  is_should_exit = (redis.exists(redis_key) && redis.hget(redis_key, key_name) == expect_value)
  info = format('%s - %s:%s = %s then exit', Time.now, redis_key, key_name, redis.hget(redis_key, key_name))
  exit_when(is_should_exit, info)
  puts info.sub('exit', 'continue')
end

def return_when_redis_not_match(redis_key, key_name, expect_value)
  is_should_return = (redis.exists(redis_key) && redis.hget(redis_key, key_name) == expect_value)
  info = format('%s - %s:%s = %s then return', Time.now, redis_key, key_name, redis.hget(redis_key, key_name))
  return true if return_when(is_should_return, info)
  puts info.sub('return', 'continue')
  return false
end

def refresh_redis_key_value(redis_key, key_name, key_value = 'null')
  if redis.exists(redis_key)
    key_value = (redis.hget(redis_key, key_name) || '').split(';').uniq.take(2**5).push(key_value).join(';')
  end
  redis.hmset(redis_key, [key_name, key_value])
end

def update_redis_key_value(redis_key, key_name, key_value = 'null')
  redis.hmset(redis_key, [key_name, key_value])
end

def update_redis_run_time(redis_key)
  return unless redis.exists(redis_key)
  return unless time_start = redis.hget(redis_key, 'time_start')
  time_run = format('%.4f', Time.now - Time.at(time_start.to_i))
  redis.hmset(redis_key, ['time_end', Time.now.to_i, 'time_run', time_run])
end

def execute_sql(conn, sql)
  sql.split(';').map(&:strip).compact.reject(&:empty?).map do |sql|
    begin
      conn.execute(sql)
    rescue => e
      puts '*' * 10 + 'execute_sql - start' + '*' * 10
      puts e.message
      puts '-' * 10
      puts sql
      puts '*' * 10 + 'execute_sql - end' + '*' * 10
    end
  end
end

def query_sql(conn, sql, titles)
  rows = []
  execute_sql(conn, sql).map do |result|
    if result && !result.to_a.empty?
      temp = []
      result.to_a.each do |fields|
        temp.push titles.zip(fields).to_h
      end
      rows.push temp
    end
  end
  rows
end

def app_dependency_tables
  Dir.glob(%(#{Dir.pwd}/app/models/*.rb)).map do |filepath|
    content = IO.read(filepath)
    content.scan(/self\.table_name\s+=\s+['"](.*?)['"]/).flatten
  end.flatten.delete_if(&:empty?)
end

def import_sql_file_command(sql_path, config, output_path="./#{Time.now.to_i}_import_sql_output.sql")
  "mysql --host=#{config[:host] || '127.0.0.1'} --port=#{config[:port] || 3306} --user=#{config[:username] || 'root'} --password=#{config[:password]} --database=#{config[:database]} < #{sql_path} >> #{output_path} 2>&1"
end

def execute_sql_command(sql_sentence, config)
  "mysql --host=#{config[:host]} --port=#{config[:port] || 3306} --user=#{config[:username]} --password=#{config[:password]} --database=#{config[:database]} --table -e '#{sql_sentence}'"
end

def filter_sensitive_info(text)
  part_lenth = text.to_s.length/4
  return '**' if part_lenth.zero?

  text.to_s[0..part_lenth-1] + '****' + text.to_s[(-part_lenth)..-1]
rescue => e
  text
end

def mysqldump_sys_tables(mysql_backup_path, config, sys_tables, timestamp)
  mysqldump_command = "mysqldump --default-character-set=utf8 --host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --databases #{config[:database]} --tables #{sys_tables.join(' ')} | gzip > #{mysql_backup_path}/#{timestamp}-#{config[:database]}.sql.gz".gsub(/\s+/, ' ')

  File.open("#{mysql_backup_path}/#{timestamp}-sys_tables.list", "w:utf-8") { |file| file.puts(sys_tables) }
  if sys_tables.empty?
    File.open("#{mysql_backup_path}/#{timestamp}-failed.log", "w:utf-8") { |file| file.write("\n#{Time.now}: sys_tables list is empty!\n") }
  else
    `#{mysqldump_command}`
  end
end

def mysqldump_functions(mysql_backup_path, config, timestamp)
  mysqldump_command = "mysqldump -ntd -R --host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --databases #{config[:database]} | gzip > #{mysql_backup_path}/#{timestamp}-#{config[:database]}-functions.sql.gz".gsub(/\s+/, ' ')
  `#{mysqldump_command}`
end

def hash_to_array(hsh)
  hsh = [hsh] unless hsh.is_a?(Array)

  titles = hsh.map(&:keys).flatten.uniq
  list = hsh.map do |item|
    titles.map { |key| item[key] }
  end

  [titles, list]
end
