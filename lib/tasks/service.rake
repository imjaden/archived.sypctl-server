# encoding: utf-8

namespace :service do
  task :load do
    services = JSON.parse(File.read("config/services.json"))

    output = services.keys.map do |service|
      start = services[service]['start']
      pid = services[service]['pid']

      <<-EOF.strip_heredoc
        #{service}_start="#{start}"
        #{service}_pid="#{pid}"
      EOF
    end.join("\n")

    File.open(".services", "w:utf-8") { |file| file.puts(output) }
  end
end