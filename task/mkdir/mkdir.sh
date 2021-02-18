#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.02
# last test environment: ubuntu 18.04
# description:

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/mkdir.json"
f_lib="${d_cur}/../../lib/lib_arashi.sh"

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
    mapfile -t l_d_lt < <(jq -r ".l_d_lt[]" ${f_cfg})
    declare -gA a_d_lt_owner
    mapfile -t l_key < <(jq -r ".a_d_lt_owner | keys_unsorted[]" ${f_cfg})
    for key in ${l_key[@]}; do
      a_d_lt_owner[${key}]=$(jq -r ".a_d_lt_owner.${key}" ${f_cfg})
    done
  else
    exit 1
  fi
}

make_dir() {
  for d_lt in ${l_d_lt[@]}; do
    mkdir -p ${d_lt}
    check_sh_retrun
  done
}

chown_dir() {
  for d_lt in ${!a_d_lt_owner[@]}; do
    owner=${a_d_lt_owner[${d_lt}]}
    if [[ -n "${owner}" ]]; then
      chown ${owner} ${d_lt}
      check_sh_retrun
    fi
  done
}

main() {
  load_lib
  load_cfg
  sh_return=0
  make_dir
  chown_dir
}

# main
main

exit ${sh_return}
