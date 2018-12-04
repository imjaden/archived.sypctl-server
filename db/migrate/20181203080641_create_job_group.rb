class CreateJobGroup < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_job_groups, force: false, comment: '任务组表' do |t|
      t.integer  :user_group_id, comment: '所属用户分组 ID'
      t.string   :uuid, null: false, comment: '任务组 UUID'
      t.string   :title, null: false, comment: '任务组标题'
      t.text     :description, comment: '任务组描述'
      t.string   :app_id, comment: '应用 ID'
      t.string   :app_name, comment: '应用名称'
      t.string   :version_id, comment: '版本 ID'
      t.string   :version_name, comment: '版本名称'
      t.integer  :device_count, default: 1, comment: '设备数量'
      t.text     :command, comment: '部署脚本'
      t.string   :state, default: 'waiting', comment: '部署进度'
      t.string   :executed_at, comment: '执行时间，支持定时任务'

      t.timestamps null: false
    end

    add_column :sys_jobs, :job_group_uuid, :string, null: false, comment: '任务组 UUID'
  end
end
