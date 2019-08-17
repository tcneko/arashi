#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${cur_dir}/arashi_cfg.sh"
export_func_s=('echo_info' 'echo_warning' 'echo_error' 'echo_exit' 'request_input' 'safe_exit')
export_var_s=('flag_tmp_dir' 'tmp_dir')

# function
safe_exit() {
  if [[ ${temp_dir_flag} -eq 0 ]]; then
    rm -rf ${temp_dir}
  fi
  exit $1
}

echo_info() {
  echo -e "\e[1;32m[Info]\e[0m $@"
}

echo_warning() {
  echo >&2 -e "\e[1;33m[Warning]\e[0m $@"
}

echo_error() {
  echo >&2 -e "\e[1;31m[Error]\e[0m $@"
}

echo_exit() {
  echo_error "$@"
  safe_exit 1
}

request_input() {
  echo "$2"
  eval "read -ep '>>> ' $1"
}

test_root_exit() {
  if [[ $(id -u) -ne 0 ]]; then
    echo_exit 'Please rerun as root'
  fi
}

test_lsb_exit() {
  lsb_release -a | grep -E "${support_lsb_regexp}" &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo_exit "This release is not supported"
  fi
}

load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    safe_exit 1
  fi
}

mk_tmp_dir() {
  flag_tmp_dir=0
  tmp_dir=$(mktemp -d)
}

mk_lt_dir() {
  for dir in ${dir_s}; do
    mkdir -p ${dir}
  done
}

export_func_a_var() {
  for export_func in ${export_func_s}; do
    export -f ${export_func}
  done
  for export_var in ${export_var_s}; do
    export ${export_var}
  done
}

run_sh() {
  for sh in $(eval echo \${${1}_s[@]}); do
    if [[ -r "$1/${sh}/${sh}.sh" ]]; then
      echo_info "Run script \"$1/${sh}/${sh}.sh\""
      bash "$1/${sh}/${sh}.sh"
      if [[ $? -ne 0 ]]; then
        echo_warning "\"$1/${sh}/${sh}.sh\" return value is not equal to 0"
      fi
    else
      echo_warning "Skip script \"$1/${sh}/${sh}.sh\""
    fi
  done
}

main() {
  test_lsb_exit
  test_root_exit
  mk_tmp_dir
  load_cfg
  mk_lt_dir
  export_func_a_var
  run_sh "${cur_dir}/base_sh"
  run_sh "${cur_dir}/ext_sh"
  safe_exit
}

# main
main

exit 1
