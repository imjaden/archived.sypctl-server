-- ------------------------------------------------
-- database snapshot
-- generated at: 19-03-21 23:12:39
--
-- host: 127.0.0.1
-- port: 3306
-- username: root
-- database: sypctl_pro
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


call syppro_create_table('sys_user_connections');
CREATE TABLE IF NOT EXISTS `sys_user_connections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT 'UUID',
  `user_group_uuid` varchar(255) NOT NULL COMMENT '分组 UUID',
  `user_uuid` varchar(255) DEFAULT NULL COMMENT '用户 UUID',
  `string` varchar(255) DEFAULT NULL COMMENT '用户 UUID',
  `user_type` varchar(255) DEFAULT 'user' COMMENT 'user/wx_user',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='微信用户表';

call syppro_create_table('sys_device_groups');
CREATE TABLE IF NOT EXISTS `sys_device_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL COMMENT '分组名称',
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `order_index` int(11) DEFAULT '0' COMMENT '排序序号',
  `publicly` tinyint(1) DEFAULT '0' COMMENT '该分组状态是否公开进入广场？',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='设备分组表';

call syppro_create_table('sys_wx_users');
CREATE TABLE IF NOT EXISTS `sys_wx_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT 'UUID',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '用户 UUID',
  `string` varchar(255) DEFAULT NULL COMMENT '用户 UUID',
  `session_key` varchar(255) DEFAULT NULL COMMENT 'session_key',
  `appid` varchar(255) DEFAULT NULL COMMENT 'APPID',
  `openid` varchar(255) DEFAULT NULL COMMENT 'OPENID',
  `avatar_url` varchar(255) DEFAULT NULL COMMENT '头像 URL',
  `group_name` varchar(255) DEFAULT NULL COMMENT '拉取群名称',
  `group_openid` varchar(255) DEFAULT NULL COMMENT '拉取群OPENID',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `nick_name` varchar(255) NOT NULL COMMENT '昵称',
  `gender` tinyint(1) DEFAULT NULL COMMENT '性别 0：未知、1：男、2：女',
  `province` varchar(255) DEFAULT NULL COMMENT 'province',
  `city` varchar(255) DEFAULT NULL COMMENT 'city',
  `country` varchar(255) DEFAULT NULL COMMENT 'country',
  `lang` varchar(255) DEFAULT NULL COMMENT 'lang',
  `mobile` varchar(255) DEFAULT NULL COMMENT '手机号',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='微信用户表';

call syppro_create_table('sys_backup_mysql_meta');
CREATE TABLE IF NOT EXISTS `sys_backup_mysql_meta` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT 'UUID',
  `device_name` varchar(255) NOT NULL COMMENT '设备名称',
  `device_uuid` varchar(255) NOT NULL COMMENT '设备 UUID',
  `ymd` varchar(255) NOT NULL COMMENT '日期 YY/MM/DD',
  `database_count` varchar(255) DEFAULT NULL COMMENT '实例中所有数据库数量',
  `backup_count` varchar(255) DEFAULT NULL COMMENT '实例中所有数据库数量',
  `backup_size` varchar(255) DEFAULT NULL COMMENT '数据库体积(共)',
  `backup_duration` varchar(255) DEFAULT NULL COMMENT '备份总耗时',
  `backup_state` varchar(255) DEFAULT NULL COMMENT '备份状态',
  `description` text COMMENT '描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='备份MySQL数据库元信息';

call syppro_create_table('sys_sms_records');
CREATE TABLE IF NOT EXISTS `sys_sms_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'UUID',
  `mobile` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '手机号',
  `message` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '短信内容',
  `state` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT 'todo' COMMENT '发送状态, default: todo',
  `sms_code` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '响应编号(阿里云)',
  `sms_message` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '响应编号(阿里云)',
  `sms_total_time` float DEFAULT NULL COMMENT '发送耗时',
  `sms_request_id` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '请求 ID(阿里云)',
  `sms_biz_id` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT 'BIZ ID(阿里云)',
  `creater_name` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '发送人名称',
  `creater_uuid` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '发送人uuid/mobile',
  `description` text COLLATE utf8_bin COMMENT '描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='发送短信记录表';

call syppro_create_table('sys_file_backups');
CREATE TABLE IF NOT EXISTS `sys_file_backups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT 'UUID',
  `file_path` varchar(255) NOT NULL COMMENT '文件路径',
  `description` varchar(255) DEFAULT NULL COMMENT ' 文件描述',
  `string` varchar(255) DEFAULT NULL COMMENT ' 文件描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='文件备份表';

call syppro_create_table('sys_records');
CREATE TABLE IF NOT EXISTS `sys_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL COMMENT '设备 UUID',
  `api_token` varchar(255) DEFAULT NULL COMMENT '应用 ID',
  `version` varchar(255) DEFAULT NULL COMMENT '代理版本',
  `memory_usage` varchar(255) DEFAULT NULL COMMENT '内存使用情况',
  `memory_usage_description` text COMMENT '内存使用情况JSON',
  `cpu_usage` varchar(255) DEFAULT NULL COMMENT 'CPU  使用情况',
  `cpu_usage_description` text COMMENT 'CPU  使用情况描述JSON',
  `disk_usage` varchar(255) DEFAULT NULL COMMENT '磁盘使用情况',
  `disk_usage_description` text COMMENT '磁盘使用情况JSON',
  `description` text COMMENT '请求描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `whoami` varchar(255) DEFAULT NULL COMMENT '代理运行账号',
  `request_ip` varchar(255) DEFAULT NULL,
  `request_agent` varchar(255) DEFAULT NULL COMMENT '代理版本信息',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='代理请求记录表';

