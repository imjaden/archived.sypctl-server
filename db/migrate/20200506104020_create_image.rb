class CreateImage < ActiveRecord::Migration[6.0]
  def change
    create_table :sys_images, force: false, comment: '图片表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :creater_uuid, null: false, comment: '创建人UUID'
      t.string   :file_name, comment: '文件名称'
      t.string   :origin_file_name, comment: '文件原名称'
      t.string   :file_size, comment: '文件体积'
      t.string   :md5, comment: '文件哈希值'
      t.string   :origin_md5, comment: '文件原哈希值'
      t.string   :file_path, comment: '文件存储路径'
      t.string   :cdn_state, default: '无任务', comment: '上传 CDN 状态'
      t.string   :cdn_link, comment: 'CDN 链接'
      t.text     :description, comment: '版本描述'

      t.timestamps null: false
    end
  end
end
