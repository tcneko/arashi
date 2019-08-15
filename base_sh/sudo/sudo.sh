#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/sudo_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

rm_user() {
  for user in ${rm_user_s}; do
    sed -i "/^${user}/s/^/#/g" /etc/sudoers
  done
}

rm_group() {
  for group in ${rm_group_s}; do
    sed -i "/^%${group}/s/^/#/g" /etc/sudoers
  done
}

add_user() {
  for user in ${add_user_s}; do
    echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers
  done
}

add_group() {
  for group in ${add_group_s}; do
    echo "%${group} ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers
  done
}

main() {
  load_cfg
  rm_user
  rm_group
  add_user
  add_group
}

# main
main

exit 0
