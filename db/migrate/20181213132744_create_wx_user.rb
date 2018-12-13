class CreateWxUser < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_wx_users, force: false, comment: '微信用户表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :user_group_uuid, :string, null: true, comment: '用户 UUID'
      t.string   :openid, comment: 'openid'
      t.string   :wxid, comment: 'weixinid'
      t.string   :avatar, comment: '头像'
      t.string   :name, null: false, comment: '名称'
      t.string   :nick_name, null: false, comment: '昵称'
      t.string   :mobile, comment: '手机号'

      t.timestamps null: false
    end

    create_table :sys_user_connections, force: false, comment: '微信用户表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :user_group_uuid, null: false, comment: '分组 UUID'
      t.string   :user_uuid, :string, null: true, comment: '用户 UUID'
      t.string   :user_type, default: 'user', comment: 'user/wxuser'

      t.timestamps null: false
    end
  end
end
