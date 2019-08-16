#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cur_dir="$(dirname ${BASH_SOURCE[0]})"

# function
set_alias() {
  if [[ ! -f /etc/skel/.bash_aliases ]]; then
    cp "${cur_dir}/bash_aliases.sh" /etc/skel/.bash_aliases
  fi
  if [[ ! -f /root/.bash_aliases ]]; then
    cp "${cur_dir}/bash_aliases.sh" /root/.bash_aliases
  fi
}

set_color() {
  cat /etc/skel/.bashrc | grep 'arashi/bash/bash.sh' &>/dev/null
  if [[ $? -ne 0 ]]; then
    sed -i '/add by arashi bash.sh/,/end by arashi bash.sh/d' /etc/skel/.bashrc
  fi
    cat >>/etc/skel/.bashrc <<EOF
# add by arashi bash.sh
if [ "$TERM" == "xterm" ]; then
    export TERM=xterm-256color
fi
# end by arashi bash.sh
EOF
}

main() {
  set_alias
  set_color
}

# main
main

exit 0
