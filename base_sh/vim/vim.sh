#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_git='/opt/git'

# function
set_vimrc() {

  if [[ -d "${dir_git}/vim_runtime" ]]; then
    git -C "${dir_git}/vim_runtime" pull
  else
    git clone --depth=1 https://github.com/amix/vimrc.git ${dir_git}/vim_runtime
  fi
  bash ${dir_git}/vim_runtime/install_awesome_parameterized.sh ${dir_git}/vim_runtime root
  cp -f /root/.vimrc /etc/skel/
}

main() {
  set_vimrc
}

# main
main

exit 0
