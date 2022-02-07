#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/syncthing.json"
d_syncthing="/etc/syncthing"

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
    b_enable_serv=$(jq -r ".b_enable_serv" ${f_cfg})
    b_start_serv=$(jq -r ".b_start_serv" ${f_cfg})
  else
    exit 1
  fi
}

install_syncthing() {
  dpkg -s syncthing &>/dev/null
  if (($? != 0)); then
    curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
    echo "deb https://apt.syncthing.net/ syncthing stable" >/etc/apt/sources.list.d/syncthing.list
    apt -y update
    apt -y install syncthing
  fi
  mkdir -p ${d_syncthing}
  chown -R s_syncthing: ${d_syncthing}

  systemctl stop syncthing.service
  systemctl disable syncthing.service
  cp -f ${d_cur}/syncthing.service /lib/systemd/system/
  systemctl daemon-reload
}

enable_serv() {
  if ((${b_enable_serv} == 0)); then
    systemctl enable syncthing.service
  fi
}

start_serv() {
  if ((${b_start_serv} == 0)); then
    systemctl start syncthing.service
  fi
}

main() {
  load_lib
  load_cfg
  install_syncthing
  enable_serv
  start_serv
}

# main
main

exit 0
