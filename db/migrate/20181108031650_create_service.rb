class CreateService < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_services, force: false, comment: '服务配置档' do |t|
      t.string   :uuid, null: false, comment: '设备 UUID'
      t.string   :hostname, null: false, comment: '主机名称'
      t.text     :config, comment: 'JSON 配置档'
      t.text     :monitor, comment: 'JSON 运行状态'
      t.integer  :total_count, comment: '服务列表数量'
      t.integer  :stopped_count, comment: '未运行服务数量'
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end

    add_column :sys_devices, :service_state, :boolean, default: false, comment: '服务列表配置状态'
    add_column :sys_devices, :service_monitor, :text, comment: '服务运行状态'
    add_column :sys_devices, :service_count, :integer, default: 0, comment: '服务列表数量'
    add_column :sys_devices, :service_stopped_count, :integer, default: 0, comment: '服务未运行数量'
  end
end
