require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root")
results = client.query("show databases;")
puts results.to_s