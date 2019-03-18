class CreateSmsRecord < ActiveRecord::Migration[5.2]
  def change
    create_table :sys_sms_records, force: false, comment: '发送短信记录表' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :mobile, null: false, comment: '手机号'
      t.string   :message, null: false, comment: '短信内容'
      t.string   :state, null: false, default: 'todo', comment: '发送状态, default: todo'
      t.string   :sms_code, comment: '响应编号(阿里云)'
      t.string   :sms_message, comment: '响应编号(阿里云)'
      t.float    :sms_total_time, comment: '发送耗时'
      t.string   :sms_request_id, comment: '请求 ID(阿里云)'
      t.string   :sms_biz_id, comment: 'BIZ ID(阿里云)'
      t.string   :creater_name, comment: '发送人名称'
      t.string   :creater_uuid, comment: '发送人uuid/mobile'

      t.text     :description, comment: '描述'

      t.timestamps null: false
    end
  end
end
