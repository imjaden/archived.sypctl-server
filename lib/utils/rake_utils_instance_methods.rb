# encoding: utf-8
require 'securerandom'

def utils_import_sql_file_command(sql_path, config, output_path)
  "mysql --host=#{config[:host]} --port=#{config[:port] || 3306} --user=#{config[:username]} --password=#{config[:password]} --database=#{config[:database]} < #{sql_path} >> #{output_path} 2>&1"
end

def utils_mysqldump_sys_tables(mysql_backup_path, config, sys_tables, timestamp)
  mysqldump_command = "mysqldump --default-character-set=utf8 --host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --databases #{config[:database]} --tables #{sys_tables.join(' ')} | gzip > #{mysql_backup_path}/#{timestamp}-#{config[:database]}.sql.gz".gsub(/\s+/, ' ')

  File.open("#{mysql_backup_path}/#{timestamp}-sys_tables.list", "w:utf-8") { |file| file.puts(sys_tables) }
  if sys_tables.empty?
    File.open("#{mysql_backup_path}/#{timestamp}-failed.log", "w:utf-8") { |file| file.write("\n#{Time.now}: sys_tables list is empty!\n") }
  else
    `#{mysqldump_command}`
  end
end

def utils_mysqldump_functions(mysql_backup_path, config, timestamp)
  mysqldump_command = "mysqldump -ntd -R --host=#{config[:host]} --port=#{config[:port]} --user=#{config[:username]} --password=#{config[:password]} --databases #{config[:database]} | gzip > #{mysql_backup_path}/#{timestamp}-#{config[:database]}-functions.sql.gz".gsub(/\s+/, ' ')
  `#{mysqldump_command}`
end

