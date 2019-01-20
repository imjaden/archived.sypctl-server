class CreateFileBackup < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_file_backups, force: false, comment: '文件备份表' do |t|
      t.string   :uuid, null: false, comment: 'UUID'
      t.string   :file_path, null: false, uniq: true, comment: '文件路径'
      t.string   :description, :string, null: true, comment: ' 文件描述'

      t.timestamps null: false
    end
  end
end
