# encoding: utf-8
require 'rubygems'
require 'json'
require 'fileutils'

version = JSON.parse(File.read("version.json"))
ENV['APP_VERSION']   = [version['major'], version['minor'], version['commit']].join('.')
ENV['APP_ROOT_PATH'] = File.dirname(File.dirname(__FILE__))
ENV['RACK_ENV']    ||= 'development'
ENV['VIEW_PATH']     = File.join(ENV['APP_ROOT_PATH'], 'app/views')

pids_path = File.join(ENV['APP_ROOT_PATH'], 'tmp', 'pids')
FileUtils.mkdir_p pids_path unless File.exist?(pids_path)

ENV['BUNDLE_GEMFILE'] ||= %(#{root_path}/Gemfile)
require 'rake'
require 'bundler/setup'

Bundler.setup
# Bundler.require(:default)

require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/logger'
require 'active_record'
require 'sprockets'
require "yui/compressor"
require 'unicorn'
require 'settingslogic'


$LOAD_PATH.unshift(ENV['APP_ROOT_PATH'])
$LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/config))
$LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/lib/tasks))
%w(controllers helpers models).each do |path|
  $LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/app/#{path}))
end

require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
# require 'active_support/core_ext/numeric'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric/time'
require 'active_support/cache'
require 'lib/utils/boot.rb'
require 'app/models/setting.rb'

require 'assets_handler'
Time.zone = 'Beijing'

ENV['CACHE_NAMESPACE']  ||= Setting.app_name
ENV['REDIS_URL']        ||= Setting.redis_url
ENV['STARTUP']            = Time.now.to_s
ENV['STARTUP_TIMESTAMP']  = Time.now.to_i.to_s

include Utils::Boot
traverser_settings_yaml_to_env

recursion_require('lib/core_ext', /\.rb$/, ENV['APP_ROOT_PATH'])
recursion_require('app/helpers', /_helper\.rb$/, ENV['APP_ROOT_PATH'])
recursion_require('app/controllers', /_controller\.rb$/, ENV['APP_ROOT_PATH'], [/^application_/])

`echo "#{ENV['APP_VERSION']}" > .app-version`
