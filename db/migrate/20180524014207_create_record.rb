class CreateRecord < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_records, force: false, comment: '代理请求记录表' do |t|
      t.string   :uuid, comment: '设备 UUID'
      t.string   :api_token, comment: '应用 ID'
      t.string   :version, comment: '代理版本'
      t.string   :whoami, comment: '代理运行账号'
      t.string   :memory_usage, comment: '内存使用情况'
      t.text     :memory_usage_description, comment: '内存使用情况JSON'
      t.string   :cpu_usage, comment: 'CPU  使用情况'
      t.text     :cpu_usage_description, comment: 'CPU  使用情况描述JSON'
      t.string   :disk_usage, comment: '磁盘使用情况'
      t.text     :disk_usage_description, comment: '磁盘使用情况JSON'
      t.string   :request_ip, comment: '代理 IP'
      t.text     :description, comment: '请求描述'

      t.timestamps null: false
    end
  end
end
