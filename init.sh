#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_ins='/opt/sh/arashi'

# function
echo_info() {
  echo -e "\e[1;32m[Info]\e[0m $@"
}

echo_error() {
  echo >&2 -e "\e[1;31m[Error]\e[0m $@"
}

# main
if (($(id -u) == 0)); then
  echo_error 'Please rerun as root'
  exit 1
fi

command -v jq &>/dev/null
if (($? == 0)); then
  echo_error "Please install \"jq\""
  exit 1
fi

if [ ! -d ${d_ins} ]; then
  mkdir -p ${d_ins}
fi
cp -rf *.sh base_sh ext_sh ${d_ins}
cp -rf version "${d_ins}/version_arashi"

echo_info 'Init succeeded if no error is reported above'
echo_info "Please run: sudo bash ${d_ins}/arashi.sh"

exit 0
