#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_main="$(dirname ${BASH_SOURCE[0]})/tmux_cfg.sh"
dir_git='/opt/git'

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
  else
    exit 1
  fi
}

ins_tmux_cfg() {
  if [[ -d "${dir_git}/tmux_theme" ]]; then
    git -C "${dir_git}/tmux_theme" pull
  else
    git clone https://github.com/gpakosz/.tmux.git ${dir_git}/tmux_theme
  fi
  cat ${dir_git}/tmux_theme/.tmux.conf | sed -E '/C-a/s/^/###/g' >/etc/skel/.tmux.conf
  cat ${dir_git}/tmux_theme/.tmux.conf.local |
    sed -E "/tmux_conf_theme_terminal_title/s/='.*'/='#{username}@#{hostname}'/g" >/etc/skel/.tmux.conf.local
}

upd_tmux_cfg() {
  for user in ${upd_tmux_cfg_user_s[@]}; do
    dir_user_home=$(eval echo ~${user})
    cp -f /etc/skel/.tmux.conf "${dir_user_home}/.tmux.conf"
    chown ${user}: "${dir_user_home}/.tmux.conf"
    cp -f /etc/skel/.tmux.conf.local "${dir_user_home}/.tmux.conf.local"
    chown ${user}: "${dir_user_home}/.tmux.conf.local"
  done
}

set_tmux_startup() {
  cat /etc/skel/.bashrc | grep 'add by arashi tmux.sh' &>/dev/null
  if [[ $? -eq 0 ]]; then
    sed -i '/add by arashi tmux.sh/,/end by arashi tmux.sh/d' /etc/skel/.bashrc
  fi
  cat >>/etc/skel/.bashrc <<EOF
# add by arashi tmux.sh
if command -v tmux &> /dev/null && [[ -z "\$TMUX" && "\$UID" -ne 0 ]]; then
    tmux attach -t rena || tmux new -s rena
fi
# end by arashi tmux.sh
EOF
}

upd_tmux_startup() {
  for user in ${upd_tmux_startup_user_s[@]}; do
    dir_user_home=$(eval echo ~${user})
    cp -f /etc/skel/.bashrc "${dir_user_home}/.bashrc"
    chown ${user}: "${dir_user_home}/.bashrc"
  done
}

main() {
  load_cfg
  ins_tmux_cfg
  upd_tmux_cfg
  set_tmux_startup
  upd_tmux_startup
}

# main
main

exit 0