call syppro_create_table('sys_apps');
CREATE TABLE IF NOT EXISTS `sys_apps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) DEFAULT NULL COMMENT '所属用户分组 ID',
  `app_group_id` int(11) DEFAULT NULL COMMENT '所属应用分组 ID',
  `name` varchar(255) NOT NULL COMMENT '应用名称',
  `file_type` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL COMMENT '应用类型',
  `description` text COMMENT '应用描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `latest_version` varchar(255) DEFAULT NULL,
  `latest_version_id` varchar(255) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `latest_build` int(11) DEFAULT NULL,
  `version_count` int(11) DEFAULT '0',
  `file_path` varchar(255) NOT NULL,
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  `latest_version_uuid` varchar(255) DEFAULT NULL COMMENT '版本 UUID',
  `app_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '用户 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='应用表';

call syppro_create_table('sys_backup_mysql_day');
CREATE TABLE IF NOT EXISTS `sys_backup_mysql_day` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT 'UUID',
  `device_name` varchar(255) NOT NULL COMMENT '设备名称',
  `device_uuid` varchar(255) NOT NULL COMMENT '设备 UUID',
  `ymd` varchar(255) NOT NULL COMMENT '日期 YY/MM/DD',
  `host` varchar(255) DEFAULT NULL COMMENT 'ip',
  `port` varchar(255) DEFAULT NULL COMMENT 'port',
  `database_name` varchar(255) DEFAULT NULL COMMENT '数据库数量',
  `backup_name` varchar(255) DEFAULT NULL COMMENT '备份文件',
  `backup_size` varchar(255) DEFAULT NULL COMMENT '备份体积(压缩)',
  `backup_md5` varchar(255) DEFAULT NULL COMMENT '备份文件MD5',
  `backup_time` varchar(255) DEFAULT NULL COMMENT '备份执行时间',
  `backup_duration` varchar(255) DEFAULT NULL COMMENT '备份耗时',
  `backup_state` varchar(255) DEFAULT NULL COMMENT '备份路径',
  `description` text COMMENT '描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='每日备份MySQL数据库';

call syppro_create_table('sys_app_groups');
CREATE TABLE IF NOT EXISTS `sys_app_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL COMMENT '分组名称',
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='应用分组表';

call syppro_create_table('sys_agent_behavior_logs');
CREATE TABLE IF NOT EXISTS `sys_agent_behavior_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8_bin NOT NULL COMMENT 'UUID',
  `device_name` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '设备名称',
  `device_uuid` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '设备 UUID',
  `behavior` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '行为描述',
  `object_type` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '行为对象类型',
  `object_id` varchar(255) COLLATE utf8_bin NOT NULL COMMENT '行为对象标识',
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '描述',
  `string` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='代理端行为记录';

