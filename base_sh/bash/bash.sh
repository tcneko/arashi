#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_cur="$(dirname ${BASH_SOURCE[0]})"
cfg_main="${dir_cur}/bash_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
  else
    exit 1
  fi
}

set_alias() {
  cp -f "${dir_cur}/bash_aliases.sh" /etc/skel/.bash_aliases
}

set_color() {
  cat /etc/skel/.bashrc | grep 'arashi/bash/bash.sh' &>/dev/null
  if [[ $? -ne 0 ]]; then
    sed -i '/add by arashi bash.sh/,/end by arashi bash.sh/d' /etc/skel/.bashrc
  fi
  cat >>/etc/skel/.bashrc <<EOF
# add by arashi bash.sh
if [[ "\$TERM" == "xterm" ]]; then
    export TERM=xterm-256color
fi
# end by arashi bash.sh
EOF
}

upd_bash_cfg() {
  for user in ${upd_bash_cfg_user_s[@]}; do
    dir_user_home=$(eval echo "~${user}")
    if [[ "${dir_user_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.bashrc "${dir_user_home}/.bashrc"
      chown ${user}: "${dir_user_home}/.bashrc"
      cp -f /etc/skel/.bash_aliases "${dir_user_home}/.bash_aliases"
      chown ${user}: "${dir_user_home}/.bash_aliases"
    else
      echo_warning "Skip upadte bash configure for user ${user}"
    fi
  done
}

main() {
  load_cfg
  set_alias
  set_color
  upd_bash_cfg
}

# main
main

exit 0
