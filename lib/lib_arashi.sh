#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2021.01
# last test environment: ubuntu 18.04
# description:

if [[ -z ${check_lsb_support} ]]; then
  check_lsb_support() {
    b_support=1
    i_x=0
    while ((${i_x} < ${#l_lsb_support[@]})); do
      lsb_release -a 2>/dev/null | grep -E "${l_lsb_support[$i_x]}" &>/dev/null
      if [[ $? -eq 0 ]]; then
        b_support=0
      fi
      i_x=$((${i_x} + 1))
    done
    if ((${b_support} != 0)); then
      echo_error "This release is not supported"
      return 1
    else
      return 0
    fi
  }
  export -f check_lsb_support
fi

if [[ -z ${check_sh_retrun} ]]; then
  check_sh_retrun() {
    if (($? != 0)); then
      sh_return=1
    fi
  }
  export -f check_sh_retrun
fi

if [[ -z ${mk_d_tmp} ]]; then
  mk_d_tmp() {
    b_d_tmp=0
    d_tmp=$(mktemp -d)
  }
  export -f mk_d_tmp
fi

if [[ -z ${clean_exit} ]]; then
  clean_exit() {
    if [[ ${b_d_tmp} -eq 0 ]]; then
      rm -rf ${d_tmp}
    fi
    exit $1
  }
  export -f clean_exit
fi

if [[ -z ${echo_info} ]]; then
  echo_info() {
    echo -e "\e[1;32m[Info]\e[0m $@"
  }
  export -f echo_info
fi

if [[ -z ${echo_warning} ]]; then
  echo_warning() {
    echo >&2 -e "\e[1;33m[Warning]\e[0m $@"
  }
  export -f echo_warning
fi

if [[ -z ${echo_error} ]]; then
  echo_error() {
    echo >&2 -e "\e[1;31m[Error]\e[0m $@"
  }
  export -f echo_error
fi
