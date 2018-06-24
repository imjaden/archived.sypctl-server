#!/usr/bin/env bash
#
# current app: default
#
# Usage:
# ./crontab_jobs.sh {0015,0300,1:hour,5:minutes}
#

app_root_path="$(pwd)"
export LANG=zh_CN.UTF-8
test -f .env-files && while read filepath; do
    test -f "${filepath}" && source "${filepath}"
done < .env-files
cd ${app_root_path}

case "$1" in
    5:minutes)
        RACK_ENV=production bundle exec rake monitor:device >> logs/crontab/monitor_device.log 2>&1
    ;;
    *)
    echo "$(date) - unkown params: $1"
    ;;
esac
