class CreateApp < ActiveRecord::Migration[5.1]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_apps, force: false, comment: '应用表' do |t|
      t.integer  :user_group_id, comment: '所属用户分组 ID'
      t.integer  :app_group_id, comment: '所属应用分组 ID'
      t.string   :name, null: false, comment: '应用名称'
      t.string   :file_name, null: false, comment: '文件名称'
      t.string   :file_type, null: false, comment: '类型类型'
      t.string   :latest_version, comment: '最新版本'
      t.string   :latest_version_id, comment: '最新版本 ID'
      t.string   :category, comment: '应用类型'
      t.text     :description, comment: '应用描述'

      t.timestamps null: false
    end
  end
end
