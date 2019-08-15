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
install_tmux_conf() {
  git clone https://github.com/gpakosz/.tmux.git ${git_dir}/tmux_theme
  cat ${git_dir}/tmux_theme/.tmux.conf | sed -E '/C-a/s/^/###/g' >/etc/skel/.tmux.conf
  cat ${git_dir}/tmux_theme/.tmux.conf.local |
    sed -E 's/^(tmux_conf_theme_.*_separator)/###\1/g;s/^#(tmux_conf_theme_.*_separator)/\1/g' |
    sed -E 's/❐|⌨|◼|◻/●/g' >/etc/skel/.tmux.conf.local
  cp /etc/skel/.tmux.conf /root/.tmux.conf
  cp /etc/skel/.tmux.conf.local /root/.tmux.conf.local
}

set_auto_start() {
  cat /etc/skel/.bashrc | grep 'tmux new -s rena' &>/dev/null
  if [[ $? -ne 0 ]]; then
    cat >>/etc/skel/.bashrc <<EOF

# added by arashi/tmux/tmux.sh
if command -v tmux &> /dev/null && [ -z "\$TMUX" ]; then
    tmux attach -t rena || tmux new -s rena
fi
EOF
  fi
}

main() {
  install_tmux_conf
  set_auto_start
}

# main
main

exit 0
