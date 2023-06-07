# encoding: utf-8
require 'timeout'
# require 'sinatra/activerecord'

# yaml_path = "#{ENV['APP_ROOT_PATH']}/config/database.yaml"
# yaml_text = YAML.load_file File.read(yaml_path), alias: true
# puts yaml_text.inspect

# set :database_file, "#{ENV['APP_ROOT_PATH']}/config/database.yaml"
# ActiveRecord::Base.default_timezone = :local

set :database_timezone, :local
set :database, {adapter: "mysql2", pool: 5, encoding: 'utf-8', database: "sypctl_pro", host: "127.0.0.1", port: 3306, username: "root", password: "Root@321"}

recursion_require('app/models', /\.rb$/, ENV['APP_ROOT_PATH'], [/base_/])

ActiveRecord::Base.establish_connection(
    adapter:  'mysql2',
    host: '127.0.0.1',
    username: 'root',
    password: 'Root@321',
    database: 'sypctl_pro',
    encoding: 'utf8',
    pool: 5
)