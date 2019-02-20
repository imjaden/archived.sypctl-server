# encoding: utf-8
module Account
  class JobController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/jobs')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '任务管理'
    end

    get '/' do
      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = JobGroup.new
      @record.uuid = generate_uuid
      @record.executed_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      haml :new, layout: settings.layout
    end

    post '/' do
      device_list = params[:job_group].delete(:device_list)
      device_name = params[:job_group].delete(:device_name)
      params[:job_group][:uuid] ||= generate_uuid
      job_group = JobGroup.create(params[:job_group])

      options = params[:job_group]
      options.delete(:device_count)
      JSON.parse(device_list).each do |hsh|
        options[:uuid] = generate_uuid
        options[:job_group_uuid] = job_group.uuid
        options[:device_name] = hsh['name']
        options[:device_uuid] = hsh['uuid']

        Job.create(options)
      end
      job_group.update_attributes({device_count: job_group.jobs.count})

      flash[:success] = "创建 #{job_group.device_count} 个任务成功"
      redirect to("/")
    end

    get '/group/:uuid' do
      haml :show, layout: settings.layout
    end

    get '/:uuid' do
      unless @record = Job.find_by(uuid: params[:uuid])
        @record = Job.new
        @record.title = '任务不存在'
      end

      haml :show, layout: settings.layout
    end

    # 拷贝功能待考虑
    get '/:id/copy' do
      @job = JobGroup.find_by(id: params[:id])
      options = @job.to_hash
      options.delete(:id)
      options.delete(:state)
      options.delete(:device_name)
      options.delete(:device_uuid)

      @record = JobGroup.new(options)
      @record.uuid = generate_uuid
      @record.executed_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      haml :copy, layout: settings.layout
    end

    # 禁止编辑
    get '/:uuid/edit' do
      @record = JobGroup.find_by(uuid: params[:uuid])

      haml :edit, layout: settings.layout
    end

    # 禁止编辑
    post '/:uuid' do
      record = JobGroup.find_by(uuid: params[:uuid])
        
      if record.update_attributes(params[:job])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    delete '/:uuid' do
      job = Job.find_by(uuid: params[:uuid])
      halt_with_format_json({data: params[:uuid], message: '查询 job 失败'}, 404) unless job
      
      job.destroy
      if job_group = job.job_group
        job_group.update_attributes({device_count: job_group.jobs.count})
        job_group.destroy if job_group.device_count.zero?
      end
      
      respond_with_json({message: "「#{job.title}」删除成功"}, 201)
    end

    delete '/group/:uuid' do
      job_group = JobGroup.find_by(uuid: params[:uuid])
      halt_with_format_json({data: params[:uuid], message: '查询 job group 失败'}, 404) unless job_group
      
      job_group.destroy
      respond_with_json({message: "「#{job_group.title}」删除成功"}, 201)
    end
  end
end