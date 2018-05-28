# encoding: utf-8
require "qiniu"
require "fileutils"

module QiniuInstanceMethods
  def upload_file_2_qiniu(local_file)
    config = {
      access_key: ::Setting.qiniu.access_key,
      secret_key: ::Setting.qiniu.secret_key
    }
    key = File.basename(local_file)
    bucket = ::Setting.qiniu.bucket
    ::Qiniu.establish_connection!(config)

    put_policy = ::Qiniu::Auth::PutPolicy.new(bucket)
    uptoken = ::Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = ::Qiniu::Storage.stat(bucket, key)
    if code == 200
      puts "[%s] already exist in [%s] then delete..." % [key, bucket]
      code, result, response_headers = ::Qiniu::Storage.delete(bucket, key)
      raise "Fail delete [%s] in [%s] with qiniu." % [key, bucket] if code != 200
      puts [code, result, response_headers].join(', ')
    else
      puts "[%s] not found in [%s] then upload..." % [key, bucket]
    end

    code, result, response_headers = ::Qiniu::Storage.upload_with_put_policy(put_policy, local_file, key)
    puts "[%s] upload successfully." % key
    return [code, result, response_headers]
  end
end