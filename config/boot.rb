# encoding: utf-8
require 'rubygems'

ENV['APP_ROOT_PATH'] = File.dirname(File.dirname(__FILE__))
ENV['RACK_ENV']    ||= 'development'
ENV['VIEW_PATH']     = File.join(ENV['APP_ROOT_PATH'], 'app/views')

begin
  ENV['BUNDLE_GEMFILE'] ||= %(#{root_path}/Gemfile)
  require 'rake'
  require 'bundler'
  Bundler.setup
rescue => e
  puts e.backtrace && exit
end
Bundler.require(:default, ENV['RACK_ENV'])

$LOAD_PATH.unshift(ENV['APP_ROOT_PATH'])
$LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/config))
$LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/lib/tasks))
%w(controllers helpers models).each do |path|
  $LOAD_PATH.unshift(%(#{ENV['APP_ROOT_PATH']}/app/#{path}))
end

require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/date'
require 'active_support/core_ext/numeric/time'
require 'active_support/cache'
require 'config/asset_handler'
require 'lib/utils/boot.rb'
include Utils::Boot

require 'asset_handler'
Time.zone = 'Beijing'

recursion_require('app/helpers', /_helper\.rb$/, ENV['APP_ROOT_PATH'])
recursion_require('app/controllers', /_controller\.rb$/, ENV['APP_ROOT_PATH'], [/^application_/])

def _traverse_hash(result_hash = {}, hsh = {}, ancestors_hash = {}, parent_item = nil)
  hsh.each_pair do |k, v|
    uuid = SecureRandom.uuid
    # puts "k: #{k}, parent: #{parent_item}, uuid: #{uuid}"
    ancestors_hash[uuid] = parent_item ? Marshal.load(Marshal.dump(ancestors_hash[parent_item])) : []
    ancestors_hash[uuid].push(k)
    if v.is_a?(Hash)
      _traverse_hash(result_hash, v, ancestors_hash, uuid)
    else
      result_hash[ancestors_hash[uuid].join(".")] = "#{v}"
      # puts "#{ancestors_hash[uuid].join(".")}:#{v}"
    end
  end
end

settings_path = File.join(ENV['APP_ROOT_PATH'], 'config/setting.yaml')
settings_hash = YAML.load(IO.read(settings_path))
settings_json_path = File.join(ENV['APP_ROOT_PATH'], "config/settings-#{ENV['RACK_ENV']}.json")
unless File.exists?(settings_json_path)
  result_hash = {}
  _traverse_hash(result_hash, settings_hash[ENV['RACK_ENV']])
  File.open(settings_json_path, "w:utf-8") { |file| file.puts(result_hash.to_json) }
end
settings_json_hash = JSON.parse(IO.read(settings_json_path))
settings_json_hash.each_pair do |key, value|
  ENV[key] = value
end