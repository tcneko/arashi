#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_cur="$(dirname ${BASH_SOURCE[0]})"

# function
set_alias() {
  cp -f "${dir_cur}/bash_aliases.sh" /etc/skel/.bash_aliases
  cp -f "${dir_cur}/bash_aliases.sh" /root/.bash_aliases
}

set_color() {
  cat /etc/skel/.bashrc | grep 'arashi/bash/bash.sh' &>/dev/null
  if [[ $? -ne 0 ]]; then
    sed -i '/add by arashi bash.sh/,/end by arashi bash.sh/d' /etc/skel/.bashrc
  fi
  cat >>/etc/skel/.bashrc <<EOF
# add by arashi bash.sh
if [ "\$TERM" == "xterm" ]; then
    export TERM=xterm-256color
fi
# end by arashi bash.sh
EOF
  cp -f /etc/skel/.bashrc /root/.bashrc
}

main() {
  set_alias
  set_color
}

# main
main

exit 0
