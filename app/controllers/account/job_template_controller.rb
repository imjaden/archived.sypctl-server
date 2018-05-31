# encoding: utf-8
module Account
  class JobTemplateController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/job_templates')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '模板管理'
    end

    get '/' do
      @records = JobTemplate.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = JobTemplate.new
      @record.uuid = SecureRandom.uuid

      haml :new, layout: settings.layout
    end

    post '/' do
      record = JobTemplate.new(params[:job_template])

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to("/#{record.id}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to('/new')
      end
    end

    get '/:id' do
      unless @record = JobTemplate.find_by(id: params[:id])
        @record = JobTemplate.new
        @record.title = '任务模板不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = JobTemplate.find_by(id: params[:id])

      haml :edit, layout: settings.layout
    end

    post '/:id' do
      record = JobTemplate.find_by(id: params[:id])
        
      if record.update_attributes(params[:job_template])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    delete '/:id' do
      if record = JobTemplate.find_by(id: params[:id])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.title}」删除成功"}, 201)
    end
  end
end