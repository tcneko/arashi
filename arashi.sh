#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/arashi.json"
f_lib="${d_cur}/lib/lib_arashi.sh"
d_task="${d_cur}/task"

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
    mapfile -f l_task < <(jq -r ".l_task[]" ${f_cfg})
  else
    exit 1
  fi
}

check_root_exit() {
  if (($(id -u) == 0)); then
    echo_error 'Please rerun as root'
    exit 1
  fi
}

run_task() {
  for task in ${l_task[@]}; do
    task_sh="${d_task}/${task}/${task}.sh"
    if [[ -r "${task_sh}" ]]; then
      echo_info "Task \"${task_sh}\" start"
      bash ${task_sh}
      if (($? != 0)); then
        echo_warning "Task \"${task_sh}\" failed"
        sh_return=1
      fi
    else
      echo_warning "Skip task \"${task_sh}\""
      sh_return=1
    fi
  done
}

main() {
  load_lib
  load_cfg
  check_root_exit
  sh_return=0
  run_task
}

# main
main

exit ${sh_return}
