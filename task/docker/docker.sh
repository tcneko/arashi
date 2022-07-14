#!/bin/bash

# author: tcneko <tcneko@outlook.com>
# start from: 2022.07
# last test environment: ubuntu 20.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/docker.json"
docker_cfg_dir="/etc/docker"

return_code=0

# function
update_return_code() {
  if ((${return_code} == 0)); then
    if (($1 != 0)); then
      return_code=1
    fi
  fi
}

load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    cfg_json=$(cat ${cfg_file})
    update_cfg=$(echo ${cfg_json} | jq -r ".update_cfg")
    start_service=$(echo ${cfg_json} | jq -r ".start_service")
    enable_service=$(echo ${cfg_json} | jq -r ".enable_service")
  else
    return 1
  fi
}

stop_systemd_service() {
  systemctl status docker.service &>/dev/null
  if (($? == 0)); then
    systemctl stop docker.service
  fi
}

start_systemd_service() {
  if ((${start_service} == 0)); then
    systemctl start docker.service
  fi
}

enable_systemd_service() {
  if ((${enable_service} == 0)); then
    systemctl enable docker.service
  else
    systemctl disable docker.service
  fi
}

install_docker_cfg() {
  mkdir -p ${docker_cfg_dir} &&
    cp -f ${cur_dir}/daemon.json ${docker_cfg_dir} &&
    chown root: ${docker_cfg_dir}/daemon.json &&
    chmod 644 ${docker_cfg_dir}/daemon.json
  update_return_code $?
}

main() {
  load_cfg
  if (($? != 0)); then
    update_return_code 1
    return 1
  fi
  stop_systemd_service
  update_docker_cfg
  start_systemd_service
  enable_systemd_service
}

# main
main

exit ${return_code}
