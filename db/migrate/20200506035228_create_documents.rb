class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :sys_document_groups, force: false, comment: '文档夹表' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :title, null: false, comment: '标题'
      t.string   :description, comment: '描述'
      t.string   :cover, comment: '封面'
      t.string   :tags, comment: '标签'
      t.integer  :order, default: 0, comment: '序号'
      t.string   :creater_name, comment: '创建人名称'
      t.string   :creater_uuid, comment: '创建人UUID'
      t.timestamps null: false
    end

    create_table :sys_documents, force: false, comment: '文档表' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :group_uuid, null: false, uniq: true, comment: '文件夹UUID'
      t.string   :title, null: false, comment: '标题'
      t.text     :content, null: false, comment: '文档标题'
      t.text     :html, comment: 'Markdown 翻译为 HTML'
      t.text     :description, comment: '描述'
      t.string   :tags, comment: '标签'
      t.integer  :order, default: 0, comment: '序号'
      t.integer  :history_count, default: 0, comment: '历史修改快照数量'
      t.string   :creater_name, comment: '创建人名称'
      t.string   :creater_uuid, comment: '创建人UUID'
      t.timestamps null: false
    end

    create_table :sys_document_histories, force: false, comment: '文档修改历史表' do |t|
      t.string   :uuid, null: false, uniq: true, comment: 'UUID'
      t.string   :document_uuid, null: false, uniq: true, comment: '文件UUID'
      t.string   :group_uuid, null: false, uniq: true, comment: '文件夹UUID'
      t.string   :title, null: false, comment: '标题'
      t.text     :content, null: false, comment: '文档标题'
      t.text     :html, comment: 'Markdown 翻译为 HTML'
      t.text     :description, comment: '描述'
      t.string   :tags, comment: '标签'
      t.integer  :order, default: 0, comment: '序号'
      t.string   :creater_name, comment: '创建人名称'
      t.string   :creater_uuid, comment: '创建人UUID'
      t.string   :updater_name, comment: '修改人名称'
      t.string   :updater_uuid, comment: '修改人UUID'
      t.timestamps null: false
    end
  end
end
