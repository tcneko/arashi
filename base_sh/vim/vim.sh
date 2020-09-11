#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_main="$(dirname ${BASH_SOURCE[0]})/vim_cfg.sh"
dir_git='/opt/git'

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
  else
    exit 1
  fi
}

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
  vimrc_my_config='set foldcolumn=0
'
  echo "${vimrc_my_config}" >${dir_git}/vim_runtime/my_configs.vim
}

upd_vim_cfg() {
  for user in ${upd_vim_cfg_user_s[@]}; do
    dir_user_home=$(eval echo "~${user}")
    if [[ "${dir_user_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.vimrc "${dir_user_home}/.vimrc"
      chown ${user}: "${dir_user_home}/.vimrc"
    else
      echo_warning "Skip upadte vim configure for user ${user}"
    fi
  done
}

main() {
  load_cfg
  ins_vimrc
  upd_vim_cfg
}

# main
main

exit 0
