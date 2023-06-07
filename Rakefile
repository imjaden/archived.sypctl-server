#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'lib/utils/rake_instance_methods'
require 'lib/utils/rake_utils_instance_methods'

task default: [:environment]

desc 'bundle exec rake :task_name RACK_ENV=development'
task environment: 'Gemfile.lock' do
  ENV['RACK_ENV'] ||= 'development'
  ENV['RAILS_ENV'] = ENV['RACK_ENV']
  require File.expand_path('../config/boot.rb', __FILE__)

  Rack::Builder.parse_file File.expand_path('../config.ru', __FILE__)
end

require 'sinatra/activerecord/rake'
namespace :db do
  task :load_config do
    require File.expand_path('../config/boot.rb', __FILE__)
  end
end


Dir.glob('lib/tasks/*.rake') { |filepath| load(filepath) }