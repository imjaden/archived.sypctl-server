## 合并 Wehbook

```
request.headers:
{
  "REMOTE_ADDR": "127.0.0.1",
  "REQUEST_METHOD": "POST",
  "REQUEST_PATH": "/api/v4/webhook",
  "PATH_INFO": "/webhook",
  "REQUEST_URI": "/api/v4/webhook",
  "SERVER_PROTOCOL": "HTTP/1.0",
  "HTTP_VERSION": "HTTP/1.0",
  "HTTP_X_FORWARDED_FOR": "47.97.19.33",
  "HTTP_HOST": "sypctl.com",
  "HTTP_CONNECTION": "close",
  "CONTENT_LENGTH": "3897",
  "CONTENT_TYPE": "application/json",
  "HTTP_X_GITLAB_EVENT": "Merge Request Hook",
  "HTTP_X_GITLAB_TOKEN": "Secret123Token",
  "rack.url_scheme": "http",
  "SERVER_NAME": "sypctl.com",
  "SERVER_PORT": "80",
  "QUERY_STRING": "",
  "rack.input": "#<Unicorn::TeeInput:0x005575380a9d00>",
  "unicorn.socket": "#<Kgio::Socket:0x005575380aa6b0>",
  "rack.hijack": "#<Unicorn::HttpParser:0x00557537fe68f0>",
  "rack.errors": "#<File:0x005575372a9b38>",
  "rack.multiprocess": true,
  "rack.multithread": false,
  "rack.run_once": false,
  "rack.version": [
    1,
    2
  ],
  "rack.hijack?": true,
  "SCRIPT_NAME": "/api/v4",
  "SERVER_SOFTWARE": "Unicorn 5.0.1",
  "rack.logger": "#<Logger:0x005575380c1950>",
  "sinatra.commonlogger": true,
  "rack.session": "#<Rack::Session::Abstract::SessionHash:0x005575380c0eb0>",
  "rack.session.options": {
    "path": "/",
    "domain": null,
    "expire_after": null,
    "secure": false,
    "httponly": true,
    "defer": false,
    "renew": false,
    "sidbits": 128,
    "secure_random": "SecureRandom",
    "secret": "baedc032482d673ddf8bde3dd61b6c44082517e851e5e9671f258a8a54efee8f8c0daff37659594736c223329449e56015f22381a82c33479862bcf3f3f0fb80",
    "coder": "#<Rack::Session::Cookie::Base64::Marshal:0x005575609f62a0>"
  },
  "rack.request.cookie_hash": {},
  "rack.session.unpacked_cookie_data": {
    "session_id": "a88ddecc5a80e80df5b2b840ca8ea00781b97228087e29bed5aa19532c635fff"
  },
  "rack.request.query_string": "",
  "rack.request.query_hash": {}
}
request.params:
{
  "captures": [],
  "object_kind": "merge_request",
  "user": {
    "name": "lijunjie",
    "username": "junjie",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png"
  },
  "project": {
    "name": "dianping-scripts",
    "description": "",
    "web_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
    "avatar_url": null,
    "git_ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
    "git_http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git",
    "namespace": "生意加",
    "visibility_level": 0,
    "path_with_namespace": "shengyiplus/dianping-scripts",
    "default_branch": "master",
    "ci_config_path": null,
    "homepage": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
    "url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
    "ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
    "http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git"
  },
  "object_attributes": {
    "id": 1023,
    "target_branch": "master",
    "source_branch": "dev-0.1-ljj",
    "source_project_id": 215,
    "author_id": 3,
    "assignee_id": 3,
    "title": "doc(readme): add readme.md",
    "created_at": "2020-02-28 14:59:36 UTC",
    "updated_at": "2020-02-28 15:11:46 UTC",
    "milestone_id": null,
    "state": "merged",
    "merge_status": "can_be_merged",
    "target_project_id": 215,
    "iid": 2,
    "description": "",
    "updated_by_id": null,
    "merge_error": null,
    "merge_params": {
      "force_remove_source_branch": "0"
    },
    "merge_when_pipeline_succeeds": false,
    "merge_user_id": null,
    "merge_commit_sha": "be7c0435b5e0c8dd3afde22f8b4c477f0139d33c",
    "deleted_at": null,
    "in_progress_merge_commit_sha": null,
    "lock_version": null,
    "time_estimate": 0,
    "last_edited_at": null,
    "last_edited_by_id": null,
    "head_pipeline_id": null,
    "ref_fetched": true,
    "merge_jid": null,
    "source": {
      "name": "dianping-scripts",
      "description": "",
      "web_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
      "avatar_url": null,
      "git_ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "git_http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git",
      "namespace": "生意加",
      "visibility_level": 0,
      "path_with_namespace": "shengyiplus/dianping-scripts",
      "default_branch": "master",
      "ci_config_path": null,
      "homepage": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
      "url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git"
    },
    "target": {
      "name": "dianping-scripts",
      "description": "",
      "web_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
      "avatar_url": null,
      "git_ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "git_http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git",
      "namespace": "生意加",
      "visibility_level": 0,
      "path_with_namespace": "shengyiplus/dianping-scripts",
      "default_branch": "master",
      "ci_config_path": null,
      "homepage": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts",
      "url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "ssh_url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
      "http_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts.git"
    },
    "last_commit": {
      "id": "500537c6d9bb5a4f8f1647d35c2d1321df067f11",
      "message": "doc(readme): add readme.md\n",
      "timestamp": "2020-02-28T22:59:10+08:00",
      "url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts/commit/500537c6d9bb5a4f8f1647d35c2d1321df067f11",
      "author": {
        "name": "jay16",
        "email": "jay_li@intfocus.com"
      }
    },
    "work_in_progress": false,
    "total_time_spent": 0,
    "human_total_time_spent": null,
    "human_time_estimate": null,
    "url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts/merge_requests/2",
    "action": "merge"
  },
  "labels": [],
  "repository": {
    "name": "dianping-scripts",
    "url": "git@gitlab.idata.mobi:shengyiplus/dianping-scripts.git",
    "description": "",
    "homepage": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts"
  },
  "assignee": {
    "name": "lijunjie",
    "username": "junjie",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png"
  },
  "ip": "47.97.19.33",
  "browser": null
}
```