def utils_data_source_convert_to_hash(record)
  database_ip, database_port = record.data_source_url.scan(/mysql:\/\/(.*?)\//).flatten.join.split(":")
  {
    adapter: 'mysql2',
    encoding: 'utf8',
    host: database_ip,
    port: database_port || 3306,
    username: record.data_source_user_name,
    password: record.data_source_password,
    database: record.data_source_name,
    flags: ['MULTI_STATEMENTS']
  }
rescue => e
  puts "#{__FILE__}:#{__LINE__} #{e.message}"
  nil
end

def hash_to_array(hsh)
  hsh = [hsh] unless hsh.is_a?(Array)

  titles = hsh.map(&:keys).flatten.uniq
  list = hsh.map do |item|
    titles.map { |key| item[key] }
  end

  [titles, list]
end

def utils_procedure_generate_error_report(config)
  datasource_id = "#{config[:host]}-#{config[:port]}-#{config[:database]}".gsub('-', '_')
  procedures_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/procedures')
  errors_path = Dir.glob(File.join(procedures_path, "*.error")).to_a
  return false if errors_path.empty?

  current_host_database_errors_path = errors_path.select do |error_path|
    basename = File.basename(error_path, ".error")
    procode, ldatasource_id = basename.split('-')
    datasource_id == ldatasource_id
  end
  return false if current_host_database_errors_path.empty?

  errors_output = current_host_database_errors_path.map.with_index do |error_path, index|
    basename = File.basename(error_path, ".error")
    procode, ldatasource_id = basename.split('-')
    procedure_sql_path = File.join(procedures_path, procode)
    procedure_info_path = File.join(procedures_path, "#{procode}.info")
    lprocode, ltitle, lproname, lparameter = IO.readlines(procedure_info_path)
    dom_id = SecureRandom.uuid
    error_lines = File.readlines(error_path).select { |line| line.strip.length > 0 }
    error_output = error_lines.size == 1 ? error_lines.join : error_lines.map.each_with_index { |line, index| "#{index+1}. #{line}" }.join
    <<-EOF.strip_heredoc
      <table class="table table-bordered" style="margin-bottom: 10px;">
        <tr><td style="word-break:keep-all!important;width:20%;">应用编号</td><td>#{index + 1}/#{lprocode.to_s.strip}&nbsp;&nbsp;<a style="float:right;margin-right:10px;" onclick="toggleShowProcedureContent(this, '#{dom_id}')"><span class="glyphicon glyphicon-eye-open"></span></a></td></tr>
        <tr><td style="word-break:keep-all!important;width:20%;">应用标题</td><td>#{ltitle.to_s.strip}</td></tr>
        <tr><td style="word-break:keep-all!important;width:20%;">存储过程</td><td>#{lproname.to_s.strip}</td></tr>
        <tr class="hidden #{dom_id}"><td style="word-break:keep-all!important;">执行参数</td><td>#{lparameter.to_s.strip}</td></tr>
        <tr><td colspan="2">部署报错:</td></tr>
        <tr><td colspan="2"><pre style="color:red;">#{error_output}</pre></td></tr>
        <tr class="hidden #{dom_id}"><td colspan="2">存储过程:</td></tr>
        <tr class="hidden #{dom_id}"><td colspan="2"><pre>#{File.read(procedure_sql_path)}</pre></td></tr>
      </table>
    EOF
  end.compact

  error_report_path = File.join(procedures_path, "procedures-state-exception-#{datasource_id}.html")
  File.delete(error_report_path) if File.exists?(error_report_path)

  puts error_report_path
  File.open(error_report_path, "a+:utf-8") do |file|
    file.write <<-EOF.strip_heredoc
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
      <title>异常报告</title>
      <meta charset="utf-8">
      <link rel="icon" href="https://v3.bootcss.com/favicon.ico">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
      <link rel="stylesheet" href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
      <style>
        pre, td {
          white-space: pre-wrap!important;
          word-wrap: break-word!important;
          word-break: break-word!important;
          *white-space:normal!important;
          line-height: 1;
        }
        a:hover {
          cursor: pointer;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-8 col-md-offset-2">
            <div class="jumbotron">
              <h1>异常报告</h1>
              <p>在同步 REP 存储过程列表至数据库 #{config[:database]}@#{config[:host]}:#{config[:port]} 过程中，出现 <strong>#{errors_output.length} </strong>处理异常报错，具体如下：</p>
              <p>创建时间：#{Time.now.strftime("%y-%m-%d %H:%M:%S")}</p>
            </div>
            #{errors_output.join("\n")}
          </div>
        </div>
      </div>
      <script src="http://libs.baidu.com/jquery/2.0.0/jquery.min.js"></script>
      <script>
        function toggleShowProcedureContent(ctl, dom_id) {
          var $dom = $("." + dom_id),
              $this = $(ctl);
          if($dom.hasClass("hidden")) {
            $dom.removeClass("hidden");
            $this.find("span").addClass("glyphicon-eye-close").removeClass("glyphicon-eye-open");
          } else {
            $dom.addClass("hidden");
            $this.find("span").addClass("glyphicon-eye-open").removeClass("glyphicon-eye-close");
          }
        }
      </script>
    </body>
    </html>
    EOF
  end

  return error_report_path
end


def utils_sqls_generate_error_report
  saas_sqls_state_path = File.join(ENV['APP_ROOT_PATH'], 'tmp/saas_sqls_state')
  saas_sqls_path = File.join(saas_sqls_state_path, "sqls")
  errors_path = Dir.glob(File.join(saas_sqls_path, "*.error")).to_a
  return false if errors_path.empty?

  errors_output = errors_path.map.with_index do |error_path, index|
    sql_code = File.basename(error_path, ".error")
    sql_info_path = File.join(saas_sqls_path, "#{sql_code}.info")
    lsqlcode, ltitle, lparameter, lsqlcontent = IO.readlines(sql_info_path)
    <<-EOF.strip_heredoc
      <table class="table table-bordered" style="margin-bottom: 10px;">
        <tr><td style="word-break:keep-all!important;">异常序号</td><td>#{index + 1}</td></tr>
        <tr><td style="word-break:keep-all!important;">标题简介</td><td>#{ltitle.to_s.strip}</td></tr>
        <tr><td style="word-break:keep-all!important;">唯一编码</td><td>#{lsqlcode.to_s.strip}</td></tr>
        <tr><td style="word-break:keep-all!important;">执行参数</td><td>#{lparameter.to_s.strip}</td></tr>
        <tr><td colspan="2">部署报错:</td></tr>
        <tr><td colspan="2"><pre style="color:red;">#{File.read(error_path)}</pre></td></tr>
      </table>
    EOF
  end.compact

  error_report_path = File.join(saas_sqls_path, "sqls-state-exception-report.html")
  File.delete(error_report_path) if File.exists?(error_report_path)

  puts error_report_path
  File.open(error_report_path, "a+:utf-8") do |file|
    file.write <<-EOF.strip_heredoc
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
      <title>异常报告</title>
      <meta charset="utf-8">
      <link rel="icon" href="https://v3.bootcss.com/favicon.ico">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
      <link rel="stylesheet" href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
      <style>
        pre, td {
          white-space: pre-wrap!important;
          word-wrap: break-word!important;
          *white-space:normal!important;
          line-height: 1;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-8 col-md-offset-2">
            <div class="jumbotron">
              <h1>异常报告</h1>
              <p>在监测 SQL 过程中，出现 <strong>#{errors_output.length} </strong>处理异常报错，具体如下：</p>
              <p>创建时间：#{Time.now.strftime("%y-%m-%d %H:%M:%S")}</p>
            </div>
            #{errors_output.join("\n")}
          </div>
        </div>
      </div>
    </body>
    </html>
    EOF
  end

  return error_report_path
end

def saas_report_cache_state_exception(exception, config)
  filename = "report-cache-state-exception-#{SecureRandom.uuid.gsub('-', '')}.html"
  File.open(app_tmp_join("monitor/info/#{filename}"), "w:utf-8") do |file| 
    file.puts <<-EOF.strip_heredoc
      <!DOCTYPE html>
      <html lang="zh-CN">
      <head>
        <title>异常报告</title>
        <meta charset="utf-8">
        <link rel="icon" href="https://v3.bootcss.com/favicon.ico">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <link rel="stylesheet" href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
        <style>
          pre, td {
            white-space: pre-wrap!important;
            word-wrap: break-word!important;
            *white-space:normal!important;
            line-height: 1;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="row">
            <div class="col-xs-12 col-md-8 col-md-offset-2">
              <div class="jumbotron">
                <h1>异常报告</h1>
                <p>在检测报表缓存状态 #{config[:database]}@#{config[:host]} 过程中，出现异常报错，具体如下：</p>
                <p>创建时间：#{Time.now.strftime("%y-%m-%d %H:%M:%S")}</p>
              </div>
              <pre>
              #{exception}
              </pre>
            </div>
          </div>
        </div>
      </body>
      </html>
    EOF
  end
  "<a href='/monitor/info/#{filename}' target='_blank'><span class='glyphicon glyphicon-stats'></span></a>"
end
