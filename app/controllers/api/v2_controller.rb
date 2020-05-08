# encoding: utf-8
require 'digest/md5'
require 'securerandom'
#
# portal ui 使用
#
module API
  class V2Controller < API::ApplicationController
    before do
      if Setting.website.api_key
        halt_with_format_json({message: '接口验证失败：请提供 api_token'}, 401) unless params[:api_token]
        halt_with_format_json({message: '接口验证失败：api_token 错误'}, 401) unless authen_api_token(params[:api_token])
      end
      params[:page], params[:page_size] = (params[:page] || 1).to_i, (params[:page_size] || 15).to_i if request.request_method.downcase == 'get'
    end

    options '/*' do
      respond_with_formt_json({message: '接收成功'}, 201)
    end

    post '/login' do
      user, message = User.authen_with_api({user_num: params[:username], user_pass: params[:password]})
      
      if user
        respond_with_formt_json({data: user.user_num, message: message}, 200)
      else
        respond_with_formt_json({message: message}, 401)
      end
    end

    get '/user' do
      respond_with_formt_json({message: '接收成功'}, 201)

      user, message = User.find_by(user_num: params[:token])
      data = {
        roles: ['admin'],
        name: user.user_num,
        avatar: '',
        introduction: 'hey'
      }
      respond_with_formt_json({data: data, message: '查询成功'}, 200)
    end

    get '/device-group/list' do
      records = DeviceGroup.paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(id: :desc)

      respond_with_formt_json({data: {items: records.map(&:to_hash), total: DeviceGroup.count}, message: '接收成功'}, 201)
    end

    get '/device/list' do
      records = Device.paginate(page: params[:page] || 1, per_page: params[:limit] || 20).order(updated_at: :desc)

      respond_with_formt_json({data: {items: records.map(&:to_hash), total: Device.count}, message: '接收成功'}, 201)
    end

    get '/account/job_group' do
      authen_api_token([:uuid])
      record = JobGroup.find_by(uuid: params[:uuid])

      respond_with_json({data: record.jobs.map(&:to_hash), message: '查询成功', code: 200}, 200)
    end

    get '/account/job_group/new' do
      record = JobGroup.new
      record.uuid = generate_uuid
      record.executed_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      respond_with_json({data: record.to_hash, message: '成功初始化任务分组', code: 200}, 200)
    end

    get '/account/job_group/copy' do
      authen_api_token([:uuid])

      record = JobGroup.find_by(uuid: params[:uuid])
      options = record.to_hash
      options[:uuid] = generate_uuid
      options[:executed_at] = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      jobs = record.jobs
      options[:device_name] = jobs.map { |job| "<#{job.device_name}>" }.join
      options[:device_list] = jobs.map { |job| {name: job.device_name, uuid: job.device_uuid} }.to_json

      respond_with_json({data: options, message: '成功初始化任务分组', code: 200}, 200)
    end

    get '/account/job_group/list' do
      records = JobGroup.order(id: :desc).limit(30).map(&:to_hash)

      respond_with_formt_json({data: records, message: "成功获取#{records.length}条数据"}, 200)
    end

    post '/account/job_group/delete' do
      authen_api_token([:uuid])

      record = JobGroup.find_by(uuid: params[:uuid])
      halt_with_format_json({data: params[:uuid], message: "任务分组查询失败", code: 200}, 200) unless record

      count = record.jobs.count
      halt_with_format_json({data: params[:uuid], message: "任务分组删除失败，请手工删除分组下的#{count}个任务", code: 200}, 200) unless count.zero?

      record.destroy
      respond_with_json({message: "成功删除任务分组「#{record.title}」", code: 201}, 201)
    end

    post '/account/file_backup/create' do
      authen_api_token([:file])

      params[:file][:uuid] ||= generate_uuid
      record = FileBackup.create(params[:file])

      respond_with_formt_json({data: record.to_hash, message: "备份文件创建成功", code: 201}, 201)
    end

    post '/account/file_backup/update' do
      authen_api_token([:file])

      record = FileBackup.find_by(uuid: params[:file][:uuid])
      halt_with_format_json({data: params[:uuid], message: "备份文件查询失败", code: 200}, 200) unless record

      record.update_attributes(params[:file])
      respond_with_formt_json({data: record.to_hash, message: "备份文件更新成功", code: 201}, 201)
    end

    post '/account/file_backup/delete' do
      authen_api_token([:file])

      record = FileBackup.find_by(uuid: params[:file][:uuid])
      halt_with_format_json({data: params[:uuid], message: "备份文件查询失败", code: 200}, 200) unless record

      record.destroy
      respond_with_formt_json({data: params[:file][:uuid], message: "文件备份删除成功", code: 201}, 201)
    end

    get '/account/file_backup/list' do
      records = FileBackup.all.order(description: :asc).map(&:to_hash)

      respond_with_formt_json({data: records, message: "备份文件查询成功(#{records.length}条)"}, 200)
    end

    get '/account/file_backup/read' do
      authen_api_token([:device_uuid, :snapshot_filename])

      file_path = File.join(Setting.path.file_backup, params[:device_uuid], 'snapshots', params[:snapshot_filename])
      data = File.exists?(file_path) ? File.read(file_path) : "文件不存在 #{file_path}"
      
      respond_with_formt_json({data: data, message: "备份文件读取成功"}, 200)
    end

    get '/account/file_backup/download' do
      authen_api_token([:device_uuid, :snapshot_filename])

      file_path = File.join(Setting.path.file_backup, params[:device_uuid], 'snapshots', params[:snapshot_filename])
      halt_with_format_json({message: "文件不存在 #{params[:snapshot_filename]}"}, 200) unless File.exists?(file_path) 
      
      send_file(file_path, type: 'text/plain', filename: params[:snapshot_filename], disposition: 'attachment')
    end

    get '/account/file_backup/db_info' do
      respond_with_formt_json({data: FileBackup.db_info, message: "查询成功"}, 200)
    end

    post '/account/file_backup/db_info' do
      FileBackup.refresh_file_backup_cache

      respond_with_formt_json({data: FileBackup.db_info, message: "刷新成功"}, 200)
    end

    get '/account/device/query' do
      authen_api_token([:uuid])
      record = Device.find_by(uuid: params[:uuid])

      respond_with_formt_json({data: record ? record.to_hash : {human_name: '不存在'}, message: "查询成功"}, 200)
    end

    get '/account/device/list' do
      keys = [:uuid, :human_name, :hostname, :monitor_state, :ssh_state, :os_type, :os_version, :updated_at, :device_group_uuid]
      devices = Device.all.order(order_index: :asc).map { |r| r.to_hash.simple(keys) }

      keys = [:uuid, :name]
      uuids = devices.map { |hsh| hsh[:device_group_uuid] }.uniq
      records = DeviceGroup.where(uuid: uuids).order(order_index: :asc).map { |r| r.to_hash.simple(keys) }
      records.push({uuid: nil, name: '未分组'})

      records = records.map do |hsh|
        hsh[:devices] = devices.select { |h| h[:device_group_uuid] == hsh[:uuid] }
        hsh
      end

      respond_with_formt_json({data: records, message: "查询成功"}, 200)
    end

    get '/account/app/list' do
      records = App.order(id: :desc).limit(30).map(&:to_hash)

      respond_with_formt_json({data: records, message: "成功获取#{records.length}条数据"}, 200)
    end

    get '/account/device_behavior_log/list' do
      params[:page_size] ||= 30
      records = AgentBehaviorLog.where(device_uuid: params[:device_uuid]).order(id: :desc).limit(params[:page_size]).offset(params[:page] * params[:page_size]).map(&:to_hash)

      respond_with_formt_json({data: records, message: "第#{params[:page]+1}页#{records.length}条数据"}, 200)
    end

    get '/account/agent_behavior_log/list' do
      params[:page_size] ||= 30
      records = AgentBehaviorLog.order(id: :desc).limit(params[:page_size]).offset(params[:page] * params[:page_size]).map(&:to_hash)

      respond_with_formt_json({data: records, message: "第#{params[:page]+1}页#{records.length}条数据"}, 200)
    end

    get '/account/backup_mysql_meta/list' do
      records = BackupMysqlMeta.where(device_uuid: params[:device_uuid]).order(updated_at: :desc).limit(30).offset(params[:page] * 30).map(&:to_hash)

      respond_with_formt_json({data: records, message: "成功获取#{records.length}条数据"}, 200)
    end

    get '/account/backup_mysql_day/list' do
      records = BackupMysqlDay.where(device_uuid: params[:device_uuid], ymd: params[:ymd]).order(backup_size: :desc).map(&:to_hash)

      respond_with_formt_json({data: records, message: "成功获取#{records.length}条数据"}, 200)
    end

    get '/account/backup_mysql/download' do
      backup_path = File.join(Setting.path.mysql_backup, params[:device_uuid], params[:host], params[:ymd].gsub('/', ''), params[:backup_name])

      halt_with_format_json({data: backup_path, message: "备份不存在"}, 200) unless File.exists?(backup_path) 
      
      send_file(backup_path, type: 'application/x-gzip ', filename: params[:backup_name], disposition: 'attachment')
    end

    get '/account/document/list' do
      documents = Document.all.order(order: :asc).map(&:to_hash)
      document_groups = DocumentGroup.order(order: :asc).map(&:to_hash)

      records = document_groups.map do |hsh|
        hsh[:documents] = documents.select { |h| h[:group_uuid] == hsh[:uuid] }
        hsh
      end

      respond_with_formt_json({data: records, message: "查询成功"}, 200)
    end

    post '/account/document/create' do
      params[:document][:group_uuid] ||= ''
      params[:document][:uuid] ||= generate_uuid
      record = Document.create(params[:document])
      record.create_history_snapshot

      respond_with_formt_json({data: record.to_hash, message: "创建成功"}, 200)
    end

    get '/account/document/query' do
      authen_api_token([:uuid])

      record = Document.find_by(uuid: params[:uuid])

      respond_with_formt_json({data: record.to_hash, message: "查询成功"}, 200)
    end

    put '/account/document/update' do
      authen_api_token([:uuid])

      record = Document.find_by(uuid: params[:uuid])
      record.update_attributes(params[:document])
      record.create_history_snapshot

      respond_with_formt_json({data: record.to_hash, message: "查询成功"}, 200)
    end

    delete '/account/document/delete' do
    end

    post '/account/document_group/create' do
      params[:document_group][:uuid] ||= generate_uuid
      record = DocumentGroup.create(params[:document_group])

      respond_with_formt_json({data: record.to_hash, message: "创建成功"}, 200)
    end

    get '/account/document_group/list' do
      authen_api_token([:uuid])

      records = DocumentGroup.all.map(&:to_hash)

      respond_with_formt_json({data: records, message: "查询成功"}, 200)
    end

    get '/account/document_group/query' do
      authen_api_token([:uuid])

      record = DocumentGroup.find_by(uuid: params[:uuid])

      respond_with_formt_json({data: record.to_hash, message: "查询成功"}, 200)
    end

    put '/account/document_group/update' do
      authen_api_token([:uuid])

      record = DocumentGroup.find_by(uuid: params[:uuid])
      record.update_attributes(params[:document_group])

      respond_with_formt_json({data: record.to_hash, message: "查询成功"}, 200)
    end

    get '/account/image/list' do
      records = Image.order(id: :desc).map(&:to_hash)

      respond_with_formt_json({data: records, message: "查询成功"}, 200)
    end

    post '/account/image/upload' do
      halt_with_json({message: "上传失败"}, 201) unless res = upload_image(params)

      image = Image.create({
        uuid: generate_uuid,
        creater_uuid: 'todo',
        md5: res[:file_md5],
        file_name: res[:file_name],
        origin_file_name: res[:origin_file_name],
        file_size: res[:file_size],
        file_path: res[:file_path]
      })
      respond_with_json({message: "上传成功", data: image.to_hash}, 201)
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end

    def upload_image(params)
      image_md5, image_path = nil, nil
      image_folder = File.join(Setting.path.images)
      FileUtils.mkdir_p(image_folder) unless File.exist?(image_folder)

      form_data = params[:file]
      if form_data && (temp_file = form_data[:tempfile])
        extname = File.extname(form_data[:filename])
        image_path = File.join(image_folder, "#{generate_uuid}#{extname}")
        begin
          FileUtils.rm_rf(image_path) if File.exists?(image_path)
          File.open(image_path, "wb") { |file| file.write(temp_file.read) }
          image_md5 = digest_file_md5(image_path)
        rescue => e
          puts "#{__FILE__}:#{__LINE__} #{e.message}"
        end
        
        {
          file_name: File.basename(image_path),
          origin_file_name: form_data[:filename],
          file_type: form_data[:type],
          file_size: File.size(image_path),
          file_path: image_path,
          file_md5: image_md5
        }
      end
    end
  end
end