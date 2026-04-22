#!/bin/sh

# 定义别名（方便手动调用）
alias menu='/usr/bin/backstageplanning'

# 防止重复执行（解决双重加载问题）
if [ -t 0 ] && [ -z "$MENU_LOADED" ]; then
    export MENU_LOADED=1
    if [ -x /usr/bin/backstageplanning ]; then
        /usr/bin/backstageplanning
    fi
fi