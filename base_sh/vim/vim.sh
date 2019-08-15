#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
git_dir='/opt/git'

# function
set_vimrc() {
  git clone --depth=1 https://github.com/amix/vimrc.git ${git_dir}/vim_runtime
  bash ${git_dir}/vim_runtime/install_awesome_parameterized.sh ${git_dir}/vim_runtime root
  cp /root/.vimrc /etc/skel/
}

main() {
  set_vimrc
}

# main
main

exit 0
