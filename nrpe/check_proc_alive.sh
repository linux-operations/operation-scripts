#!/bin/bash

#
# 用户Nagios的判断进程是否存在的脚本
# 参数：
#   $1 进程关键字
# 返回值：
#   0: OK 一切正常
#   2: Critical
#


pid=`ps aux | grep $1 | grep -v grep | grep -v $0 | awk '{print $2}'`
if [ -z "$pid" ]; then
  echo "Critical! Process is died."
  exit 2
else
  echo "OK! Process is alive."
  exit 0
fi
