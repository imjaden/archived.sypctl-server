require 'net/smtp'
require 'settingslogic'

class String
  def strip_mail_heredoc
    indent = split(/\n/).first.scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

module Mail
  module Methods
    def send_email(from, to = [], subject, mail_body)
      to.uniq!
      if to.nil? || to.empty?
        puts %(send_email failed for to is empty?)
        return
      end

      marker = 'AUNIQUEMARKER'
      mail_content = <<-EOF.strip_mail_heredoc
        From: #{from}
        To: #{to.join(',')}
        Subject: #{subject}
        MIME-Version: 1.0
        Content-Type: multipart/mixed; boundary=#{marker}
        --#{marker}
        Content-Type: text/html

        #{mail_body}
        --#{marker}
      EOF

      res = ''
      Net::SMTP.start('smtp.ym.163.com', 25, 'localhost', Setting.email.username, Setting.email.password) do |smtp|
        res = smtp.send_message mail_content, Setting.email.username, to
      end
      res
    end

    def send_rake_crashed_email(exception, task_command, source_file = __FILE__, line_number = __LINE__)
      from = %(【#{Setting.website.title}】 <#{Setting.email.username}>)
      to = Setting.notify.developer.email
      subject = %(#{Setting.website.title} Rake Crashed (#{Time.now.strftime('%a %m/%d/%y')}))

      attachment_path = File.join(ENV['APP_ROOT_PATH'], 'tmp', task_command + '.ex')
      File.open(attachment_path, 'w:utf-8') { |file| file.puts(exception.backtrace) }
      attachment_name = File.basename(attachment_path)

      human_exception = exception.backtrace.find_all { |info| info.include?(ENV['APP_ROOT_PATH']) }
      human_exception = exception.backtrace.first(15) if human_exception.empty?

      marker = 'AUNIQUEMARKER'
      mail_body = <<-EOF.strip_mail_heredoc
        file: #{source_file}(#{line_number})<br>
        command: `RACK_ENV=production bundle exec #{task_command}`<br>
        message: #{exception.message}<br>
        backtraces: <br>
        #{human_exception.compact.join('<br>')}

        --#{marker}
        Content-Type: multipart/mixed; name=\"#{attachment_path}\"
        Content-Transfer-Encoding:base64
        Content-Disposition: attachment; filename="#{attachment_name}"

        #{[File.read(attachment_path)].pack('m')}
      EOF

      send_email(from, to, subject, mail_body)
    rescue => e
      puts format('Error#send_rake_crashed_email: %s', e.message)
    end


    def send_email(from, to = [], subject, mail_body)
      to.uniq!
      if to.nil? || to.empty?
        puts %(send_email failed for to is empty?)
        return
      end

      marker = 'AUNIQUEMARKER'
      mail_content = <<-EOF.strip_mail_heredoc
        From: #{from}
        To: #{to.join(',')}
        Subject: #{subject}
        MIME-Version: 1.0
        Content-Type: multipart/mixed; boundary=#{marker}
        --#{marker}
        Content-Type: text/html

        #{mail_body}
        --#{marker}
      EOF

      res = ''
      Net::SMTP.start('smtp.ym.163.com', 25, 'localhost', Setting.email.username, Setting.email.password) do |smtp|
        res = smtp.send_message mail_content, Setting.email.username, to
      end
      res
    end

    def deliver_email(from, to = [], subject, mail_content, options)
      to.uniq!
      if to.nil? || to.empty?
        puts %(send_email failed for to is empty?)
        return
      end

      marker = 'AUNIQUEMARKER'
      mail_body = <<-EOF.strip_mail_heredoc
        From: #{from}
        To: #{to.join(',')}
        Subject: #{subject}
        MIME-Version: 1.0
        Content-Type: multipart/mixed; boundary=#{marker}
        --#{marker}
        Content-Type: text/html

        #{mail_content}
        --#{marker}
      EOF

      options[:attachment_path] ||= []
      options[:attachment_path] = [options[:attachment_path]] unless options[:attachment_path].is_a?(Array)
      options[:attachment_path].uniq.each do |attachment_path|
        next unless File.exists?(attachment_path)

        mail_body += "\n"
        attachment_content = <<-EOF.strip_mail_heredoc
          --#{marker}
          Content-Type: multipart/mixed; name=\"#{attachment_path}\"
          Content-Transfer-Encoding:base64
          Content-Disposition: attachment; filename="#{File.basename(attachment_path)}"
        EOF
        mail_body += "\n"
        mail_body += attachment_content
        mail_body += "\n"
        mail_body += [File.read(attachment_path)].pack('m')
      end

      options[:username] ||= Setting.email.username
      options[:password] ||= Setting.email.password
      Net::SMTP.start('smtp.ym.163.com', 25, 'localhost', options[:username], options[:password]) do |smtp|
        return smtp.send_message mail_body, options[:username], to
      end
    end
  end
end
