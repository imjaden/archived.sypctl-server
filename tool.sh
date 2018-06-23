#!/usr/bin/env bash
#
########################################
#  
#  SYPCTL Server Command Tool
#
########################################
#
# Usage:
#
# bash /tool.sh {config|start|stop|start_redis|stop_redis|restart|deploy}
#
#
# Crontab env:
#
# make sure the commands that used in this script will be valid! 
# the below tips should be obeyed:
#
# 1. load .env-files first
# 2. implement the env $PATH to let the commands in script can be find
# 3. check it by hand and then within crontab job
# 
#     bash tool.sh commands:version
# 

#
# script env
#
app_root_path="$(pwd)"
export LANG=zh_CN.UTF-8
test -f .env-files && while read filepath; do
    test -f "${filepath}" && source "${filepath}"
done < .env-files
source lib/utils/toolsh_common_functions.sh
cd ${app_root_path}

fun_configuration_guides ".app-port" "运行端口号"  "4567"
app_default_port=$(cat .app-port)
app_port=${2:-${app_default_port}}

unicorn_config_file=config/unicorn.rb
unicorn_pid_file=tmp/pids/unicorn.pid

cd "${app_root_path}" || exit 1
case "$1" in
    state)
        title "## 检测当前部署情况："
        test -f .app-port && echo "- 运行端口号: $(cat .app-port)" || echo "- 未配置运行端口号"
        test -f .env-files && {
            echo "- 上下文环境文档："
            cat .env-files
        } || echo "- 未配置上下文环境文档"


        title "## 检测进程运行状态："
        if [[ -f ${unicorn_pid_file} ]]; then
            pid=$(cat ${unicorn_pid_file})
            /bin/ps ax | awk '{print $1}' | grep -e "^${pid}$" &> /dev/null
            if [[ $? -eq 0 ]]; then
                echo "- sypctl 服务运行中($pid)"
            else
                rm -f ${unicorn_pid_file}
                echo "- sypctl 服务未运行"
            fi
        else
            echo "- sypctl 服务未运行"
        fi
    ;;
    deploy)
        bash $0 state
        echo

        test -f .app-port && current_app_port=$(cat .app-port)
        read -p "请输入运行端口号，默认 4567: " user_input
        echo ${user_input:-4567} > .app-port

        if [[ -f ~/.bash_profile ]]; then
            [[ $(uname -s) = "Darwin" ]] && env_path=$(greadlink -f ~/.bash_profile) || env_path=$(readlink -f ~/.bash_profile)
            echo "${env_path}" > .env-files
        fi

        title "$ bundle install"
        bundle install

        bash $0 restart
    ;;
    git:pull|upgrade)
        git_current_branch=$(git rev-parse --abbrev-ref HEAD)
        echo "$ git pull origin ${git_current_branch}"
        git pull origin ${git_current_branch}
    ;;
    start)
        test -d logs || mkdir -p logs
        fun_print_table_header "start process" "process" "status"
        command_text="bundle exec unicorn -c ${unicorn_config_file} -p ${app_port} -E production -D"
        process_start "${unicorn_pid_file}" "unicorn" "${command_text}"
        fun_print_table_footer
    ;;
    stop)
        fun_print_table_header "stop process" "process" "status"
        process_stop "${unicorn_pid_file}" "unicorn"
        fun_print_table_footer
    ;;
    restart)
        bash $0 stop
        bash $0 start
    ;;
    restart:hot)
        cat "${unicorn_pid_file}" | xargs -I pid kill -USR2 pid
    ;;
    *)
        echo "warning: unkown params - $@"
    ;;
esac
