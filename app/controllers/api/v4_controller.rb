# encoding: utf-8
require 'cgi'
require 'json'
require 'fileutils'
require 'digest/md5'
require 'securerandom'

#
# gitlab 使用
#
module API
  class V4Controller < API::ApplicationController
    before do
      class_logger 
      class_logger 'request.headers:'
      class_logger JSON.pretty_generate(request.env)
      class_logger 'request.params:'
      class_logger JSON.pretty_generate(params)
    end

    options '/*' do
      respond_with_formt_json({message: '接收成功'}, 201)
    end

    route :get, :post, :put, :patch, :delete, '/webhook' do
      merge_state = params.dig(:object_attributes, :state)
      halt_with_format_json({data: "#{merge_state} 不作处理"}, 200) if merge_state != 'opened'

      auto_deal_merge_request_with_wxwork_webhook(params)
      respond_with_formt_json({message: '获取成功'}, 200)
    end

    protected

    def class_logger(message='')
      @class_logger_path ||= File.join(ENV['APP_ROOT_PATH'], 'logs', "#{self.class.to_s.underscore.gsub('/', '-')}.log")
      File.write(@class_logger_path, "#{message}\n", mode: 'a')
      puts message
    end

    def http_action(request_method=:get, url="", headers={}, body={})
      response = HTTParty.send(request_method, URI.escape(url), headers: headers, body: body.to_json)
      responseHash = JSON.parse(response.body) rescue {}
      class_logger
      class_logger "timestamp: #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}"
      class_logger "url:"
      class_logger "#{request_method} #{url}"
      class_logger "params:"
      class_logger JSON.pretty_generate(body) rescue body
      class_logger "response(#{response.code}):"
      class_logger JSON.pretty_generate(responseHash)
      responseHash
    end

    def post_wxwork_webhook(content, mentioned_list=['@all'])
      url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=78424a00-4a56-4544-b7b3-ec1720c5d76c"
      headers = {
        "Content-Type" => "application/json"
      }
      body = {
         "msgtype": "markdown",
         "markdown": {
            "content": content,
            "mentioned_list": mentioned_list
         }
      }
      responseHash = http_action(:post, url, headers, body)
    end

    def get_gitlab_merge_request(params)
      url = "https://gitlab.idata.mobi/api/v4/projects/#{params[:object_attributes][:source_project_id]}/merge_requests/#{params[:object_attributes][:iid]}"
      get_res_hash = http_action(:get, url, {'PRIVATE-TOKEN': 'zuiNRw7NdNrHbHx7Szsz'})
      if get_res_hash['state'] == 'opened'
        commit_message = params.dig(:object_attributes, :title)
        commit_match = commit_message.scan(/merge@(.*?)\((.*?)\): (.*?)$/)
        if commit_match.empty?
          get_res_hash['merge_state'] = 'wait to fix'
        else
          put_res_hash = put_gitlab_merge_request_merge(params)
          get_res_hash['merge_state'] = put_res_hash['state']
        end
      else
        get_res_hash['merge_state'] = "#{get_res_hash['state']} cannot be merge!"
      end
      get_res_hash['merge_state'] = "#{get_res_hash['merge_state']}" if get_res_hash['merge_state'] == 'merged'
      
      get_res_hash
    end

    def put_gitlab_merge_request_merge(params)
      url = "https://gitlab.idata.mobi/api/v4/projects/#{params[:object_attributes][:source_project_id]}/merge_requests/#{params[:object_attributes][:iid]}/merge"
      response_hash = http_action(:put, url, {'PRIVATE-TOKEN': 'zuiNRw7NdNrHbHx7Szsz'})
    end
    
    def gitlab_username(username)
      gitlab_users[username] || username
    end

    def gitlab_users
      @gitlab_users ||= {
        'wangwen' => '王稳',
        'zxw19970514' => '赵晓伟',
        'dengzhicheng' => '邓志成',
        'junjie' => '李俊杰'
      }
    end

    def auto_deal_merge_request_with_wxwork_webhook(params)
      begin_time = Time.now
      response_hash = get_gitlab_merge_request(params)
      commit_message = params.dig(:object_attributes, :title)
      commit_match = commit_message.scan(/merge@(.*?)\((.*?)\): (.*?)$/)

      bot_message = <<-EOF.strip_heredoc
        Gitlab 助手#{commit_match.empty? ? "<font color=\"warning\">拒单😷</font>" : "<font color=\"info\">结单🎉</font>"}
        
        [项目链接](#{params.dig(:project, :homepage)})

        MR 详情列表

        > 项目: #{params.dig(:project, :name)}
        > 提交人: #{gitlab_username(params.dig(:user, :username))}
        > 分支: #{params.dig(:object_attributes, :source_branch)}
        > 状态: #{response_hash.dig('state')}
        > 审查人: <font color="comment">#{gitlab_username(params.dig(:assignee, :username)) || '未指定'}</font>
        > 分支: <font color="comment">#{params.dig(:object_attributes, :target_branch)}</font>
        > 备注: <font color="info">#{commit_message}</font>

        MR 操作流程

      EOF

      if commit_match.empty?
        bot_message += <<-EOF.strip_heredoc
          > Commit检测: <font color="warning">不合规</font>
          > 合并状态: <font color="info">#{response_hash['merge_state']}</font>
          > 操作耗时: <font color="comment">#{(Time.now - begin_time).round(4)}s</font>

          点击查看 [Gitlab Commit规范](https://docs.idata.mobi/corporate-culture/teamwork.html#%E8%AF%B7%E6%B1%82%E5%90%88%E5%B9%B6)
        EOF
      else
        bot_message += <<-EOF.strip_heredoc
          > 编译检测: <font color="comment">Skip</font>
          > 语法检测: <font color="comment">Skip</font>
          > 单元测试: <font color="comment">Skip</font>
          > 操作耗时: <font color="comment">#{(Time.now - begin_time).round(4)}s</font>
          > 合并状态: <font color="info">#{response_hash['merge_state']}</font>
        EOF
      end
      post_wxwork_webhook(bot_message)
    end
  end
end