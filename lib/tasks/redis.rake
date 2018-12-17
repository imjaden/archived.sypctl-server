# encoding: utf-8
require 'lib/sinatra/extension_redis'

namespace :redis do
  task load: :environment do
    register Sinatra::Redis

    if !ENV['data_path'] || !File.exists?(ENV['data_path'])
      puts "Error: 数据文件不存在 #{ENV['data_path']}"
      exit 1
    end

    unless ENV['redis_key']
      puts "Error: 请提供 redis key"
      exit 1
    end

    IO.readlines(ENV['data_path']).each_slice(2) do |arr|
      key, value = arr.map { |line| line.gsub(/"/, "").split(/\s+/).last }
      puts "#{key}: #{value}"
      redis.hset(ENV['redis_key'], key, value)
    end
  end
end