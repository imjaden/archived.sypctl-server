# encoding: utf-8
require 'timeout'
require 'sinatra/activerecord'

set :database_file, "#{ENV['APP_ROOT_PATH']}/config/database.yaml"
set :database_timezone, :local
ActiveRecord::Base.default_timezone = :local

recursion_require('app/models', /\.rb$/, ENV['APP_ROOT_PATH'], [/base_/])
