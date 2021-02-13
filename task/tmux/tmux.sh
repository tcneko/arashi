#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/tmux.json"
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
    mapfile -t l_update_tmux_cfg_user < <(jq -r ".l_update_tmux_cfg_user[]" ${f_cfg})
  else
    exit 1
  fi
}

update_git_repo() {
  if [[ -d "${d_git}/tmux_theme" ]]; then
    git -C "${d_git}/tmux_theme" pull
  else
    git clone https://github.com/gpakosz/.tmux.git ${d_git}/tmux_theme
  fi
}

update_tmux_cfg() {
  cat ${d_git}/tmux_theme/.tmux.conf | sed -E '/C-a/s/^/###/g' >${1}/.tmux.conf
  cp -f ${d_git}/tmux_theme/.tmux.conf.local ${1}/.tmux.conf.local
  sed -i '/add by arashi tmux.sh ins_tmux_cfg/,/end by arashi tmux.sh ins_tmux_cfg/d' ${1}/.tmux.conf.local
  cat >>${1}/.tmux.conf.local <<EOF
## add by arashi tmux.sh ins_tmux_cfg
set -g default-terminal "xterm-256color"

tmux_conf_theme_terminal_title='#{username}@#H'

tmux_conf_theme_status_left_fg='#000000,#e4e4e4,#000000'  # black, white, white
tmux_conf_theme_status_left_bg='#ffff00,#ff00af,#e4e4e4'  # yellow, pink, blue
tmux_conf_theme_status_left_attr='bold,bold,bold'

tmux_conf_theme_status_right_fg='#e6e6e6,#f0f0f0,#fafafa'
tmux_conf_theme_status_right_bg='#444444,#585858,#808080'
tmux_conf_theme_status_right_attr='bold,bold,bold'

tmux_conf_theme_synchronized='sync'
tmux_conf_theme_pairing='pair'
tmux_conf_theme_prefix='prefix'

tmux_conf_theme_status_left=' #S | #{username}#{root} '
tmux_conf_theme_status_right=' #{synchronized}| #{pairing}| #{prefix}'

set -g status-interval 0
## end by arashi tmux.sh ins_tmux_cfg
EOF
}

enable_tmux_startup() {
  sed -i '/add by arashi tmux.sh/,/end by arashi tmux.sh/d' $1
  cat >>$1 <<EOF
# add by arashi tmux.sh
if command -v tmux &> /dev/null && [[ -z "\$TMUX" && "\$UID" -ne 0 ]]; then
    tmux attach -t rena || (sleep 1 && tmux new -s rena)
fi
# end by arashi tmux.sh
EOF
}

update_tmux_cfg_user() {
  for user in ${l_update_tmux_cfg_user[@]}; do
    d_home=$(eval echo ~${user})
    if [[ "${d_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.tmux.conf ${d_home}/.tmux.conf
      cp -f /etc/skel/.tmux.conf.local ${d_home}/.tmux.conf.local
      cp -f /etc/skel/.bashrc ${d_home}/.bashrc
      chown ${user}: ${d_home}/.tmux.conf ${d_home}/.tmux.conf.local ${d_home}/.bashrc
    else
      echo_warning "Skip upadte tmux configure for user ${user}"
    fi
  done
}

main() {
  load_lib
  load_cfg
  update_git_repo
  update_tmux_cfg /etc/skel
  enable_tmux_startup /etc/skel/.bashrc
  update_tmux_cfg_user
}

# main
main

exit 0
