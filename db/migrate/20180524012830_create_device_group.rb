class CreateDeviceGroup < ActiveRecord::Migration[5.1]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_device_groups, force: false, comment: '设备分组表' do |t|
      t.integer  :user_group_id, comment: '所属用户分组 ID'
      t.string   :name, null: false, comment: '分组名称'
      t.integer  :device_count, default: 0, comment: '关联的设备数量'
      t.text     :description

      t.timestamps null: false
    end
  end
end
