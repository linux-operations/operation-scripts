#!/bin/bash

# 安装service_timer应用

package=sina-messageReceive-0.0.1-SNAPSHOT-distribution.tar.gz
download_url='http://ops.pp.cc:3305/jenkins/job/sina-messageReceive/lastStableBuild/cc.pp$sina-messageReceive/artifact/cc.pp/sina-messageReceive/0.0.1-SNAPSHOT/'$package
project_dir=sina-messageReceive

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

script_dir=`dirname $PRG`

usage() {
  echo >&2 "usage: $PRG <command> [args]"
  echo 'Valid commands: install, uninstall'
  exit 1
}

install() {
  rm -f $package
  wget $download_url -O $package
  $script_dir/backup.sh $project_dir && rm -rf $project_dir
  tar -xzf $package
  test -d $project_dir || echo $project_dir' is not exist.' || exit 1
  rm -f $package
}

uninstall() {
  rm -rf $project_dir
}

case $1 in
  (install)
    install
    ;;
  (uninstall)
    uninstall
    ;;
  (*)
    echo >&2 "$PRG: error: unknown command '$1'"
    usage
    ;;
esac

