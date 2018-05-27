class CreateVersion < ActiveRecord::Migration[5.1]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_versions, force: false, comment: '应用版本表' do |t|
      t.integer  :app_id, null: false, comment: '应用 ID'
      t.string   :version, null: false, comment: '版本号'
      t.integer  :build, null: false, comment: '版本 build 值'
      t.string   :file_name, comment: '文件名称'
      t.string   :file_size, comment: '应用体积'
      t.string   :md5, comment: '文件 MD5 值'
      t.string   :cdn_link, comment: 'CDN 链接'
      t.text     :description, comment: '版本描述'

      t.timestamps null: false
    end
  end
end
