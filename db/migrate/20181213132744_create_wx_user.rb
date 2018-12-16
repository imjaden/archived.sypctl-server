class CreateWxUser < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_wx_users, force: false, comment: '微信用户表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :user_group_uuid, :string, null: true, comment: '用户 UUID'
      t.string   :session_key, comment: 'session_key'
      t.string   :appid, comment: 'APPID'
      t.string   :openid, comment: 'OPENID'
      t.string   :avatar_url, comment: '头像 URL'
      t.string   :group_name, comment: '拉取群名称'
      t.string   :group_openid, comment: '拉取群OPENID'
      t.string   :name, null: false, comment: '名称'
      t.string   :nick_name, null: false, comment: '昵称'
      t.boolean  :gender, comment: '性别 0：未知、1：男、2：女'
      t.string   :province, comment: 'province'
      t.string   :city, comment: 'city'
      t.string   :country, comment: 'country'
      t.string   :lang, comment: 'lang'
      t.string   :mobile, comment: '手机号'

      t.timestamps null: false
    end

    create_table :sys_user_connections, force: false, comment: '微信用户表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :user_group_uuid, null: false, comment: '分组 UUID'
      t.string   :user_uuid, :string, null: true, comment: '用户 UUID'
      t.string   :user_type, default: 'user', comment: 'user/wx_user'

      t.timestamps null: false
    end
  end
end
