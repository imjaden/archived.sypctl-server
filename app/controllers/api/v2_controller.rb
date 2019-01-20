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
      halt_with_format_json({data: params[:uuid], message: "查询任务分组失败，#{params[:uuid]}", code: 200}, 200) unless record

      count = record.jobs.count
      halt_with_format_json({data: params[:uuid], message: "删除任务分组失败，请手工删除分组下的#{count}个任务", code: 200}, 200) unless count.zero?

      record.destroy
      respond_with_json({message: "成功删除任务分组「#{record.title}」", code: 201}, 201)
    end

    post '/account/file_backup/create' do
      params[:file][:uuid] ||= generate_uuid
      record = FileBackup.create(params[:file])

      respond_with_formt_json({data: record.to_hash, message: "成功创建文件备份", code: 201}, 201)
    end

    get '/account/file_backup/list' do
      records = FileBackup.all.order(id: :desc).map(&:to_hash)

      respond_with_formt_json({data: records, message: "成功获取#{records.length}条数据"}, 200)
    end

    protected

    def authen_api_token(api_token)
      Setting.api_keys.any? { |key| md5("#{key}#{request.path}#{key}") == api_token }
    end
  end
end