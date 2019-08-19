#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_main="$(dirname ${BASH_SOURCE[0]})/apt_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
  else
    exit 1
  fi
}

apt_upgrade() {
  if [[ ${flag_apt_upgrade} -eq '0' ]]; then
    apt upgrade -y
  fi
}

apt_install() {
  for apt_install in ${apt_install_s[@]}; do
    apt install -y ${apt_install}
  done
}

apt_diable() {
  for apt_diable in ${apt_diable_s[@]}; do
    apt disable -y ${apt_install}
  done
}

apt_remove() {
  for apt_diable in ${apt_diable_s[@]}; do
    apt disable -y ${apt_install}
  done
}

main() {
  load_cfg
  apt_upgrade
  apt_install
  apt_diable
  apt_remove
}

# main
main

exit 0
