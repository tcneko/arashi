#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_cur="$(dirname ${BASH_SOURCE[0]})"
cfg_file="${dir_cur}/arashi_cfg.sh"
export_func_s=('echo_info' 'echo_warning' 'echo_error' 'echo_exit' 'request_input' 'test_or_mkdir' 'safe_exit')
export_var_s=('flag_dir_tmp' 'tmp_dir')

# function
safe_exit() {
  if [[ ${flag_dir_tmp} -eq 0 ]]; then
    rm -rf ${dir_tmp}
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

test_or_mkdir() {
  if [[ ! -d $1 ]]; then
    mkdir -p $1
  fi
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
  flag_dir_tmp=0
  dir_tmp=$(mktemp -d)
}

mk_lt_dir() {
  for lt_dir in ${lt_dir_s[@]}; do
    test_or_mkdir ${lt_dir}
  done
}

export_func_a_var() {
  for export_func in ${export_func_s[@]}; do
    export -f ${export_func}
  done
  for export_var in ${export_var_s[@]}; do
    export ${export_var}
  done
}

run_sh() {
  for sh in $(eval echo \${${1}_s[@]}); do
    if [[ -r "${dir_cur}/$1/${sh}/${sh}.sh" ]]; then
      echo_info "Run script \"$1/${sh}/${sh}.sh\""
      bash "${dir_cur}/$1/${sh}/${sh}.sh"
      if [[ $? -ne 0 ]]; then
        echo_warning "\"${dir_cur}/$1/${sh}/${sh}.sh\" return value is not equal to 0"
      fi
    else
      echo_warning "Skip script \"${dir_cur}/$1/${sh}/${sh}.sh\""
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
  run_sh base_sh
  run_sh ext_sh
  safe_exit
}

# main
main

exit 1
