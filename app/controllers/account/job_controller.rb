# encoding: utf-8
module Account
  class JobController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/jobs')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '任务管理'
    end

    get '/' do
      @records = Job.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = Job.new
      @record.uuid = SecureRandom.uuid
      @record.executed_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      haml :new, layout: settings.layout
    end

    post '/' do
      device_list = JSON.parse(params[:job].delete(:device_list))
      device_list.each do |hsh|
        params[:job][:uuid] = SecureRandom.uuid
        params[:job][:device_name] = hsh['name']
        params[:job][:device_uuid] = hsh['uuid']

        Job.create(params[:job])
      end

      flash[:success] = "创建 #{device_list.length} 个任务成功"
      redirect to("/")
    end

    get '/:id' do
      unless @record = Job.find_by(id: params[:id])
        @record = Job.new
        @record.title = '任务不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = Job.find_by(id: params[:id])

      haml :edit, layout: settings.layout
    end

    get '/:id/copy' do
      @job = Job.find_by(id: params[:id])
      options = @job.to_hash
      options.delete(:id)
      options.delete(:state)
      options.delete(:device_name)
      options.delete(:device_uuid)

      @record = Job.new(options)
      @record.uuid = SecureRandom.uuid
      @record.executed_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      haml :copy, layout: settings.layout
    end

    post '/:id' do
      record = Job.find_by(id: params[:id])
        
      if record.update_attributes(params[:job])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    delete '/:id' do
      if record = Job.find_by(id: params[:id])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.title}」删除成功"}, 201)
    end
  end
end