class CreateDevice < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_devices, force: false, comment: '设备服务器表' do |t|
      t.integer  :user_group_id, comment: '所属用户分组 ID'
      t.integer  :device_group_id, comment: '所属设备分组 ID'
      t.string   :uuid, comment: '设备 UUID'
      t.string   :human_name, comment: '业务名称'
      t.string   :hostname, comment: '主机名称'
      t.string   :ssh_ip, comment: 'SSH IP'
      t.string   :ssh_port, comment: 'SSH 端口'
      t.string   :ssh_username, comment: 'SSH 登录用户'
      t.string   :ssh_password, comment: 'SSH 登录密码'
      t.boolean  :ssh_state, default: false, comment: 'SSH 连接状态'
      t.string   :username, comment: '代理服务器用户名称'
      t.string   :password, comment: '代理服务器登录密码'
      t.string   :os_type, comment: '系统类型'
      t.string   :os_version, comment: '系统版本'
      t.string   :api_token, comment: 'API Token'
      t.string   :memory, comment: '内存大小'
      t.text     :memory_description, comment: '内存大小描述JSON'
      t.string   :cpu, comment: 'CPU 核数'
      t.text     :cpu_description, comment: 'CPU 描述JSON'
      t.string   :disk, comment: '磁盘大小'
      t.text     :disk_description, comment: '磁盘JSON'
      t.string   :notify_mode, comment: '通知模式'
      t.text     :notify_receivers, comment: '通知接收者'
      t.string   :lan_ip, comment: '内网 IP'
      t.string   :wan_ip, comment: '外网 IP'
      t.integer  :record_count, default: 0, comment: '记录数量'
      t.string   :request_ip, comment: '代理 IP'
      t.string   :request_agent, comment: '代理版本信息'
      t.text     :description, comment: '设备服务器描述'
      t.integer  :order_index, default: 0, comment: '排序序号'

      t.timestamps null: false
    end
  end
end
