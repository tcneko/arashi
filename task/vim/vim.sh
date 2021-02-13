#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/vim.json"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
d_git='/opt/git'

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
    mapfile -t l_enable_vim_cfg_user < <(jq -r ".l_enable_vim_cfg_user[]" ${f_cfg})
  else
    exit 1
  fi
}

update_git_repo() {
  if [[ -d "${d_git}/vim_runtime" ]]; then
    git -C "${d_git}/vim_runtime" pull
  else
    git clone --depth=1 https://github.com/amix/vimrc.git ${d_git}/vim_runtime
  fi
}

update_vim_cfg() {
  vimrc_my_config='" basic
set foldcolumn=0

" auto pairs
let g:AutoPairs={}
'
  echo "${vimrc_my_config}" >${d_git}/vim_runtime/my_configs.vim
}

enable_vim_cfg() {
  vimrc="set runtimepath+=${d_git}/vim_runtime
 
source ${d_git}/vim_runtime/vimrcs/basic.vim
source ${d_git}/vim_runtime/vimrcs/filetypes.vim
source ${d_git}/vim_runtime/vimrcs/plugins_config.vim
source ${d_git}/vim_runtime/vimrcs/extended.vim

try
source ${d_git}/vim_runtime/my_configs.vim
catch
endtry"
  echo "${vimrc}" >$1
}

enable_vim_cfg_user() {
  for user in ${l_enable_vim_cfg_user[@]}; do
    d_home=$(eval echo "~${user}")
    if [[ "${d_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.vimrc ${d_home}/.vimrc
      chown ${user}: ${d_home}/.vimrc
    else
      echo_warning "Skip upadte vim configure for user ${user}"
    fi
  done
}

main() {
  load_lib
  load_cfg
  update_git_repo
  update_vim_cfg
  enable_vim_cfg /etc/skel/.vimrc
  enable_vim_cfg_user
}

# main
main

exit 0