call syppro_create_table('sys_job_groups');
CREATE TABLE IF NOT EXISTS `sys_job_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) DEFAULT NULL COMMENT '所属用户分组 ID',
  `uuid` varchar(255) NOT NULL COMMENT '任务组 UUID',
  `title` varchar(255) NOT NULL COMMENT '任务组标题',
  `description` text COMMENT '任务组描述',
  `app_id` varchar(255) DEFAULT NULL COMMENT '应用 ID',
  `app_name` varchar(255) DEFAULT NULL COMMENT '应用名称',
  `version_id` varchar(255) DEFAULT NULL COMMENT '版本 ID',
  `version_name` varchar(255) DEFAULT NULL COMMENT '版本名称',
  `device_count` int(11) DEFAULT '1' COMMENT '设备数量',
  `command` text COMMENT '部署脚本',
  `state` varchar(255) DEFAULT 'waiting' COMMENT '部署进度',
  `executed_at` varchar(255) DEFAULT NULL COMMENT '执行时间，支持定时任务',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='任务组表';

call syppro_create_table('sys_jobs');
CREATE TABLE IF NOT EXISTS `sys_jobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT '任务 UUID',
  `title` varchar(255) NOT NULL COMMENT '任务标题',
  `description` text COMMENT '任务描述',
  `app_id` varchar(255) DEFAULT NULL COMMENT '应用 ID',
  `app_name` varchar(255) DEFAULT NULL COMMENT '应用名称',
  `version_id` varchar(255) DEFAULT NULL COMMENT '版本 ID',
  `version_name` varchar(255) DEFAULT NULL COMMENT '版本名称',
  `device_uuid` varchar(255) DEFAULT NULL COMMENT '设备 UUID',
  `device_name` varchar(255) DEFAULT NULL COMMENT '设备名称',
  `command` text COMMENT '部署脚本',
  `output` text COMMENT '脚本输出',
  `state` varchar(255) DEFAULT 'waiting' COMMENT '部署进度',
  `executed_at` varchar(255) DEFAULT NULL COMMENT '执行时间，支持定时任务',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_group_id` int(11) DEFAULT NULL COMMENT '所属用户分组 ID',
  `job_group_uuid` varchar(255) NOT NULL COMMENT '任务组 UUID',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='任务表';

call syppro_create_table('sys_devices');
CREATE TABLE IF NOT EXISTS `sys_devices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) DEFAULT NULL,
  `human_name` varchar(255) DEFAULT NULL COMMENT '业务名称',
  `hostname` varchar(255) DEFAULT NULL,
  `ssh_username` varchar(255) DEFAULT NULL COMMENT 'SSH 登录用户',
  `ssh_password` varchar(255) DEFAULT NULL COMMENT 'SSH 登录密码',
  `ssh_port` varchar(255) DEFAULT NULL COMMENT 'SSH 端口',
  `ssh_state` tinyint(1) DEFAULT '0' COMMENT 'SSH 连接状态',
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `os_type` varchar(255) DEFAULT NULL COMMENT '系统类型',
  `os_version` varchar(255) DEFAULT NULL COMMENT '系统版本',
  `api_token` varchar(255) DEFAULT NULL COMMENT 'API Token',
  `memory` varchar(255) DEFAULT NULL COMMENT '内存大小',
  `memory_description` text COMMENT '内存大小描述JSON',
  `cpu` varchar(255) DEFAULT NULL COMMENT 'CPU 核数',
  `cpu_description` text COMMENT 'CPU 描述JSON',
  `disk` varchar(255) DEFAULT NULL COMMENT '磁盘大小',
  `disk_description` text COMMENT '磁盘JSON',
  `lan_ip` varchar(255) DEFAULT NULL COMMENT '内网 IP',
  `wan_ip` varchar(255) DEFAULT NULL COMMENT '外网 IP',
  `record_count` int(11) DEFAULT '0' COMMENT '记录数量',
  `description` text COMMENT '设备服务器描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `ssh_ip` varchar(255) DEFAULT NULL,
  `user_group_id` int(11) DEFAULT NULL COMMENT '所属用户分组 ID',
  `device_group_id` int(11) DEFAULT NULL COMMENT '所属设备分组 ID',
  `order_index` int(11) DEFAULT '0',
  `request_ip` varchar(255) DEFAULT NULL,
  `request_agent` varchar(255) DEFAULT NULL COMMENT '代理版本信息',
  `monitor_state` tinyint(1) DEFAULT '0' COMMENT '是否监控',
  `service_state` tinyint(1) DEFAULT '0' COMMENT '服务列表配置状态',
  `service_monitor` text COMMENT '服务运行状态',
  `service_count` int(11) DEFAULT '0' COMMENT '服务列表数量',
  `service_stopped_count` int(11) DEFAULT '0' COMMENT '服务未运行数量',
  `device_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  `file_backup_list` text COMMENT '文件备份列表，JSON 格式',
  `service_config` text COMMENT '服务列表配置 JSON',
  `service_updated_at` varchar(255) DEFAULT NULL COMMENT '提交更新时间',
  `file_backup_config` text COMMENT '文件备份列表，JSON 格式',
  `file_backup_monitor` text COMMENT '文件备份列表执行结果',
  `file_backup_updated_at` varchar(255) DEFAULT NULL COMMENT '提交更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='设备服务器表';

call syppro_create_table('sys_versions');
CREATE TABLE IF NOT EXISTS `sys_versions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_id` int(11) NOT NULL COMMENT '应用 ID',
  `version` varchar(255) NOT NULL COMMENT '版本号',
  `build` int(11) NOT NULL COMMENT '版本 build 值',
  `file_size` varchar(255) DEFAULT NULL COMMENT '应用体积',
  `md5` varchar(255) DEFAULT NULL COMMENT '文件 MD5 值',
  `cdn_link` varchar(255) DEFAULT NULL COMMENT 'CDN 链接',
  `description` text COMMENT '版本描述',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `cdn_state` varchar(255) DEFAULT '无任务',
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  `app_uuid` varchar(255) DEFAULT NULL COMMENT '应用 UUID',
  `origin_name` varchar(255) DEFAULT NULL COMMENT '文件原名称',
  `origin_file_name` varchar(255) DEFAULT NULL COMMENT '文件原名称',
  `origin_md5` varchar(255) DEFAULT NULL COMMENT '文件原哈希值',
  `file_path` varchar(255) DEFAULT NULL COMMENT '文件存储路径',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='应用版本表';

call syppro_create_table('sys_operation_logs');
CREATE TABLE IF NOT EXISTS `sys_operation_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `operator` varchar(255) NOT NULL COMMENT '操作者',
  `description` text COMMENT '行为描述',
  `template` varchar(255) DEFAULT NULL COMMENT '模板',
  `objects` varchar(255) DEFAULT NULL COMMENT '对象',
  `tags` varchar(255) DEFAULT NULL COMMENT '标签',
  `ip` varchar(255) DEFAULT NULL COMMENT '请求 IP',
  `browser` text COMMENT '操作浏览器',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='行为日志记录';

call syppro_create_table('sys_job_templates');
CREATE TABLE IF NOT EXISTS `sys_job_templates` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_group_id` int(11) DEFAULT NULL COMMENT '所属用户分组 ID',
  `uuid` varchar(255) NOT NULL COMMENT '模板 UUID',
  `title` varchar(255) NOT NULL COMMENT '模板标题',
  `description` text COMMENT '任务描述',
  `content` text COMMENT '任务模板',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_group_uuid` varchar(255) DEFAULT NULL COMMENT '分组 UUID',
  `template_type` varchar(255) NOT NULL DEFAULT 'script' COMMENT '模板类型',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='任务模板表';

call syppro_create_table('sys_user_groups');
CREATE TABLE IF NOT EXISTS `sys_user_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '分组名称',
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='用户分组表';

call syppro_create_table('sys_services');
CREATE TABLE IF NOT EXISTS `sys_services` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL COMMENT '设备 UUID',
  `hostname` varchar(255) NOT NULL COMMENT '主机名称',
  `config` text COMMENT 'JSON 配置档',
  `monitor` text COMMENT 'JSON 运行状态',
  `total_count` int(11) DEFAULT NULL COMMENT '服务列表数量',
  `stopped_count` int(11) DEFAULT NULL COMMENT '未运行服务数量',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `device_uuid` varchar(255) DEFAULT NULL COMMENT '设备 UUID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='服务配置档';

call syppro_create_table('sys_users');
CREATE TABLE IF NOT EXISTS `sys_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) NOT NULL,
  `user_num` varchar(50) NOT NULL,
  `user_pass` varchar(50) NOT NULL,
  `email` varchar(22) DEFAULT '',
  `mobile` varchar(18) DEFAULT '',
  `tel` varchar(16) DEFAULT '',
  `join_date` datetime DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `dept_id` int(11) DEFAULT NULL,
  `dept_name` varchar(50) DEFAULT NULL,
  `active_flag` int(11) DEFAULT '1',
  `create_user` int(11) DEFAULT NULL,
  `update_user` int(11) DEFAULT NULL,
  `memo` varchar(300) DEFAULT NULL,
  `load_time` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `last_login_at` datetime DEFAULT '2016-01-15 06:19:44',
  `last_login_ip` varchar(255) DEFAULT '',
  `last_login_browser` varchar(255) DEFAULT '',
  `sign_in_count` int(11) DEFAULT '0',
  `last_login_version` varchar(255) DEFAULT '',
  `access_token` varchar(255) DEFAULT '',
  `coordinate` varchar(255) DEFAULT NULL,
  `coordinate_location` varchar(255) DEFAULT NULL,
  `store_ids` text,
  `uuid` varchar(255) DEFAULT NULL COMMENT 'UUID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sys_users_on_user_num` (`user_num`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='用户表';
