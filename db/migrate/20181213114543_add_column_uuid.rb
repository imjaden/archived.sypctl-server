class AddColumnUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :sys_users, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_user_groups, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_apps, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_apps, :latest_version_uuid, :string, null: true, comment: '版本 UUID'
    add_column :sys_apps, :app_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_apps, :user_group_uuid, :string, null: true, comment: '用户 UUID'
    add_column :sys_app_groups, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_app_groups, :user_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_versions, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_versions, :app_uuid, :string, null: true, comment: '应用 UUID'
    add_column :sys_operation_logs, :uuid, :string, null: true, comment: 'UUID'
    add_column :sys_devices, :device_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_devices, :user_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_device_groups, :user_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_records, :device_uuid, :string, null: true, comment: '设备 UUID'
    add_column :sys_jobs, :user_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_job_templates, :user_group_uuid, :string, null: true, comment: '分组 UUID'
    add_column :sys_services, :device_uuid, :string, null: true, comment: '设备 UUID'
    add_column :sys_job_groups, :user_group_uuid, :string, null: true, comment: '分组 UUID'
  end
end
