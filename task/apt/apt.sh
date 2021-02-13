#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/apt.json"

# function
load_lib() {
  if [[ -r ${f_lib} ]]; then
    source ${f_lib}
  else
    exit 1
  fi
}

load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    mapfile -t l_lsb_support < <(jq -r ".l_lsb_support[]" ${f_cfg})
    b_apt_upgrade=$(jq -r ".b_apt_upgrade" ${f_cfg})
    mapfile -t l_apt_install < <(jq -r ".l_apt_install[]" ${f_cfg})
    mapfile -t l_apt_disable < <(jq -r ".l_apt_disable[]" ${f_cfg})
    mapfile -t l_apt_remove < <(jq -r ".l_apt_remove[]" ${f_cfg})
  else
    exit 1
  fi
}

apt_update() {
  apt update
  check_sh_retrun
}

apt_upgrade() {
  if ((${b_apt_upgrade} == 0)); then
    apt upgrade -y
    check_sh_retrun
  fi
}

apt_install() {
  echo ${l_apt_install[@]}
  apt install -y ${l_apt_install[@]}
  check_sh_retrun
}

apt_diable() {
  for apt_diable in ${l_apt_diable[@]}; do
    apt disable -y ${apt_diable}
    check_sh_retrun
  done
}

apt_remove() {
  apt remove -y ${l_apt_remove[@]}
  check_sh_retrun
}

main() {
  load_lib
  load_cfg
  check_lsb_support
  if (($? != 0)); then
    exit 1
  fi
  sh_return=0
  apt_update
  apt_upgrade
  apt_install
  apt_diable
  apt_remove
}

# main
main

exit ${sh_return}
