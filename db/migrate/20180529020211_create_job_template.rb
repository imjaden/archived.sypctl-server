class CreateJobTemplate < ActiveRecord::Migration[5.2]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_job_templates, force: false, comment: '任务模板表' do |t|
      t.integer  :user_group_id, comment: '所属用户分组 ID'
      t.string   :uuid, null: false, comment: '模板 UUID'
      t.string   :title, null: false, comment: '模板标题'
      t.string   :type, null: false, comment: '模板类型', default: 'script'
      t.text     :description, comment: '任务描述'
      t.text     :content, comment: '任务模板'

      t.timestamps null: false
    end
  end
end
