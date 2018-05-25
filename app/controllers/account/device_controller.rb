# encoding: utf-8
module Account
  class DeviceController < Account::ApplicationController
    set :views, File.join(ENV['VIEW_PATH'], 'account/devices')
    set :layout, :'../../layouts/layout'

    before do
      @page_title = '设备管理'
    end

    get '/' do
      @records = Device.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :index, layout: settings.layout
    end

    get '/:uuid/records' do
      @device = Device.find_by(uuid: params[:uuid])
      @records = @device.records.paginate(page: params[:page], per_page: 15).order(id: :desc)

      haml :records, layout: settings.layout
    end
  end
end