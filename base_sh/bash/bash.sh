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
  cat /etc/bash.bashrc | grep 'arashi/bash/bash.sh' &>/dev/null
  if [[ $? -ne 0 ]]; then
    sed -i '/add by arashi bash.sh set_color/,/end by arashi bash.sh set_color/d' /etc/bash.bashrc
  fi
  cat >>/etc/bash.bashrc <<EOF
# add by arashi bash.sh set_color
if [[ "\$TERM" == "xterm" ]]; then
    export TERM=xterm-256color
fi
# end by arashi bash.sh set_color
EOF
}

set_ps1() {
  cat /etc/skel/.bashrc | grep 'arashi/bash/bash.sh' &>/dev/null
  if [[ $? -ne 0 ]]; then
    sed -i '/add by arashi bash.sh set_ps1/,/end by arashi bash.sh set_ps1/d' /etc/skel/.bashrc
  fi
  sed -i 's/unset color_prompt force_color_prompt/#unset color_prompt force_color_prompt/g' /etc/skel/.bashrc
  cat >>/etc/skel/.bashrc <<EOF
# add by arashi bash.sh set_ps1
if [ "\$color_prompt" = yes ]; then
     PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;35m\]\H\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]:\[\033[01;33m\]\$?\[\033[00m\]\n\$ '
else
     PS1='\${debian_chroot:+(\$debian_chroot)}\u:\H:\w:\$?\n\$ '
fi
unset color_prompt force_color_prompt
# end by arashi bash.sh set_ps1
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
  set_ps1
  upd_bash_cfg
}

# main
main

exit 0
