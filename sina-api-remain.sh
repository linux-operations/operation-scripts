#!/bin/bash

# ョ浠ｇ哄ㄧ璇锋浣

PRG="$0"

usage() {
  echo >&2 "usage: $PRG <hosts_file> "
  exit 1
}

[ -z "$1" ] && usage

for i in `cat $1`
do
  echo "$i: "`curl -s 'http://'$i':18088/account/rate_limit_status.json?access_token=2.00SlDQsDdcZIJC94e5308f67sRL13D&uid=1660612723' | python -mjson.tool | grep remaining_ip_hits`
done


