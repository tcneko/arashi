#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg="$(dirname ${BASH_SOURCE[0]})/sysctl.json"
f_sysctl='/etc/sysctl.conf'

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
    b_enable_forward=$(jq -r ".b_enable_forward" ${f_cfg})
    b_enable_bbr=$(jq -r ".b_enable_bbr" ${f_cfg})
    b_apply_sysctl=$(jq -r ".b_apply_sysctl" ${f_cfg})
  else
    exit 1
  fi
}

enable_forward() {
  if ((${b_enable_forward} == 0)); then
    sed -Ei 's/^#*[[:space:]]*net.ipv4.ip_forward=[0-1][[:space:]]*$/net.ipv4.ip_forward=1/g' ${f_sysctl}
    sed -Ei 's/^#*[[:space:]]*net.ipv6.conf.all.forwarding=[0-1][[:space:]]*$/net.ipv6.conf.all.forwarding=1/g' ${f_sysctl}
    check_sh_retrun
  fi
}

enable_bbr() {
  if ((${b_enable_bbr} == 0)); then
    sed -i '/add by arashi sysctl.sh enable_bbr/,/end by arashi sysctl.sh enable_bbr/d' ${f_sysctl}
    cat >>${f_sysctl} <<EOF
# add by arashi sysctl.sh enable_bbr
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
# end by arashi sysctl.sh enable_bbr
EOF
    check_sh_retrun
  fi
}

apply_sysctl() {
  if ((${b_apply_sysctl} == 0)); then
    sysctl -p
    check_sh_retrun
  fi
}

main() {
  load_lib
  load_cfg
  enable_forward
  enable_bbr
  apply_sysctl
}

# main
main

exit 0
