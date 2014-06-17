#!/bin/bash

# 一个简单的备份脚本

usage() {
  echo >&2 "usage: $PRG <dir|file>"
  exit 1
}

test -z "$1" && usage

test -d ~/backup || mkdir -v ~/backup
name=`basename $1`
test -e $1 && tar -czf ~/backup/$name.`date +%Y-%m-%d_%H-%M-%S`.tar.gz $1
