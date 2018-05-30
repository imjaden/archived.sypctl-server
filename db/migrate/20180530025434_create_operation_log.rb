class CreateOperationLog < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_operation_logs, force: false, comment: '行为日志记录' do |t|
      t.string   :operator, null: false, comment: '操作者'
      t.text     :description, comment: '行为描述'
      t.string   :template, comment: '模板'
      t.string   :objects, comment: '对象'
      t.string   :tags, comment: '标签'
      t.string   :ip, comment: '请求 IP'
      t.text     :browser, comment: '操作浏览器'
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }
    end
  end
end
