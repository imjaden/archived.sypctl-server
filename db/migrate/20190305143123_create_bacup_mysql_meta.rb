class CreateBacupMysqlMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_backup_mysql_meta, force: false, comment: '备份MySQL数据库元信息' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :device_name, null: false, comment: '设备名称'
      t.string   :device_uuid, null: false, comment: '设备 UUID'
      t.string   :ymd, null: false, comment: '日期 YY/MM/DD'
      t.string   :database_count, comment: '实例中所有数据库数量'
      t.string   :backup_count, comment: '实例中所有数据库数量'
      t.string   :backup_size, comment: '数据库体积(共)'
      t.string   :backup_duration, comment: '备份总耗时'
      t.string   :backup_state, comment: '备份状态'
      t.text     :description, comment: '描述'

      t.timestamps null: false
    end

    create_table :sys_backup_mysql_day, force: false, comment: '每日备份MySQL数据库' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :device_name, null: false, comment: '设备名称'
      t.string   :device_uuid, null: false, comment: '设备 UUID'
      t.string   :ymd, null: false, comment: '日期 YY/MM/DD'
      t.string   :host, comment: 'ip'
      t.string   :port, comment: 'port'
      t.string   :database_name, comment: '数据库数量'
      t.string   :backup_name, comment: '备份文件'
      t.string   :backup_size, comment: '备份体积(压缩)'
      t.string   :backup_md5, comment: '备份文件MD5'
      t.string   :backup_time, comment: '备份执行时间'
      t.string   :backup_duration, comment: '备份耗时'
      t.string   :backup_state, comment: '备份路径'
      t.text     :description, comment: '描述'

      t.timestamps null: false
    end
  end
end
