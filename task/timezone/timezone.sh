#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/timezone.json"

# function
load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    timezone=$(jq -r ".timezone" ${f_cfg})
  else
    exit 1
  fi
}

main() {
  load_cfg
  timedatectl set-timezone ${timezone}
}

# main
main

exit 0
