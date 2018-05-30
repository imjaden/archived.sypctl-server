# encoding: utf-8
module Account
  class OperationLogController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/operation_logs')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '操作日志'
    end

    get '/' do
      @records = OperationLog.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end
  end
end