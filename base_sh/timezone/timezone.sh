#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_cur="$(dirname ${BASH_SOURCE[0]})"
cfg_main="${dir_cur}/timezone_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
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
