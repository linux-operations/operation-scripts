#!/bin/bash

# 安装应用
package=crm-0.0.1-SNAPSHOT-distribution.tar.gz
download_url='http://ops.pp.cc:3305/jenkins/job/crm/lastStableBuild/cc.pp.api$crm/artifact/cc.pp.api/crm/0.0.1-SNAPSHOT/'$package
project_dir=crm
confDir=$project_dir/conf

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
  tar -xf $package
  test -d $project_dir || echo $project_dir' is not exist.' || exit 1
  conf
  rm -f $package
}

conf() {
  echo "Replace conf file..."
  customConfDir=~/.$project_dir
  if [ -d $customConfDir ]; then
    for i in $customConfDir/*; do
      customConfFile=$i; customConfFileName=`basename $i`
      if [ -f $confDir/$customConfFileName ]; then
        echo "Replace conf file $confDir/$customConfFileName, use $customConfDir/$customConfFileName"
        rm $confDir/$customConfFileName;
        ln -s $customConfDir/$customConfFileName $confDir/$customConfFileName
      else
        echo "$confDir/$customConfFileName is not exist."
        exit -1
      fi
    done
  fi
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

