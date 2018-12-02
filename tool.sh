#!/usr/bin/env bash
#
########################################
#  
#  SYPCTL Server Command Tool
#
########################################

app_root_path="$(pwd)"
export LANG=zh_CN.UTF-8
test -f .env-files && while read filepath; do
    test -f "${filepath}" && source "${filepath}"
done < .env-files
source lib/scripts/toolsh_common_functions.sh
test -f .services && source .services

cd "${app_root_path}" || exit 1
case "$1" in
    config)
        mkdir -p db/{backups,snapshots}
        mkdir -p logs/{crontab,archived}
        mkdir -p tmp/pids

        if [[ -f config/services.json ]]; then
            bundle exec rake service:load RACK_ENV=production 
            test -f .services && source .services
        else
            echo "Warning: config/services.json 不存在请配置，具有可参考: config/services.json.example"
            exit 2
        fi
    ;;
    upgrade)
        echo -e "## 下拉最新代码\n"
        local_modified=$(git status -s)
        if [[ ! -z "${local_modified}" ]]; then
            git status
            read -p "本地代码有修改，可能会产生冲突，是否继续？y/n " user_input
            if [[ "${user_input}" != "y" ]]; then
                echo "退出操作！"
                exit 2
            fi

            git checkout ./
            echo "已撤销本地代码修改"
        fi
        bash $0 git:pull

        echo -e "\n## 刷新项目配置\n"
        bash $0 config

        echo -e "\n## 检查项目配置\n"
        bundle exec rake boom:setting RACK_ENV=production 

        echo -e "\n## 刷新定时任务\n"
        bundle exec whenever --update-crontab

        echo -e "\n## Migrate 业务数据表\n"
        bundle exec rake db:migrate RACK_ENV=production

        echo -e "\n## 适配数据库快照\n"
        bundle exec rake mysql:snapshot:load RACK_ENV=production

        echo -e "\n## 重启 App 服务\n"
        bash $0 restart
    ;;
    git:pull)
        git_current_branch=$(git rev-parse --abbrev-ref HEAD)
        echo "$ git pull origin ${git_current_branch}"
        git pull origin ${git_current_branch}
    ;;
    crontab:update)
        bundle exec whenever --update-crontab
    ;;
    start:dev)
        bundle exec unicorn -p 8085
    ;;
    start)
        bash $0 config

        fun_print_table_header "start process" "process" "status"
        bash $0 redis:start
        bash $0 unicorn:start
        fun_print_table_footer
    ;;
    stop)
        fun_print_table_header "stop process" "process" "status"
        bash $0 unicorn:stop
        fun_print_table_footer
    ;;
    restart)
        bash $0 stop
        sleep 2
        bash $0 start
    ;;
    restart:hot)
        cat "${unicorn_pid}" | xargs -I pid kill -USR2 pid
    ;;
    *:start|*:stop|*:restart)
        service=${1%:*}
        operate=${1#*:}
        var_start="${service}_start"
        var_pid="${service}_pid"

        if [[ ${operate} = "restart" ]]; then
            bash $0 "${service}:stop"
            sleep 1
            bash $0 "${service}:start"
        else
            test ${operate} = "start" \
                && process_start "${!var_pid}" "${service}" "${!var_start}" \
                || process_stop "${!var_pid}" "${service}"
        fi
    ;;
    *)
        echo "warning: unkown params - $@"
    ;;
esac
