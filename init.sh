#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/arashi.json"
f_lib="${d_cur}/lib/lib_arashi.sh"
d_ins='/opt/sh/arashi'

# function
load_lib() {
  if [[ -r ${f_lib} ]]; then
    source ${f_lib}
  else
    exit 1
  fi
}

check_root_exit() {
  if (($(id -u) == 0)); then
    echo_error 'Please rerun as root'
    exit 1
  fi
}

check_command_exit() {
  command -v jq &>/dev/null
  if (($? == 0)); then
    echo_error "Please install \"jq\""
    exit 1
  fi
}

install_arashi() {
  mkdir -p ${d_ins}

  cp -rf lib task arashi.sh arashi.json ${d_ins}
  cp -rf version ${d_ins}/version_arashi

  echo_info 'Init succeeded if no error is reported above'
  echo_info "Please run: sudo bash ${d_ins}/arashi.sh"
}

main() {
  load_lib
  check_root_exit
  check_command_exit
  install_arashi
}

# main
main

exit 0
