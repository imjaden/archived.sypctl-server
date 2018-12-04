# encoding: utf-8
require 'lib/sinatra/extension_redis'
module API
  class ApplicationController < ::ApplicationController
    register Sinatra::Redis

    get '/' do
      'hey: why are you here?'
    end

    protected
  end
end