-- procedures
call syppro_add_column('sys_user_connections', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_user_connections', 'uuid', 'varchar(255) NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_user_connections', 'user_group_uuid', 'varchar(255) NOT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_user_connections', 'user_uuid', 'varchar(255) DEFAULT NULL COMMENT "用户 UUID"');
call syppro_add_column('sys_user_connections', 'string', 'varchar(255) DEFAULT NULL COMMENT "用户 UUID"');
call syppro_add_column('sys_user_connections', 'user_type', 'varchar(255) DEFAULT "user" COMMENT "user/wx_user"');
call syppro_add_column('sys_user_connections', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_user_connections', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_device_groups', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_device_groups', 'user_group_id', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_device_groups', 'name', 'varchar(255) NOT NULL COMMENT "分组名称"');
call syppro_add_column('sys_device_groups', 'description', 'text');
call syppro_add_column('sys_device_groups', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_device_groups', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_device_groups', 'uuid', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_device_groups', 'order_index', 'int(11) DEFAULT "0" COMMENT "排序序号"');
call syppro_add_column('sys_device_groups', 'publicly', 'tinyint(1) DEFAULT "0" COMMENT "该分组状态是否公开进入广场？"');
call syppro_add_column('sys_device_groups', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_wx_users', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_wx_users', 'uuid', 'varchar(255) NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_wx_users', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "用户 UUID"');
call syppro_add_column('sys_wx_users', 'string', 'varchar(255) DEFAULT NULL COMMENT "用户 UUID"');
call syppro_add_column('sys_wx_users', 'session_key', 'varchar(255) DEFAULT NULL COMMENT "session_key"');
call syppro_add_column('sys_wx_users', 'appid', 'varchar(255) DEFAULT NULL COMMENT "APPID"');
call syppro_add_column('sys_wx_users', 'openid', 'varchar(255) DEFAULT NULL COMMENT "OPENID"');
call syppro_add_column('sys_wx_users', 'avatar_url', 'varchar(255) DEFAULT NULL COMMENT "头像 URL"');
call syppro_add_column('sys_wx_users', 'group_name', 'varchar(255) DEFAULT NULL COMMENT "拉取群名称"');
call syppro_add_column('sys_wx_users', 'group_openid', 'varchar(255) DEFAULT NULL COMMENT "拉取群OPENID"');
call syppro_add_column('sys_wx_users', 'name', 'varchar(255) NOT NULL COMMENT "名称"');
call syppro_add_column('sys_wx_users', 'nick_name', 'varchar(255) NOT NULL COMMENT "昵称"');
call syppro_add_column('sys_wx_users', 'gender', 'tinyint(1) DEFAULT NULL COMMENT "性别 0：未知、1：男、2：女"');
call syppro_add_column('sys_wx_users', 'province', 'varchar(255) DEFAULT NULL COMMENT "province"');
call syppro_add_column('sys_wx_users', 'city', 'varchar(255) DEFAULT NULL COMMENT "city"');
call syppro_add_column('sys_wx_users', 'country', 'varchar(255) DEFAULT NULL COMMENT "country"');
call syppro_add_column('sys_wx_users', 'lang', 'varchar(255) DEFAULT NULL COMMENT "lang"');
call syppro_add_column('sys_wx_users', 'mobile', 'varchar(255) DEFAULT NULL COMMENT "手机号"');
call syppro_add_column('sys_wx_users', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_wx_users', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_backup_mysql_meta', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_backup_mysql_meta', 'uuid', 'varchar(255) NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_backup_mysql_meta', 'device_name', 'varchar(255) NOT NULL COMMENT "设备名称"');
call syppro_add_column('sys_backup_mysql_meta', 'device_uuid', 'varchar(255) NOT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_backup_mysql_meta', 'ymd', 'varchar(255) NOT NULL COMMENT "日期 YY/MM/DD"');
call syppro_add_column('sys_backup_mysql_meta', 'database_count', 'varchar(255) DEFAULT NULL COMMENT "实例中所有数据库数量"');
call syppro_add_column('sys_backup_mysql_meta', 'backup_count', 'varchar(255) DEFAULT NULL COMMENT "实例中所有数据库数量"');
call syppro_add_column('sys_backup_mysql_meta', 'backup_size', 'varchar(255) DEFAULT NULL COMMENT "数据库体积(共)"');
call syppro_add_column('sys_backup_mysql_meta', 'backup_duration', 'varchar(255) DEFAULT NULL COMMENT "备份总耗时"');
call syppro_add_column('sys_backup_mysql_meta', 'backup_state', 'varchar(255) DEFAULT NULL COMMENT "备份状态"');
call syppro_add_column('sys_backup_mysql_meta', 'description', 'text COMMENT "描述"');
call syppro_add_column('sys_backup_mysql_meta', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_backup_mysql_meta', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_sms_records', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_sms_records', 'uuid', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_sms_records', 'mobile', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "手机号"');
call syppro_add_column('sys_sms_records', 'message', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "短信内容"');
call syppro_add_column('sys_sms_records', 'state', 'varchar(255) COLLATE utf8_bin NOT NULL DEFAULT "todo" COMMENT "发送状态, default: todo"');
call syppro_add_column('sys_sms_records', 'sms_code', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "响应编号(阿里云)"');
call syppro_add_column('sys_sms_records', 'sms_message', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "响应编号(阿里云)"');
call syppro_add_column('sys_sms_records', 'sms_total_time', 'float DEFAULT NULL COMMENT "发送耗时"');
call syppro_add_column('sys_sms_records', 'sms_request_id', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "请求 ID(阿里云)"');
call syppro_add_column('sys_sms_records', 'sms_biz_id', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "BIZ ID(阿里云)"');
call syppro_add_column('sys_sms_records', 'creater_name', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "发送人名称"');
call syppro_add_column('sys_sms_records', 'creater_uuid', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "发送人uuid/mobile"');
call syppro_add_column('sys_sms_records', 'description', 'text COLLATE utf8_bin COMMENT "描述"');
call syppro_add_column('sys_sms_records', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_sms_records', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_file_backups', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_file_backups', 'uuid', 'varchar(255) NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_file_backups', 'file_path', 'varchar(255) NOT NULL COMMENT "文件路径"');
call syppro_add_column('sys_file_backups', 'description', 'varchar(255) DEFAULT NULL COMMENT " 文件描述"');
call syppro_add_column('sys_file_backups', 'string', 'varchar(255) DEFAULT NULL COMMENT " 文件描述"');
call syppro_add_column('sys_file_backups', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_file_backups', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_records', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_records', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_records', 'api_token', 'varchar(255) DEFAULT NULL COMMENT "应用 ID"');
call syppro_add_column('sys_records', 'version', 'varchar(255) DEFAULT NULL COMMENT "代理版本"');
call syppro_add_column('sys_records', 'memory_usage', 'varchar(255) DEFAULT NULL COMMENT "内存使用情况"');
call syppro_add_column('sys_records', 'memory_usage_description', 'text COMMENT "内存使用情况JSON"');
call syppro_add_column('sys_records', 'cpu_usage', 'varchar(255) DEFAULT NULL COMMENT "CPU  使用情况"');
call syppro_add_column('sys_records', 'cpu_usage_description', 'text COMMENT "CPU  使用情况描述JSON"');
call syppro_add_column('sys_records', 'disk_usage', 'varchar(255) DEFAULT NULL COMMENT "磁盘使用情况"');
call syppro_add_column('sys_records', 'disk_usage_description', 'text COMMENT "磁盘使用情况JSON"');
call syppro_add_column('sys_records', 'description', 'text COMMENT "请求描述"');
call syppro_add_column('sys_records', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_records', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_records', 'whoami', 'varchar(255) DEFAULT NULL COMMENT "代理运行账号"');
call syppro_add_column('sys_records', 'request_ip', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_records', 'request_agent', 'varchar(255) DEFAULT NULL COMMENT "代理版本信息"');
call syppro_add_column('sys_apps', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_apps', 'user_group_id', 'int(11) DEFAULT NULL COMMENT "所属用户分组 ID"');
call syppro_add_column('sys_apps', 'app_group_id', 'int(11) DEFAULT NULL COMMENT "所属应用分组 ID"');
call syppro_add_column('sys_apps', 'name', 'varchar(255) NOT NULL COMMENT "应用名称"');
call syppro_add_column('sys_apps', 'file_type', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_apps', 'category', 'varchar(255) DEFAULT NULL COMMENT "应用类型"');
call syppro_add_column('sys_apps', 'description', 'text COMMENT "应用描述"');
call syppro_add_column('sys_apps', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_apps', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_apps', 'latest_version', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_apps', 'latest_version_id', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_apps', 'file_name', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_apps', 'latest_build', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_apps', 'version_count', 'int(11) DEFAULT "0"');
call syppro_add_column('sys_apps', 'file_path', 'varchar(255) NOT NULL');
call syppro_add_column('sys_apps', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');
call syppro_add_column('sys_apps', 'latest_version_uuid', 'varchar(255) DEFAULT NULL COMMENT "版本 UUID"');
call syppro_add_column('sys_apps', 'app_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_apps', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "用户 UUID"');
call syppro_add_column('sys_backup_mysql_day', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_backup_mysql_day', 'uuid', 'varchar(255) NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_backup_mysql_day', 'device_name', 'varchar(255) NOT NULL COMMENT "设备名称"');
call syppro_add_column('sys_backup_mysql_day', 'device_uuid', 'varchar(255) NOT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_backup_mysql_day', 'ymd', 'varchar(255) NOT NULL COMMENT "日期 YY/MM/DD"');
call syppro_add_column('sys_backup_mysql_day', 'host', 'varchar(255) DEFAULT NULL COMMENT "ip"');
call syppro_add_column('sys_backup_mysql_day', 'port', 'varchar(255) DEFAULT NULL COMMENT "port"');
call syppro_add_column('sys_backup_mysql_day', 'database_name', 'varchar(255) DEFAULT NULL COMMENT "数据库数量"');
call syppro_add_column('sys_backup_mysql_day', 'backup_name', 'varchar(255) DEFAULT NULL COMMENT "备份文件"');
call syppro_add_column('sys_backup_mysql_day', 'backup_size', 'varchar(255) DEFAULT NULL COMMENT "备份体积(压缩)"');
call syppro_add_column('sys_backup_mysql_day', 'backup_md5', 'varchar(255) DEFAULT NULL COMMENT "备份文件MD5"');
call syppro_add_column('sys_backup_mysql_day', 'backup_time', 'varchar(255) DEFAULT NULL COMMENT "备份执行时间"');
call syppro_add_column('sys_backup_mysql_day', 'backup_duration', 'varchar(255) DEFAULT NULL COMMENT "备份耗时"');
call syppro_add_column('sys_backup_mysql_day', 'backup_state', 'varchar(255) DEFAULT NULL COMMENT "备份路径"');
call syppro_add_column('sys_backup_mysql_day', 'description', 'text COMMENT "描述"');
call syppro_add_column('sys_backup_mysql_day', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_backup_mysql_day', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_app_groups', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_app_groups', 'user_group_id', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_app_groups', 'name', 'varchar(255) NOT NULL COMMENT "分组名称"');
call syppro_add_column('sys_app_groups', 'description', 'text');
call syppro_add_column('sys_app_groups', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_app_groups', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_app_groups', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');
call syppro_add_column('sys_app_groups', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_agent_behavior_logs', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_agent_behavior_logs', 'uuid', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "UUID"');
call syppro_add_column('sys_agent_behavior_logs', 'device_name', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "设备名称"');
call syppro_add_column('sys_agent_behavior_logs', 'device_uuid', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_agent_behavior_logs', 'behavior', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "行为描述"');
call syppro_add_column('sys_agent_behavior_logs', 'object_type', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "行为对象类型"');
call syppro_add_column('sys_agent_behavior_logs', 'object_id', 'varchar(255) COLLATE utf8_bin NOT NULL COMMENT "行为对象标识"');
call syppro_add_column('sys_agent_behavior_logs', 'description', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "描述"');
call syppro_add_column('sys_agent_behavior_logs', 'string', 'varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT "描述"');
call syppro_add_column('sys_agent_behavior_logs', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_agent_behavior_logs', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_job_groups', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_job_groups', 'user_group_id', 'int(11) DEFAULT NULL COMMENT "所属用户分组 ID"');
call syppro_add_column('sys_job_groups', 'uuid', 'varchar(255) NOT NULL COMMENT "任务组 UUID"');
call syppro_add_column('sys_job_groups', 'title', 'varchar(255) NOT NULL COMMENT "任务组标题"');
call syppro_add_column('sys_job_groups', 'description', 'text COMMENT "任务组描述"');
call syppro_add_column('sys_job_groups', 'app_id', 'varchar(255) DEFAULT NULL COMMENT "应用 ID"');
call syppro_add_column('sys_job_groups', 'app_name', 'varchar(255) DEFAULT NULL COMMENT "应用名称"');
call syppro_add_column('sys_job_groups', 'version_id', 'varchar(255) DEFAULT NULL COMMENT "版本 ID"');
call syppro_add_column('sys_job_groups', 'version_name', 'varchar(255) DEFAULT NULL COMMENT "版本名称"');
call syppro_add_column('sys_job_groups', 'device_count', 'int(11) DEFAULT "1" COMMENT "设备数量"');
call syppro_add_column('sys_job_groups', 'command', 'text COMMENT "部署脚本"');
call syppro_add_column('sys_job_groups', 'state', 'varchar(255) DEFAULT "waiting" COMMENT "部署进度"');
call syppro_add_column('sys_job_groups', 'executed_at', 'varchar(255) DEFAULT NULL COMMENT "执行时间，支持定时任务"');
call syppro_add_column('sys_job_groups', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_job_groups', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_job_groups', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_jobs', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_jobs', 'uuid', 'varchar(255) NOT NULL COMMENT "任务 UUID"');
call syppro_add_column('sys_jobs', 'title', 'varchar(255) NOT NULL COMMENT "任务标题"');
call syppro_add_column('sys_jobs', 'description', 'text COMMENT "任务描述"');
call syppro_add_column('sys_jobs', 'app_id', 'varchar(255) DEFAULT NULL COMMENT "应用 ID"');
call syppro_add_column('sys_jobs', 'app_name', 'varchar(255) DEFAULT NULL COMMENT "应用名称"');
call syppro_add_column('sys_jobs', 'version_id', 'varchar(255) DEFAULT NULL COMMENT "版本 ID"');
call syppro_add_column('sys_jobs', 'version_name', 'varchar(255) DEFAULT NULL COMMENT "版本名称"');
call syppro_add_column('sys_jobs', 'device_uuid', 'varchar(255) DEFAULT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_jobs', 'device_name', 'varchar(255) DEFAULT NULL COMMENT "设备名称"');
call syppro_add_column('sys_jobs', 'command', 'text COMMENT "部署脚本"');
call syppro_add_column('sys_jobs', 'output', 'text COMMENT "脚本输出"');
call syppro_add_column('sys_jobs', 'state', 'varchar(255) DEFAULT "waiting" COMMENT "部署进度"');
call syppro_add_column('sys_jobs', 'executed_at', 'varchar(255) DEFAULT NULL COMMENT "执行时间，支持定时任务"');
call syppro_add_column('sys_jobs', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_jobs', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_jobs', 'user_group_id', 'int(11) DEFAULT NULL COMMENT "所属用户分组 ID"');
call syppro_add_column('sys_jobs', 'job_group_uuid', 'varchar(255) NOT NULL COMMENT "任务组 UUID"');
call syppro_add_column('sys_jobs', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_devices', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_devices', 'uuid', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'human_name', 'varchar(255) DEFAULT NULL COMMENT "业务名称"');
call syppro_add_column('sys_devices', 'hostname', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'ssh_username', 'varchar(255) DEFAULT NULL COMMENT "SSH 登录用户"');
call syppro_add_column('sys_devices', 'ssh_password', 'varchar(255) DEFAULT NULL COMMENT "SSH 登录密码"');
call syppro_add_column('sys_devices', 'ssh_port', 'varchar(255) DEFAULT NULL COMMENT "SSH 端口"');
call syppro_add_column('sys_devices', 'ssh_state', 'tinyint(1) DEFAULT "0" COMMENT "SSH 连接状态"');
call syppro_add_column('sys_devices', 'username', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'password', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'os_type', 'varchar(255) DEFAULT NULL COMMENT "系统类型"');
call syppro_add_column('sys_devices', 'os_version', 'varchar(255) DEFAULT NULL COMMENT "系统版本"');
call syppro_add_column('sys_devices', 'api_token', 'varchar(255) DEFAULT NULL COMMENT "API Token"');
call syppro_add_column('sys_devices', 'memory', 'varchar(255) DEFAULT NULL COMMENT "内存大小"');
call syppro_add_column('sys_devices', 'memory_description', 'text COMMENT "内存大小描述JSON"');
call syppro_add_column('sys_devices', 'cpu', 'varchar(255) DEFAULT NULL COMMENT "CPU 核数"');
call syppro_add_column('sys_devices', 'cpu_description', 'text COMMENT "CPU 描述JSON"');
call syppro_add_column('sys_devices', 'disk', 'varchar(255) DEFAULT NULL COMMENT "磁盘大小"');
call syppro_add_column('sys_devices', 'disk_description', 'text COMMENT "磁盘JSON"');
call syppro_add_column('sys_devices', 'lan_ip', 'varchar(255) DEFAULT NULL COMMENT "内网 IP"');
call syppro_add_column('sys_devices', 'wan_ip', 'varchar(255) DEFAULT NULL COMMENT "外网 IP"');
call syppro_add_column('sys_devices', 'record_count', 'int(11) DEFAULT "0" COMMENT "记录数量"');
call syppro_add_column('sys_devices', 'description', 'text COMMENT "设备服务器描述"');
call syppro_add_column('sys_devices', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_devices', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_devices', 'ssh_ip', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'user_group_id', 'int(11) DEFAULT NULL COMMENT "所属用户分组 ID"');
call syppro_add_column('sys_devices', 'device_group_id', 'int(11) DEFAULT NULL COMMENT "所属设备分组 ID"');
call syppro_add_column('sys_devices', 'order_index', 'int(11) DEFAULT "0"');
call syppro_add_column('sys_devices', 'request_ip', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_devices', 'request_agent', 'varchar(255) DEFAULT NULL COMMENT "代理版本信息"');
call syppro_add_column('sys_devices', 'monitor_state', 'tinyint(1) DEFAULT "0" COMMENT "是否监控"');
call syppro_add_column('sys_devices', 'service_state', 'tinyint(1) DEFAULT "0" COMMENT "服务列表配置状态"');
call syppro_add_column('sys_devices', 'service_monitor', 'text COMMENT "服务运行状态"');
call syppro_add_column('sys_devices', 'service_count', 'int(11) DEFAULT "0" COMMENT "服务列表数量"');
call syppro_add_column('sys_devices', 'service_stopped_count', 'int(11) DEFAULT "0" COMMENT "服务未运行数量"');
call syppro_add_column('sys_devices', 'device_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_devices', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_devices', 'file_backup_list', 'text COMMENT "文件备份列表，JSON 格式"');
call syppro_add_column('sys_devices', 'service_config', 'text COMMENT "服务列表配置 JSON"');
call syppro_add_column('sys_devices', 'service_updated_at', 'varchar(255) DEFAULT NULL COMMENT "提交更新时间"');
call syppro_add_column('sys_devices', 'file_backup_config', 'text COMMENT "文件备份列表，JSON 格式"');
call syppro_add_column('sys_devices', 'file_backup_monitor', 'text COMMENT "文件备份列表执行结果"');
call syppro_add_column('sys_devices', 'file_backup_updated_at', 'varchar(255) DEFAULT NULL COMMENT "提交更新时间"');
call syppro_add_column('sys_versions', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_versions', 'app_id', 'int(11) NOT NULL COMMENT "应用 ID"');
call syppro_add_column('sys_versions', 'version', 'varchar(255) NOT NULL COMMENT "版本号"');
call syppro_add_column('sys_versions', 'build', 'int(11) NOT NULL COMMENT "版本 build 值"');
call syppro_add_column('sys_versions', 'file_size', 'varchar(255) DEFAULT NULL COMMENT "应用体积"');
call syppro_add_column('sys_versions', 'md5', 'varchar(255) DEFAULT NULL COMMENT "文件 MD5 值"');
call syppro_add_column('sys_versions', 'cdn_link', 'varchar(255) DEFAULT NULL COMMENT "CDN 链接"');
call syppro_add_column('sys_versions', 'description', 'text COMMENT "版本描述"');
call syppro_add_column('sys_versions', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_versions', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_versions', 'file_name', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_versions', 'cdn_state', 'varchar(255) DEFAULT "无任务"');
call syppro_add_column('sys_versions', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');
call syppro_add_column('sys_versions', 'app_uuid', 'varchar(255) DEFAULT NULL COMMENT "应用 UUID"');
call syppro_add_column('sys_versions', 'origin_name', 'varchar(255) DEFAULT NULL COMMENT "文件原名称"');
call syppro_add_column('sys_versions', 'origin_file_name', 'varchar(255) DEFAULT NULL COMMENT "文件原名称"');
call syppro_add_column('sys_versions', 'origin_md5', 'varchar(255) DEFAULT NULL COMMENT "文件原哈希值"');
call syppro_add_column('sys_versions', 'file_path', 'varchar(255) DEFAULT NULL COMMENT "文件存储路径"');
call syppro_add_column('sys_operation_logs', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_operation_logs', 'operator', 'varchar(255) NOT NULL COMMENT "操作者"');
call syppro_add_column('sys_operation_logs', 'description', 'text COMMENT "行为描述"');
call syppro_add_column('sys_operation_logs', 'template', 'varchar(255) DEFAULT NULL COMMENT "模板"');
call syppro_add_column('sys_operation_logs', 'objects', 'varchar(255) DEFAULT NULL COMMENT "对象"');
call syppro_add_column('sys_operation_logs', 'tags', 'varchar(255) DEFAULT NULL COMMENT "标签"');
call syppro_add_column('sys_operation_logs', 'ip', 'varchar(255) DEFAULT NULL COMMENT "请求 IP"');
call syppro_add_column('sys_operation_logs', 'browser', 'text COMMENT "操作浏览器"');
call syppro_add_column('sys_operation_logs', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_operation_logs', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_operation_logs', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');
call syppro_add_column('sys_job_templates', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_job_templates', 'user_group_id', 'int(11) DEFAULT NULL COMMENT "所属用户分组 ID"');
call syppro_add_column('sys_job_templates', 'uuid', 'varchar(255) NOT NULL COMMENT "模板 UUID"');
call syppro_add_column('sys_job_templates', 'title', 'varchar(255) NOT NULL COMMENT "模板标题"');
call syppro_add_column('sys_job_templates', 'description', 'text COMMENT "任务描述"');
call syppro_add_column('sys_job_templates', 'content', 'text COMMENT "任务模板"');
call syppro_add_column('sys_job_templates', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_job_templates', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_job_templates', 'user_group_uuid', 'varchar(255) DEFAULT NULL COMMENT "分组 UUID"');
call syppro_add_column('sys_job_templates', 'template_type', 'varchar(255) NOT NULL DEFAULT "script" COMMENT "模板类型"');
call syppro_add_column('sys_user_groups', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_user_groups', 'name', 'varchar(255) NOT NULL COMMENT "分组名称"');
call syppro_add_column('sys_user_groups', 'description', 'text');
call syppro_add_column('sys_user_groups', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_user_groups', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_user_groups', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');
call syppro_add_column('sys_services', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_services', 'uuid', 'varchar(255) NOT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_services', 'hostname', 'varchar(255) NOT NULL COMMENT "主机名称"');
call syppro_add_column('sys_services', 'config', 'text COMMENT "JSON 配置档"');
call syppro_add_column('sys_services', 'monitor', 'text COMMENT "JSON 运行状态"');
call syppro_add_column('sys_services', 'total_count', 'int(11) DEFAULT NULL COMMENT "服务列表数量"');
call syppro_add_column('sys_services', 'stopped_count', 'int(11) DEFAULT NULL COMMENT "未运行服务数量"');
call syppro_add_column('sys_services', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_services', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_services', 'device_uuid', 'varchar(255) DEFAULT NULL COMMENT "设备 UUID"');
call syppro_add_column('sys_users', 'id', 'bigint(20) NOT NULL AUTO_INCREMENT');
call syppro_add_column('sys_users', 'user_name', 'varchar(50) NOT NULL');
call syppro_add_column('sys_users', 'user_num', 'varchar(50) NOT NULL');
call syppro_add_column('sys_users', 'user_pass', 'varchar(50) NOT NULL');
call syppro_add_column('sys_users', 'email', 'varchar(22) DEFAULT ""');
call syppro_add_column('sys_users', 'mobile', 'varchar(18) DEFAULT ""');
call syppro_add_column('sys_users', 'tel', 'varchar(16) DEFAULT ""');
call syppro_add_column('sys_users', 'join_date', 'datetime DEFAULT NULL');
call syppro_add_column('sys_users', 'position', 'varchar(50) DEFAULT NULL');
call syppro_add_column('sys_users', 'dept_id', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_users', 'dept_name', 'varchar(50) DEFAULT NULL');
call syppro_add_column('sys_users', 'active_flag', 'int(11) DEFAULT "1"');
call syppro_add_column('sys_users', 'create_user', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_users', 'update_user', 'int(11) DEFAULT NULL');
call syppro_add_column('sys_users', 'memo', 'varchar(300) DEFAULT NULL');
call syppro_add_column('sys_users', 'load_time', 'datetime DEFAULT NULL');
call syppro_add_column('sys_users', 'created_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP');
call syppro_add_column('sys_users', 'updated_at', 'datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
call syppro_add_column('sys_users', 'last_login_at', 'datetime DEFAULT "2016-01-15 06:19:44"');
call syppro_add_column('sys_users', 'last_login_ip', 'varchar(255) DEFAULT ""');
call syppro_add_column('sys_users', 'last_login_browser', 'varchar(255) DEFAULT ""');
call syppro_add_column('sys_users', 'sign_in_count', 'int(11) DEFAULT "0"');
call syppro_add_column('sys_users', 'last_login_version', 'varchar(255) DEFAULT ""');
call syppro_add_column('sys_users', 'access_token', 'varchar(255) DEFAULT ""');
call syppro_add_column('sys_users', 'coordinate', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_users', 'coordinate_location', 'varchar(255) DEFAULT NULL');
call syppro_add_column('sys_users', 'store_ids', 'text');
call syppro_add_column('sys_users', 'uuid', 'varchar(255) DEFAULT NULL COMMENT "UUID"');

call syppro_add_index('sys_records', 'index_uuid', 'uuid');
-- call syppro_add_unique_index('sys_backup_mysql_day', 'index_uuid', 'uuid');
call syppro_add_index('sys_backup_mysql_day', 'index_device_uuid', 'device_uuid');
-- call syppro_add_unique_index('sys_backup_mysql_meta', 'index_uuid', 'uuid');
call syppro_add_index('sys_backup_mysql_meta', 'index_device_uuid', 'device_uuid');
-- call syppro_add_unique_index('sys_agent_behavior_logs', 'index_uuid', 'uuid');
call syppro_add_index('sys_agent_behavior_logs', 'index_device_uuid', 'device_uuid');


