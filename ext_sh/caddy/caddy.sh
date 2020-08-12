#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/caddy_cfg.sh"
dir_git='/opt/git'

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

ins_caddy() {
  echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
  apt update
  apt install caddy
  sed -i "s/User=caddy/User=s_caddy/g" /lib/systemd/system/caddy.service
  sed -i "s/Group=caddy/Group=s_caddy/g" /lib/systemd/system/caddy.service
}

sysd_reload() {
  systemctl daemon-reload
}

enable_serv() {
  if [[ ${flag_enable_serv} -eq 0 ]]; then
    systemctl enable caddy.service
  fi
}

start_serv() {
  if [[ ${flag_start_serv} -eq 0 ]]; then
    systemctl stop caddy.service
    sleep 1
    systemctl start caddy.service
  fi
}

main() {
  load_cfg
  ins_caddy
}

# main
main

exit 0
