# encoding: utf-8
module Account
  class FileBackupController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/file_backups')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '文件备份'
    end

    get '/' do
      haml :index, layout: settings.layout
    end
  end
end