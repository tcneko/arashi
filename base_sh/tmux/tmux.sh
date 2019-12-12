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
  cp ${dir_git}/tmux_theme/.tmux.conf.local /etc/skel/.tmux.conf.local
  sed -i '/add by arashi tmux.sh ins_tmux_cfg/,/end by arashi tmux.sh ins_tmux_cfg/d' /etc/skel/.tmux.conf.local
  cat >>/etc/skel/.tmux.conf.local <<EOF
## add by arashi tmux.sh ins_tmux_cfg
set -g default-terminal "xterm-256color"

tmux_conf_theme_terminal_title='#{username}@#H'

tmux_conf_theme_status_left_fg='#000000,#e4e4e4,#000000'  # black, white , white
tmux_conf_theme_status_left_bg='#ffff00,#ff00af,#e4e4e4'  # yellow, pink, white blue
tmux_conf_theme_status_left_attr='bold,bold,bold'

tmux_conf_theme_status_right_fg='#000000'
tmux_conf_theme_status_right_bg='#e4e4e4'
tmux_conf_theme_status_right_attr='bold'

tmux_conf_theme_prefix=' prefix '
tmux_conf_theme_pairing=' pair '
tmux_conf_theme_synchronized=' sync '

tmux_conf_theme_status_left=' ❐ #S | #{username}#{root} |#{prefix}'
tmux_conf_theme_status_right='#{synchronized}#{pairing}'

set -g status-interval 0
## end by arashi tmux.sh ins_tmux_cfg
EOF
}

upd_tmux_cfg() {
  for user in ${upd_tmux_cfg_user_s[@]}; do
    dir_user_home=$(eval echo ~${user})
    if [[ "${dir_user_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.tmux.conf "${dir_user_home}/.tmux.conf"
      chown ${user}: "${dir_user_home}/.tmux.conf"
      cp -f /etc/skel/.tmux.conf.local "${dir_user_home}/.tmux.conf.local"
      chown ${user}: "${dir_user_home}/.tmux.conf.local"
    else
      echo_warning "Skip upadte tmux configure for user ${user}"
    fi
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
    tmux attach -t rena || sleep 1 && tmux new -s rena
fi
# end by arashi tmux.sh
EOF
}

upd_tmux_startup() {
  for user in ${upd_tmux_startup_user_s[@]}; do
    dir_user_home=$(eval echo "~${user}")
    if [[ "${dir_user_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.bashrc "${dir_user_home}/.bashrc"
      chown ${user}: "${dir_user_home}/.bashrc"
    else
      echo_warning "Skip upadte tmux startup for user ${user}"
    fi
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
