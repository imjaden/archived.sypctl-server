# encoding: utf-8
module Account
  class DocumentGroupController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/document_groups')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '文档夹中心'
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
  end
end