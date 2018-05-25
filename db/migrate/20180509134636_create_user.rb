class CreateUser < ActiveRecord::Migration[5.1]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_users, force: false, comment: '用户表' do |t|
      t.string   :user_name,          limit: 50,                                  null: false
      t.string   :user_num,           limit: 50,                                  null: false
      t.string   :user_pass,          limit: 50,                                  null: false
      t.string   :email,              limit: 22,  default: ""
      t.string   :mobile,             limit: 18,  default: ""
      t.string   :tel,                limit: 16,  default: ""
      t.datetime :join_date
      t.string   :position,           limit: 50
      t.integer  :dept_id,            limit: 4
      t.string   :dept_name,          limit: 50
      t.integer  :active_flag,        limit: 4,   default: 1
      t.integer  :create_user,        limit: 4
      t.integer  :update_user,        limit: 4
      t.string   :memo,               limit: 300
      t.datetime :load_time
      t.timestamps null: false
      t.datetime :last_login_at,                  default: "2016-01-15 06:19:44"
      t.string   :last_login_ip,      limit: 255, default: ""
      t.string   :last_login_browser, limit: 255, default: ""
      t.integer  :sign_in_count,      limit: 4,   default: 0
      t.string   :last_login_version, limit: 255, default: ""
      t.string   :access_token,       limit: 255, default: ""
      t.string   :coordinate
      t.string   :coordinate_location
      t.string   :access_token,       limit: 255, default: ""
      t.text     :store_ids

      t.timestamps null: false
    end

    add_index :sys_users, :user_num, unique: true
  end
end
