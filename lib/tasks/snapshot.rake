require 'active_record'
require 'fileutils'

namespace :mysql do
  def exec_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  desc 'db/migrate/timestamp_*.rb not in schema_migrations'
  task diff: :environment do
    migrate_path = File.join(ENV['APP_ROOT_PATH'], 'db/migrate/')
    timestamps = []
    Dir.entries(migrate_path).each do |migrate|
      next if migrate == '.' || migrate == '..'

      timestamp = migrate.split('_')[0]
      timestamps.push(timestamp)
    end

    versions = exec_sql('select version from schema_migrations;').map(&:first)

    puts 'migrate not in schema_migrations:'
    puts timestamps - versions
    (timestamps - versions).each do |version|
      puts "insert into schema_migrations(version) value('#{version}');"
    end
    puts '-' * 10
    puts 'schema_migrations not in migrate:'
    puts versions - timestamps
  end

  namespace :snapshot do

    desc '快照本地数据库数据表结构，部署其他环境时自动补充字段调整'
    task generate: :environment do
      conn = ActiveRecord::Base.connection
      config = ActiveRecord::Base.connection_config()
      output, procedures_output = [], []
      output.push <<-EOF.strip_heredoc
        -- ------------------------------------------------
        -- database snapshot
        -- generated at: #{Time.now.strftime("%y-%m-%d %H:%M:%S")}
        --
        -- host: #{config[:host]}
        -- port: #{config[:port] || 3306}
        -- username: #{config[:username]}
        -- database: #{config[:database]}
        -- 
        -- ------------------------------------------------

        drop procedure if exists syppro_add_column;
        delimiter ;;
        create procedure syppro_add_column(
            in param_table_name tinytext,
            in param_field_name tinytext,
            in param_field_def text
        )
        begin
            if not exists (
                select * from information_schema.columns
                where column_name=param_field_name and table_name=param_table_name and table_schema=database()
            )
            then
                set @ddl = concat('alter table ', database(), '.', param_table_name, ' add column ', param_field_name, ' ', param_field_def);
                prepare stmt from @ddl;
                execute stmt;
                select @ddl as '-- 字段调整';
            end if;
        end
        ;;
        delimiter ;

        drop procedure if exists syppro_create_table;
        delimiter ;;
        create procedure syppro_create_table(
            in param_table_name tinytext
        )
        begin
            if not exists (
                select * from information_schema.tables
                where table_name=param_table_name and table_schema=database()
            )
            then
                select param_table_name as '-- 创建数据表';
            end if;
        end
        ;;
        delimiter ;

        /*
         * 判断业务表中是否存在某索引，不存在则创建，存在则没有操作
         *
         * 参数:
         * @param_table_name: 数据表名称
         * @param_index_name: 索引名称
         * @param_index_def: 索引列名，多个列名时使用逗号分隔
         *
         * 示例:
         * call syppro_add_index('sys_devices', 'index_uuid', 'uuid');
         * call syppro_add_index('sys_devices', 'index_code_and_num', 'code,num');
         */
        drop procedure if exists syppro_add_index;
        delimiter ;;
        create procedure syppro_add_index(
            in param_table_name tinytext,
            in param_index_name tinytext,
            in param_index_def text)
        begin
            set @db_name = database();
            if not exists (
                select distinct index_name from information_schema.statistics 
                where table_schema = @db_name and table_name = param_table_name and index_name = param_index_name
            )
            then
                set @ddl = concat('alter table ', @db_name, '.', param_table_name, ' add index ', param_index_name, '(', param_index_def, ')');
                prepare stmt from @ddl;
                execute stmt;
                deallocate prepare stmt; 
                select @ddl as '-- 索引添加';
            end if;
        end
        ;;
        delimiter ;

        drop procedure if exists syppro_add_unique_index;
        delimiter ;;
        create procedure syppro_add_unique_index(
            in param_table_name tinytext,
            in param_index_name tinytext,
            in param_index_def text)
        begin
            set @db_name = database();
            if not exists (
                select distinct index_name from information_schema.statistics 
                where table_schema = @db_name and table_name = param_table_name and index_name = param_index_name
            )
            then
                set @ddl = concat('alter table ', @db_name, '.', param_table_name, ' add unique index ', param_index_name, '(', param_index_def, ')');
                prepare stmt from @ddl;
                execute stmt;
                deallocate prepare stmt; 
                select @ddl as '-- 索引添加';
            end if;
        end
        ;;
        delimiter ;

        /*
         * 判断业务表中是否存在某索引，存在则删除，不存在则没有操作
         *
         * 参数:
         * @param_table_name: 数据表名称
         * @param_index_name: 索引名称
         * @param_index_def: 索引列名，多个列名时使用逗号分隔
         *
         * 示例:
         * call syppro_del_index('sys_devices', 'index_uuid', 'uuid');
         * call syppro_del_index('sys_devices', 'index_code_and_num', 'code,num');
         */
        drop procedure if exists syppro_del_index;
        delimiter ;;
        create procedure syppro_del_index(
            in param_table_name tinytext,
            in param_index_name tinytext,
            in param_index_def text)
        begin
            set @db_name = database();
            if exists (
                select distinct index_name from information_schema.statistics 
                where table_schema = @db_name and table_name = param_table_name and index_name = param_index_name
            )
            then
                set @ddl = concat('alter table ', @db_name, '.', param_table_name, ' drop index ', param_index_name, '(', param_index_def, ')');
                prepare stmt from @ddl;
                execute stmt;
                deallocate prepare stmt; 
                select @ddl as '-- 索引删除';
            end if;
        end
        ;;
        delimiter ;
      EOF

      app_dependency_tables.each do |table_name|
        next if table_name.empty?

        create_table_sql = conn.exec_query("show create table #{table_name}").to_a.flatten[0]["Create Table"]
        increment_zero = create_table_sql.scan(/(AUTO_INCREMENT=\d+)/).flatten[0]
        create_table_sql = create_table_sql.sub(increment_zero, "AUTO_INCREMENT=0") if increment_zero
        create_table_sql =create_table_sql.sub("CREATE TABLE ", "CREATE TABLE IF NOT EXISTS ") + ";"

        output.push ""
        output.push "call syppro_create_table('#{table_name}');"
        output.push create_table_sql

        conn.exec_query("desc #{table_name}").to_a.flatten.map { |h| h['Field'] }.each do |field|
          field_def = create_table_sql.scan(/`#{field}`\s(.*?),$/).flatten.join.gsub(/\'/, '"')
          # puts "ALTER TABLE `#{config[:database]}`.`#{table_name}` ADD COLUMN `#{field}` #{part};"
          field_def = 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP' if field == 'created_at'
          field_def = 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' if field == 'updated_at'

          procedures_output.push "call syppro_add_column('#{table_name}', '#{field}', '#{field_def}');"
        end
      end
      output.push "-- procedures"
      output.push procedures_output.join("\n")


      snapshots_path = File.join(ENV['APP_ROOT_PATH'], 'db/snapshots')
      FileUtils.mkdir_p(snapshots_path) unless File.exist?(snapshots_path)

      snapshot_name = "snapshot-#{Time.now.strftime('%y%m%d%H%M%S')}.sql"
      snapshot_path = File.join(snapshots_path, snapshot_name)
      latest_index_path = File.join(snapshots_path, "latest.index")

      File.open(snapshot_path, "w:utf-8") { |file| file.puts(output.join("\n")) }
      File.open(latest_index_path, "w:utf-8") { |file| file.puts(snapshot_name) }

      puts <<-EOF.strip_heredoc
        数据库连接:
        - host: #{config[:host]}
        - port: #{config[:port] || 3306}
        - username: #{config[:username]}
        - database: #{config[:database]}

        快照生成成功:
        - 路径: #{snapshot_path.sub(ENV['APP_ROOT_PATH'], '.')}
        - 大小: #{File.size(snapshot_path).number_to_human_size}
        - 哈希: #{digest_file_md5(snapshot_path)}
        - 更新时间: #{File.mtime(snapshot_path)}
      EOF
    end

    desc "加载最新快的备份照至项目数据库"
    task load: :environment do
      snapshots_path = File.join(ENV['APP_ROOT_PATH'], 'db/snapshots')
      latest_index_path = File.join(snapshots_path, "latest.index")
      snapshot_name = File.read(latest_index_path).strip
      snapshot_path = File.join(snapshots_path, snapshot_name)

      unless File.exist?(snapshot_path)
        puts "快照异常:\n#{snapshot_path} 不存在\n退出操作!"
        exit
      end

      # config = ActiveRecord::Base.connection_config()
      config = {adapter: "mysql2", database: "sypctl_pro", host: "127.0.0.1", port: 3306, username: "root", password: "Root@321"}
      puts <<-EOF.strip_heredoc
        项目数据库连接:
        - host: #{config[:host]}
        - port: #{config[:port] || 3306}
        - username: #{config[:username]}
        - database: #{config[:database]}

        快照详情:
        - 路径: #{snapshot_path.gsub(ENV['APP_ROOT_PATH'], '.')}
        - 大小: #{File.size(snapshot_path).number_to_human_size}
        - 哈希: #{digest_file_md5(snapshot_path)}
        - 更新时间: #{File.mtime(snapshot_path)}
      EOF

      snapshot_tmp_path = File.join(ENV['APP_ROOT_PATH'], 'tmp')
      snapshot_output_path = File.join(snapshot_tmp_path, snapshot_name + '.output')
      Dir.mkdir(snapshot_tmp_path) unless File.exist?(snapshot_tmp_path)

      command = utils_import_sql_file_command(snapshot_path, config, snapshot_output_path)
      File.delete(snapshot_output_path) if File.exist?(snapshot_output_path)

      `#{command}`

      puts "\n加载快照结果:"
      puts "- 执行命令: $ #{command.gsub(ENV['APP_ROOT_PATH'], '.')}"
      puts "- 输出日志: #{snapshot_output_path.gsub(ENV['APP_ROOT_PATH'], '.')}"
      if File.exist?(snapshot_output_path) 
        if File.readlines(snapshot_output_path).count > 1
          puts "- 日志明细:"
          puts File.readlines(snapshot_output_path)[1..-1].uniq.reject(&:empty?).map { |line| "\tmysql> #{line.strip}" }.join("\n")
        else
          puts "- 字段状态: 正常，无调整"
        end
      else
        puts "- 执行异常: 日志输出文档不存在"
      end

      # snapshot_without_output_sql, snapshot_with_output_sql = snapshot_sql.split("-- procedures")
      # snapshot_with_output_sql.scan(/^(call.*?;)$/).flatten.each do |procedure_sql|
      #   puts ActiveRecord::Base.connection.exec_query(procedure_sql).to_ary
      # end
    end
  end
end
