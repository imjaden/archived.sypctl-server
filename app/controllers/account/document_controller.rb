# encoding: utf-8
module Account
  class DocumentController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/documents')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '文档中心'
    end

    get '/' do
      haml :index, layout: settings.layout
    end

    get '/new' do
      haml :new, layout: settings.layout
    end

    get '/edit' do
      haml :edit, layout: settings.layout
    end

    get '/images' do
      haml :index, layout: settings.layout
    end

    get '/preview/:uuid' do
      document = Document.find_by(uuid: params[:uuid])
      document.html || "文档内容为空！"
    end
  end
end