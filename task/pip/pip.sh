#!/bin/bash

# author: tcneko <tcneko@outlook.com>
# start from: 2022.06
# last test environment: ubuntu 20.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/pip.json"

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
    update_pip=$(echo ${cfg_json} | jq -r ".update_pip")
    update_package=$(echo ${cfg_json} | jq -r ".update_package")
    mapfile -t package_list < <(echo ${cfg_json} | jq -r ".package_list[]")
  else
    return 1
  fi
}

update_pip() {
  if ((${update_pip} == 0)); then
    pip install --upgrade pip
    update_return_code $?
  fi
}

install_package() {
  if ((${update_package} == 0)); then
    pip install ${package_list[@]}
  else
    pip install --upgrade ${package_list[@]}
  fi
  update_return_code $?
}

main() {
  load_cfg
  if (($? != 0)); then
    update_return_code 1
    return 1
  fi
  update_pip
  install_package
}

# main
main

exit ${return_code}
