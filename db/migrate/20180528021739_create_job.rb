class CreateJob < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_jobs, force: false, comment: '任务表' do |t|
      t.string   :uuid, null: false, comment: '任务 UUID'
      t.string   :title, null: false, comment: '任务标题'
      t.text     :description, comment: '任务描述'
      t.string   :app_id, comment: '应用 ID'
      t.string   :app_name, comment: '应用名称'
      t.string   :version_id, comment: '版本 ID'
      t.string   :version_name, comment: '版本名称'
      t.string   :device_uuid, comment: '设备 UUID'
      t.string   :device_name, comment: '设备名称'
      t.text     :command, comment: '部署脚本'
      t.text     :output, comment: '脚本输出'
      t.string   :state, default: 'waiting', comment: '部署进度'
      t.string   :executed_at, comment: '执行时间，支持定时任务'

      t.timestamps null: false
    end
  end
end
