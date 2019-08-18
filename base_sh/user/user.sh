#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/user_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

set_flag_retrun() {
  if [[ $? -eq 0 ]]; then
    flag_retrun=0
  fi
}

add_user_c() {
  id_add=$(echo -n $1 | md5sum | sed 's/[^0-9]//g;s/.*\(...\)$/\1/')
  case $2 in
    'n')
      id=$(echo "${id_add}+${base_id_nor}" | bc)
      ;;
    's')
      id=$(echo "${id_add}+${base_id_sys}" | bc)
      ;;
  esac

  flag_retrun=1
  # uid
  cat /etc/passwd | cut -d: -f3 | grep ${id} &>/dev/null
  set_flag_retrun
  # username
  cat /etc/passwd | cut -d: -f1 | grep -E "^$1$" &>/dev/null
  set_flag_retrun
  # gid
  cat /etc/group | cut -d: -f3 | grep ${id} &>/dev/null
  set_flag_retrun
  # groupname
  cat /etc/group | cut -d: -f1 | grep -E "^$1$" &>/dev/null
  set_flag_retrun
  if [[ ${flag_retrun} -eq 0 ]]; then
    echo_warning "Skip add user ${1}"
    return 1
  fi

  case $2 in
    'n')
      groupadd -g ${id} $1
      useradd -u ${id} -g ${id} -s /bin/bash -m $1
      ;;
    's')
      groupadd -g ${id} $1
      useradd -u ${id} -g ${id} -s /usr/sbin/nologin -M $1
      ;;
  esac
}

add_user() {
  for nor_user in ${nor_user_s[@]}; do
    add_user_c ${nor_user} 'n'
  done
  for sys_user in ${sys_user_s[@]}; do
    add_user_c ${sys_user} 's'
  done

}

set_pass() {
  for nor_user in ${nor_user_s[@]}; do
    if [[ -n ${nor_user_pass_s[${nor_user}]} ]]; then
      echo "${nor_user}:${nor_user_pass_s[${nor_user}]}" | chpasswd
    fi
  done
}

main() {
  load_cfg
  add_user
  set_pass
}

# main
main

exit 0
