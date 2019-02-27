class CreateAgentBehaviorLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_agent_behavior_logs, force: false, comment: '代理端行为记录' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :device_name, null: false, comment: '设备名称'
      t.string   :device_uuid, null: false, comment: '设备 UUID'
      t.string   :behavior, null: false, comment: '行为描述'
      t.string   :object_type, null: false, comment: '行为对象类型'
      t.string   :object_id, null: false, comment: '行为对象标识'
      t.string   :description, :string, null: true, comment: '描述'

      t.timestamps null: false
    end
  end
end
