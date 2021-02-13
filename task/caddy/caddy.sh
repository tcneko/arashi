#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/caddy.json"
d_caddy="/etc/caddy"

# function
load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    b_enable_serv=$(jq -r ".b_enable_serv" ${f_cfg})
    b_start_serv=$(jq -r ".b_start_serv" ${f_cfg})
  else
    exit 1
  fi
}

install_caddy() {
  echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" >/etc/apt/sources.list.d/caddy-fury.list
  apt -y update
  apt -y install caddy
  mkdir -p ${d_caddy}
  cp -f ${d_cur}/caddyenv ${d_caddy}/
  touch ${d_caddy}/caddyfile
  chown -R s_caddy: ${d_caddy}
  cp -f ${d_cur}/caddy.service /lib/systemd/system/
}

disable_def_serv() {
  systemctl stop caddy-api.service
  systemctl disable caddy-api.service
}

sysd_reload() {
  systemctl daemon-reload
}

enable_serv() {
  if ((${b_enable_serv} == 0)); then
    systemctl enable caddy.service
  else
    systemctl disable caddy.service
  fi
}

start_serv() {
  systemctl stop caddy.service
  if ((${b_start_serv} == 0)); then
    sleep 1
    systemctl start caddy.service
  fi
}

main() {
  load_cfg
  install_caddy
  disable_def_serv
  sysd_reload
  enable_serv
  start_serv
}

# main
main

exit 0