## 查询合并请求

```
GET https://gitlab.idata.mobi/api/v4/projects/215/merge_requests/2
Response(200):
{
  "id": 1023,
  "iid": 2,
  "project_id": 215,
  "title": "doc(readme): add readme.md",
  "description": "",
  "state": "opened",
  "created_at": "2020-02-28T14:59:36.062Z",
  "updated_at": "2020-02-28T14:59:36.124Z",
  "target_branch": "master",
  "source_branch": "dev-0.1-ljj",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "name": "lijunjie",
    "username": "junjie",
    "id": 3,
    "state": "active",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png",
    "web_url": "https://gitlab.idata.mobi/junjie"
  },
  "assignee": {
    "name": "lijunjie",
    "username": "junjie",
    "id": 3,
    "state": "active",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png",
    "web_url": "https://gitlab.idata.mobi/junjie"
  },
  "source_project_id": 215,
  "target_project_id": 215,
  "labels": [],
  "work_in_progress": false,
  "milestone": null,
  "merge_when_pipeline_succeeds": false,
  "merge_status": "unchecked",
  "sha": "500537c6d9bb5a4f8f1647d35c2d1321df067f11",
  "merge_commit_sha": null,
  "user_notes_count": 0,
  "should_remove_source_branch": null,
  "force_remove_source_branch": false,
  "web_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts/merge_requests/2",
  "subscribed": true
}
```

## 提交合并请求

```
PUT https://gitlab.idata.mobi/api/v4/projects/215/merge_requests/2/merge
Response:
{
  "id": 1023,
  "iid": 2,
  "project_id": 215,
  "title": "doc(readme): add readme.md",
  "description": "",
  "state": "merged",
  "created_at": "2020-02-28T14:59:36.062Z",
  "updated_at": "2020-02-28T15:11:46.492Z",
  "target_branch": "master",
  "source_branch": "dev-0.1-ljj",
  "upvotes": 0,
  "downvotes": 0,
  "author": {
    "name": "lijunjie",
    "username": "junjie",
    "id": 3,
    "state": "active",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png",
    "web_url": "https://gitlab.idata.mobi/junjie"
  },
  "assignee": {
    "name": "lijunjie",
    "username": "junjie",
    "id": 3,
    "state": "active",
    "avatar_url": "https://gitlab.idata.mobi/uploads/-/system/user/avatar/3/avatar.png",
    "web_url": "https://gitlab.idata.mobi/junjie"
  },
  "source_project_id": 215,
  "target_project_id": 215,
  "labels": [],
  "work_in_progress": false,
  "milestone": null,
  "merge_when_pipeline_succeeds": false,
  "merge_status": "can_be_merged",
  "sha": "500537c6d9bb5a4f8f1647d35c2d1321df067f11",
  "merge_commit_sha": "be7c0435b5e0c8dd3afde22f8b4c477f0139d33c",
  "user_notes_count": 0,
  "should_remove_source_branch": null,
  "force_remove_source_branch": false,
  "web_url": "https://gitlab.idata.mobi/shengyiplus/dianping-scripts/merge_requests/2",
  "subscribed": true
}
```