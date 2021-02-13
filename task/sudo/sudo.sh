#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/sudo_cfg.sh"
f_sudo='/etc/sudoers'

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
    mapfile -t l_rm_user < <(jq -r ".l_rm_user[]" ${f_cfg})
    mapfile -t l_rm_group < <(jq -r ".l_rm_group[]" ${f_cfg})
    mapfile -t l_add_user < <(jq -r ".l_add_user[]" ${f_cfg})
    mapfile -t l_add_group < <(jq -r ".l_add_group[]" ${f_cfg})
  else
    exit 1
  fi
}

rm_def_user() {
  for user in ${l_rm_user[@]}; do
    sed -Ei "/^[[:space:]]*${user}.*ALL[[:space:]]*$/s/^/#/g" ${f_sudo}
    check_sh_retrun
  done
}

rm_def_group() {
  for group in ${l_rm_group[@]}; do
    sed -Ei "/^[[:space:]]*%${group}.*ALL[[:space:]]*$/s/^/#/g" ${f_sudo}
    check_sh_retrun
  done
}

add_user() {
  if [[ -n ${l_add_user[@]} ]]; then
    sed -Ei '/add by arashi sudo.sh add_user/,/end by arashi sudo.sh add_user/d' ${f_sudo}
    echo '# add by arashi sudo.sh add_user' >>${f_sudo}
    for user in ${l_add_user[@]}; do
      echo "${user} ALL=(ALL:ALL) NOPASSWD: ALL" >>${f_sudo}
    done
    echo '# end by arashi sudo.sh add_user' >>${f_sudo}
    check_sh_retrun
  fi
}

add_group() {
  if [[ -n ${l_add_group[@]} ]]; then
    sed -Ei '/add by arashi sudo.sh add_group/,/end by arashi sudo.sh add_group/d' ${f_sudo}
    echo '# add by arashi sudo.sh add_group' >>${f_sudo}
    for group in ${l_add_group[@]}; do
      echo "%${group} ALL=(ALL:ALL) NOPASSWD: ALL" >>${f_sudo}
    done
    echo '# end by arashi sudo.sh add_group' >>${f_sudo}
    check_sh_retrun
  fi
}

main() {
  load_lib
  load_cfg
  sh_return=0
  rm_def_user
  rm_def_group
  add_user
  add_group
}

# main
main

exit ${sh_return}
