#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${dir_cur}/caddy_cfg.sh"

# function
load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    source ${f_cfg}
  else
    exit 1
  fi
}

ins_caddy() {
  echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
  apt update
  apt install caddy
  cp -f ${d_cur}/caddy.service /lib/systemd/system/
}

sysd_reload() {
  systemctl daemon-reload
}

disable_def_serv() {
  systemctl disable caddy-api.service
  systemctl disable caddy-api.service
}

enable_serv() {
  if [[ ${flag_enable_serv} -eq 0 ]]; then
    systemctl enable caddy.service
  else
    systemctl disable caddy.service
  fi
}

start_serv() {
  systemctl stop caddy.service
  if [[ ${flag_start_serv} -eq 0 ]]; then
    sleep 1
    systemctl start caddy.service
  fi
}

main() {
  load_cfg
  ins_caddy
  disable_def_serv
  sysd_reload
  enable_serv
  start_serv
}

# main
main

exit 0
