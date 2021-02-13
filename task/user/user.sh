#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/user.json"

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
    base_id_nor=$(jq -r ".base_id_nor" ${f_cfg})
    base_id_sys=$(jq -r ".base_id_sys" ${f_cfg})
    mapfile -t l_nor_user < <(jq -r ".l_nor_user[]" ${f_cfg})
    mapfile -t l_sys_user < <(jq -r ".l_sys_user[]" ${f_cfg})
    declare -gA a_nor_user_pass
    mapfile -t l_key < <(jq -r ".a_nor_user_pass | keys_unsorted[]" ${f_cfg})
    for key in ${l_key[@]}; do
      a_nor_user_pass[${key}]=$(jq -r ".a_nor_user_pass.${key}" ${f_cfg})
    done
  else
    exit 1
  fi
}

check_func_return() {
  if (($? != 0)); then
    func_return=1
  fi
}

check_func_return_r() {
  if (($? == 0)); then
    func_return=1
  fi
}

add_user_c() {
  id_add=$(echo -n ${user} | md5sum | sed 's/[^0-9]//g;s/.*\(...\)$/\1/')
  if [[ $2 == 'nor' ]]; then
    id=$((${id_add} + ${base_id_nor}))
  elif [[ $2 == 'sys' ]]; then
    id=$((${id_add} + ${base_id_sys}))
  else
    return 1
  fi

  id $1 &>/dev/null
  if (($? == 0)); then
    if (($(id -u $1) == $id && $(id -g $1) == $id)); then
      return 0
    fi
  fi

  func_return=0
  # username & uid
  cat /etc/passwd | cut -d: -f1,3 | grep -E "(^$1:)|(:$id$)" &>/dev/null
  check_func_return_r
  # groupname & gid
  cat /etc/group | cut -d: -f1,3 | grep -E "(^$1:)|(:$id$)" &>/dev/null
  check_func_return_r
  if ((${func_return} != 0)); then
    return 1
  fi

  groupadd -g ${id} ${user}
  check_func_return
  if [[ $2 == 'nor' ]]; then
    useradd -u ${id} -g ${id} -s /bin/bash -m ${user}
  elif [[ $2 == 'sys' ]]; then
    useradd -u ${id} -g ${id} -s /usr/sbin/nologin -M ${user}
  else
    return 1
  fi
  check_func_return

  return ${func_return}
}

add_user() {
  for user in ${l_nor_user[@]}; do
    add_user_c ${user} "nor"
    check_sh_retrun
  done

  for user in ${l_sys_user[@]}; do
    add_user_c ${user} "sys"
    check_sh_retrun
  done
}

update_pass() {
  for user in ${!a_nor_user_pass[@]}; do
    pass=${a_nor_user_pass[${user}]}
    if [[ -n "${pass}" ]]; then
      echo "${user}:${pass}" | chpasswd
      check_sh_retrun
    fi
  done
}

main() {
  load_lib
  load_cfg
  sh_return=0
  add_user
  update_pass
}

# main
main

exit ${sh_return}
