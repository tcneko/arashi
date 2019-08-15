#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/timezone_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
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
