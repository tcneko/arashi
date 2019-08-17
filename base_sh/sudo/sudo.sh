#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_sudo='/etc/sudoers'
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
    sed -Ei "/^[[:space:]]*${user}/s/^/#/g" ${cfg_sudo}
  done
}

rm_group() {
  for group in ${rm_group_s}; do
    sed -Ei "/^[[:space:]]*%${group}/s/^/#/g" ${cfg_sudo}
  done
}

add_user() {
  if [[ -n ${add_user_s[@]} ]]; then
    cat ${cfg_sudo} | grep 'add by arashi sudo.sh add_user' &>/dev/null
    if [[ $? -eq 0 ]]; then
      sed -Ei '/add by arashi sudo.sh add_user/,/end by arashi sudo.sh add_user/d' ${cfg_sudo}
    fi
    echo '# add by arashi sudo.sh add_user' >>${cfg_sudo}
    for user in ${add_user_s}; do
      echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" >>${cfg_sudo}
    done
    echo '# end by arashi sudo.sh add_user' >>${cfg_sudo}
  fi
}

add_group() {
  if [[ -n ${add_group_s[@]} ]]; then
    cat ${cfg_sudo} | grep 'add by arashi sudo.sh add_group' &>/dev/null
    if [[ $? -eq 0 ]]; then
      sed -Ei '/add by arashi sudo.sh add_group/,/end by arashi sudo.sh add_group/d' ${cfg_sudo}
    fi
    echo '# add by arashi sudo.sh add_group' >>${cfg_sudo}
    for group in ${add_group_s}; do
      echo "%${group} ALL=(ALL:ALL) NOPASSWD: ALL" >>${cfg_sudo}
    done
    echo '# end by arashi sudo.sh add_group' >>${cfg_sudo}
  fi
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
