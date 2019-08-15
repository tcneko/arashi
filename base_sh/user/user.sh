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

test_success_exit() {
  if [[ $? -eq 0 ]]; then
    exit 1
  fi
}

add_user() {
  id_add=$(echo -n $1 | md5sum | sed 's/[^0-9]//g;s/.*\(...\)$/\1/')

  # uid
  cat /etc/passwd | cut -d: -f3 | grep ${id} &>/dev/null
  test_success_exit
  # username
  cat /etc/passwd | cut -d: -f1 | grep -E "^$1$" &>/dev/null
  test_success_exit
  # gid
  cat /etc/group | cut -d: -f3 | grep ${id} &>/dev/null
  test_success_exit
  # groupname
  cat /etc/group | cut -d: -f1 | grep -E "^$1$" &>/dev/null
  test_success_exit

  case $2 in
    'n')
      id=$(echo "${id_add}+${base_id_nor}" | bc)
      groupadd -g ${id} $1
      useradd -u ${id} -g ${id} -s /bin/bash -m $1
      ;;
    's')
      id=$(echo "${id_add}+${base_id_sys}" | bc)
      groupadd -g ${id} $1
      useradd -u ${id} -g ${id} -s /usr/sbin/nologin -M $1
      ;;
  esac
}

main() {
  load_cfg
  for nor_user in ${nor_user_s[@]}; do
    add_user ${nor_user} 'n'
  done
  for sys_user in ${sys_user_s[@]}; do
    add_user ${sys_user} 's'
  done
}

# main
main

exit 0
