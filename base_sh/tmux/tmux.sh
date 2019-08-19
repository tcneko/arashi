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
ins_tmux_cfg() {
  if [[ -d "${dir_git}/tmux_theme" ]]; then
    git -C "${dir_git}/tmux_theme" pull
  else
    git clone https://github.com/gpakosz/.tmux.git ${dir_git}/tmux_theme
  fi
  cat ${dir_git}/tmux_theme/.tmux.conf | sed -E '/C-a/s/^/###/g' >/etc/skel/.tmux.conf
  cat ${dir_git}/tmux_theme/.tmux.conf.local |
    sed -E 's/^(tmux_conf_theme_.*_separator)/###\1/g;s/^#(tmux_conf_theme_.*_separator)/\1/g' |
    sed -E 's/❐|⌨|◼|◻/●/g' >/etc/skel/.tmux.conf.local
  cp /etc/skel/.tmux.conf /root/.tmux.conf
  cp /etc/skel/.tmux.conf.local /root/.tmux.conf.local
}

set_auto_start() {
  cat /etc/skel/.bashrc | grep 'add by arashi tmux.sh' &>/dev/null
  if [[ $? -eq 0 ]]; then
    sed -i '/add by arashi tmux.sh/,/end by arashi tmux.sh/d' /etc/skel/.bashrc
  fi
  cp -f /etc/skel/.bashrc /root/.bashrc
  cat >>/etc/skel/.bashrc <<EOF
# add by arashi tmux.sh
if command -v tmux &> /dev/null && [ -z "\$TMUX" ]; then
    tmux attach -t rena || tmux new -s rena
fi
# end by arashi tmux.sh
EOF
}

main() {
  ins_tmux_cfg
  set_auto_start
}

# main
main

exit 0
