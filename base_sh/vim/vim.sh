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
ins_vimrc() {
  if [[ -d "${dir_git}/vim_runtime" ]]; then
    git -C "${dir_git}/vim_runtime" pull
  else
    git clone --depth=1 https://github.com/amix/vimrc.git ${dir_git}/vim_runtime
  fi
  vimrc="set runtimepath+=${dir_git}/vim_runtime
 
 source ${dir_git}/vim_runtime/vimrcs/basic.vim
 source ${dir_git}/vim_runtime/vimrcs/filetypes.vim
 source ${dir_git}/vim_runtime/vimrcs/plugins_config.vim
 source ${dir_git}/vim_runtime/vimrcs/extended.vim
 
 try
 source ${dir_git}/vim_runtime/my_configs.vim
 catch
 endtry"

  echo "${vimrc}" >/etc/skel/.vimrc
}

upd_vim_cfg() {
  for user in ${upd_vim_cfg_user_s[@]}; do
    dir_user_home=$(eval echo ~${user})
    cp -f /etc/skel/.vimrc "${dir_user_home}/.vimrc"
    chown ${user}: "${dir_user_home}/.vimrc"
  done
}

main() {
  ins_vimrc
  upd_vim_cfg
}

# main
main

exit 0
