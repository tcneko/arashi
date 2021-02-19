#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/sftpgo.json"
d_sftpgo="/etc/sftpgo"
d_sftpgo_run="/var/lib/sftpgo"
d_pkg="/opt/pkg/sftpgo"
f_pkg="${d_pkg}/sftpgo_2.0.2-1_amd64.deb"
pkg_link="https://github.com/drakkan/sftpgo/releases/download/v2.0.2/sftpgo_2.0.2-1_amd64.deb"

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

install_sftpgo() {
  dpkg -s sftpgo &>/dev/null
  if (($? != 0)); then
    mkdir -p ${d_pkg}
    curl -sLo ${f_pkg} ${pkg_link}
    apt install ${f_pkg}
  fi
  mkdir -p ${d_sftpgo} ${d_sftpgo_run}

  chown root: ${d_sftpgo}
  chmod 755 ${d_sftpgo}

  chown s_sftpgo: ${d_sftpgo_run}
  chmod 755 ${d_sftpgo_run}

  systemctl disable sftpgo.service
  systemctl stop sftpgo.service
  cp -f ${d_cur}/sftpgo.service /lib/systemd/system/
  systemctl daemon-reload
}

enable_serv() {
  if ((${b_enable_serv} == 0)); then
    systemctl enable sftpgo.service
  fi
}

start_serv() {
  if ((${b_start_serv} == 0)); then
    systemctl start sftpgo.service
  fi
}

main() {
  load_lib
  load_cfg
  check_lsb_support
  if (($? != 0)); then
    exit 1
  fi
  install_sftpgo
  enable_serv
  start_serv
}

# main
main

exit 0
