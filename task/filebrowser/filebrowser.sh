#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/filebrowser.json"
d_filebrowser="/etc/filebrowser"
d_filebrowser_run="/var/lib/filebrowser"

# function
load_cfg() {
  if [[ -r ${f_cfg} ]]; then
    b_enable_serv=$(jq -r ".b_enable_serv" ${f_cfg})
    b_start_serv=$(jq -r ".b_start_serv" ${f_cfg})
  else
    exit 1
  fi
}

install_filebrowser() {
  curl -fsSL https://filebrowser.org/get.sh | bash

  mkdir -p ${d_filebrowser} ${d_filebrowser_run}
  chown -R root: ${d_filebrowser}
  chown -R s_filebrowser: ${d_filebrowser_run}
  chmod 755 ${d_filebrowser} ${d_filebrowser_run}

  systemctl stop filebrowser.service
  systemctl disable filebrowser.service
  cp -f ${d_cur}/filebrowser.service /lib/systemd/system/
  systemctl daemon-reload
}

enable_serv() {
  if ((${b_enable_serv} == 0)); then
    systemctl enable filebrowser.service
  fi
}

start_serv() {
  if ((${b_start_serv} == 0)); then
    systemctl start filebrowser.service
  fi
}

main() {
  load_cfg
  install_filebrowser
  enable_serv
  start_serv
}

# main
main

exit 0
