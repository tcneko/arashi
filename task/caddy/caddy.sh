#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/caddy.json"
d_caddy="/etc/caddy"
d_caddy_run="/var/lib/caddy"
f_env="/etc/default/caddy"

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
    b_enable_serv=$(jq -r ".b_enable_serv" ${f_cfg})
    b_start_serv=$(jq -r ".b_start_serv" ${f_cfg})
  else
    exit 1
  fi
}

install_caddy() {
  dpkg -s caddy &>/dev/null
  if (($? != 0)); then
    echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" >/etc/apt/sources.list.d/caddy-fury.list
    apt -y update
    apt -y install caddy
  fi
  rm -f /etc/caddy/Caddyfile

  cp -f ${d_cur}/caddy_env ${f_env}

  mkdir -p ${d_caddy} ${d_caddy_run}
  chown -R root: ${d_caddy}
  chown -R s_caddy: ${d_caddy_run}
  chmod 755 ${d_caddy} ${d_caddy_run}

  systemctl stop caddy-api.service
  systemctl disable caddy-api.service
  systemctl stop caddy.service
  systemctl disable caddy.service
  cp -f ${d_cur}/caddy.service /lib/systemd/system/
  systemctl daemon-reload
}

enable_serv() {
  if ((${b_enable_serv} == 0)); then
    systemctl enable caddy.service
  fi
}

start_serv() {
  if ((${b_start_serv} == 0)); then
    systemctl start caddy.service
  fi
}

main() {
  load_lib
  load_cfg
  install_caddy
  enable_serv
  start_serv
}

# main
main

exit 0
