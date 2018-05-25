class CreateUserGroup < ActiveRecord::Migration[5.1]
  def change
    # [<tt>:force</tt>]
    #   Set to true to drop the table before creating it.
    #   Set to +:cascade+ to drop dependent objects as well.
    #   Defaults to false.
    create_table :sys_user_groups, force: false, comment: '用户分组表' do |t|
      t.string   :name, null: false, comment: '分组名称'
      t.text     :description

      t.timestamps null: false
    end
  end
end
