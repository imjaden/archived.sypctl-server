# encoding: utf-8
module Account
  class AppController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/apps')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '应用管理'
    end

    get '/' do
      @records = App.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/new' do
      @record = App.new
      @record.file_path = "/usr/local/src/"

      haml :new, layout: settings.layout
    end

    post '/' do
      record = App.new(params[:app])
      record.uuid ||= generate_uuid

      if record.save(validate: true)
        flash[:success] = '创建成功'
        # redirect to("/") # /#{record.uuid}
        flash[:success]
      else
        flash[:danger] = record.errors.messages.to_s
        # redirect to('/new')
        flash[:danger]
      end
    end

    get '/:uuid' do
      unless @record = App.find_by(uuid: params[:uuid])
        @record = App.new
        @record.name = '应用不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:uuid/edit' do
      @record = App.find_by(uuid: params[:uuid])

      haml :edit, layout: settings.layout
    end

    post '/:uuid' do
      record = App.find_by(uuid: params[:uuid])
        
      if record.update_attributes(params[:app])
        flash[:success] = '更新成功'
        redirect to("/#{record.uuid}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/#{record.uuid}/edit")
      end
    end

    delete '/:uuid' do
      if record = App.find_by(uuid: params[:uuid])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.name}」删除成功"}, 201)
    end

    get '/:uuid/version/upload' do
      @app = App.find_by(uuid: params[:uuid])

      haml :'version/upload', layout: settings.layout
    end

    post '/:uuid/version/upload' do
      if res = upload_version(params)
        app = App.find_by(uuid: params[:uuid])
        version = Version.create({
          uuid: generate_uuid,
          app_id: params[:app_id],
          app_uuid: params[:app_uuid],
          md5: res[:file_md5],
          file_name: res[:file_name],
          origin_file_name: res[:origin_file_name],
          file_size: res[:file_size],
          file_path: res[:file_path],
          version: increment_version(app.latest_version),
          build: increment_build(app.latest_build),
        })
        app.update_attributes({
          latest_version: version.version,
          latest_build: version.build,
          latest_version_id: version.id, 
          latest_version_uuid: version.uuid, 
          version_count: app.versions.count
        })
        respond_with_json({message: "上传成功", data: "/account/apps/#{app.uuid}/version/#{version.uuid}/edit"}, 201)
      else
        respond_with_json({message: "上传失败"}, 201)
      end
    end

    get '/:app_uuid/version/:version_uuid/edit' do
      @app = App.find_by(uuid: params[:app_uuid])
      @version = Version.find_by(uuid: params[:version_uuid])

      haml :'version/edit', layout: settings.layout
    end

    post '/:app_uuid/version/:version_uuid' do
      version = Version.find_by(uuid: params[:version_uuid])
      version.update_attributes(params[:version])

      app = App.find_by(uuid: params[:app_uuid])
      app.update_attributes({
        latest_version: version.version,
        latest_build: version.build,
        latest_version_id: version.id, 
        latest_version_uuid: version.uuid, 
        version_count: app.versions.count
      })
      puts Version.where("app_uuid = ? and version = ? and uuid != ?", app.uuid, version.version, version.uuid).to_sql
      Version.where("app_uuid = ? and version = ? and uuid != ?", app.uuid, version.version, version.uuid).each do |record|
        puts "删除如下重复应用版本:"
        puts "- 应用名称: #{app.name}(#{app.uuid})"
        puts "- 版本名称: #{record.version}(#{record.uuid})"
        puts "- 创建时间: #{record.created_at}"
        record.destroy
      end

      redirect to("/") # /#{params[:app_uuid]}/version/#{params[:version_uuid]}
    end

    get '/:app_uuid/version/:version_uuid' do
      @app = App.find_by(uuid: params[:app_uuid])
      @version = Version.find_by(uuid: params[:version_uuid])

      haml :'version/show', layout: settings.layout
    end

    get '/:app_uuid/version' do
      @app = App.find_by(uuid: params[:app_uuid])
      @versions = @app.versions.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :'version/index', layout: settings.layout
    end

    get '/:app_uuid/version/:version_uuid' do
      @app = App.find_by(uuid: params[:app_uuid])
      @record = Version.find_by(uuid: params[:version_uuid])

      haml :'version/show', layout: settings.layout
    end

    protected

    def upload_version(params)
      version_md5, version_path = nil, nil
      version_folder = File.join(Setting.path.version, params[:app_uuid].to_s)
      FileUtils.mkdir_p(version_folder) unless File.exist?(version_folder)

      form_data = params[:file]
      if form_data && (temp_file = form_data[:tempfile])
        extname = File.extname(form_data[:filename])
        version_path = File.join(version_folder, "#{generate_uuid}#{extname}")
        begin
          FileUtils.rm_rf(version_path) if File.exist?(version_path)
          File.open(version_path, "wb") { |file| file.write(temp_file.read) }
          version_md5 = digest_file_md5(version_path)
        rescue => e
          puts "#{__FILE__}:#{__LINE__} #{e.message}"
        end
        
        {
          file_name: File.basename(version_path),
          origin_file_name: form_data[:filename],
          file_type: form_data[:type],
          file_size: File.size(version_path),
          file_path: version_path,
          file_md5: version_md5
        }
      end
    end

    def increment_version(version)
      parts = version.to_s.split('.')
      parts[-1] = parts[-1].to_i + 1
      parts.unshift(0) while parts.length < 3
      parts.join('.')
    rescue => e
      puts "#{__FILE__}:#{__LINE__} #{e.message}"
      '0.0.1'
    end

    def increment_build(build)
      build.to_i + 1
    rescue => e
      puts "#{__FILE__}:#{__LINE__} #{e.message}"
      1
    end
  end
end