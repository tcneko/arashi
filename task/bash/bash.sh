#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="${d_cur}/bash.json"

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
    mapfile -t l_update_bash_cfg_user < <(jq -r ".l_update_bash_cfg_user[]" ${f_cfg})
  else
    exit 1
  fi
}

set_color() {
  if [[ -n "$1" ]]; then
    sed -i '/add by arashi bash.sh set_color/,/end by arashi bash.sh set_color/d' $1
    cat >>$1 <<EOF
# add by arashi bash.sh set_color
if [[ "\$TERM" == "xterm" ]]; then
    export TERM=xterm-256color
fi
# end by arashi bash.sh set_color
EOF
  fi
}

set_alias() {
  if [[ -n "$1" ]]; then
    cp -f "${d_cur}/bash_aliases.sh" $1
    sed -i '/add by arashi bash.sh set_alias/,/end by arashi bash.sh set_alias/d' $1
    cat >>$1 <<EOF
# add by arashi bash.sh set_alias
if [[ -f ~/.bash_aliases_arashi ]]; then
    . ~/.bash_aliases_arashi
fi
# end by arashi bash.sh set_alias
EOF
  fi
}

set_ps1() {
  if [[ -n "$1" ]]; then
    sed -i '/add by arashi bash.sh set_ps1/,/end by arashi bash.sh set_ps1/d' $1
    sed -i 's/unset color_prompt force_color_prompt/#unset color_prompt force_color_prompt/g' $1
    cat >>$1 <<EOF
# add by arashi bash.sh set_ps1
if [ "\$color_prompt" = yes ]; then
     PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;35m\]\H\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]:\[\033[01;33m\]\$?\[\033[00m\]\n\$ '
else
     PS1='\${debian_chroot:+(\$debian_chroot)}\u:\H:\w:\$?\n\$ '
fi
unset color_prompt force_color_prompt
# end by arashi bash.sh set_ps1
EOF
  fi
}

update_bash_cfg_user() {
  for user in ${l_update_bash_cfg_user[@]}; do
    d_home=$(eval echo "~${user}")
    if [[ "${d_home}" != "~${user}" ]]; then
      cp -f /etc/skel/.bashrc ${d_home}/.bashrc
      cp -f /etc/skel/.bash_aliases_arashi ${d_home}/.bash_aliases_arashi
      chown ${user}: ${d_home}/.bashrc ${d_home}/.bash_aliases_arashi
    else
      echo_warning "Skip upadte bash configuration for user ${user}"
    fi
  done
}

main() {
  load_lib
  load_cfg
  set_color /etc/bash.bashrc
  set_alias /etc/skel/.bash_aliases_arashi
  set_ps1 /etc/skel/.bashrc
  update_bash_cfg_user
}

# main
main

exit 0
