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

      haml :new, layout: settings.layout
    end

    post '/' do
      puts params
      record = App.new(params[:app])

      if record.save(validate: true)
        flash[:success] = '创建成功'
        redirect to('/')
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to('/new')
      end
    end

    get '/:id' do
      unless @record = App.find_by(id: params[:id])
        @record = App.new
        @record.name = '应用不存在'
      end

      haml :show, layout: settings.layout
    end

    get '/:id/edit' do
      @record = App.find_by(id: params[:id])

      haml :edit, layout: settings.layout
    end

    post '/:id' do
      record = App.find_by(id: params[:id])
        
      if record.update_attributes(params[:app])
        flash[:success] = '更新成功'
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      else
        flash[:danger] = record.errors.messages.to_s
        redirect to("/?page=#{params[:page] || 1}&id=#{params[:id]}")
      end
    end

    delete '/:id' do
      if record = App.find_by(id: params[:id])
        record.destroy
      end
      
      respond_with_json({message: "「#{record.name}」删除成功"}, 201)
    end

    get '/:id/version/new' do
      @app = App.find_by(id: params[:id])
      @record = Version.new
      @record.app_id = @app.id

      haml :'version/new', layout: settings.layout
    end

    post '/:id/version' do
      @app = App.find_by(id: params[:id])

      md5, file_path = read_upload_file(params)

      params[:version].delete(:file)
      params[:version][:md5] = md5
      params[:version][:file_name] = File.basename(file_path)
      params[:version][:file_size] = File.size(file_path).number_to_human_size if File.exists?(file_path)

      version = Version.create(params[:version])
      @app.update_attributes({latest_version: version.version, latest_version_id: version.id})

      redirect to("/?id=#{params[:id]}")
    end

    get '/:id/version/:version_id' do
      @app = App.find_by(id: params[:id])
      @record = Version.find_by(id: params[:version_id])

      haml :'version/show', layout: settings.layout
    end

    protected

    def read_upload_file(params)
      version_file_md5 = nil
      version_file_md5_path = nil
      version_path = File.join(Setting.path.version, params[:id])
      FileUtils.mkdir_p(version_path) unless File.exist?(version_path)

      form_data = params[:version][:file]
      if form_data && (temp_file = form_data[:tempfile])
        extname = File.extname(form_data[:filename]) || '.zip'
        version_file_path = File.join(version_path, "#{SecureRandom.uuid}#{extname}")
        begin
          File.open(version_file_path, "w:utf-8") { |file| file.puts(temp_file.read.force_encoding("UTF-8")) }
          version_file_md5 = digest_file_md5(version_file_path)
          version_file_md5_path = File.join(version_path, "#{version_file_md5}.#{extname}")
          FileUtils.mv(version_file_path, version_file_md5_path)
        rescue => e
          puts "#{__FILE__}:#{__LINE__} #{e.message}"
        end
        
        [version_file_md5, version_file_md5_path]
      end
    end
  end
end