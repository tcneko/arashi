#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/sysctl_cfg.sh"
cfg_sysctl='/etc/sysctl.conf'

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

enable_forward() {
  grep -E '^[[:space:]]*net.ipv4.ip_forward=1[[:space:]]*$' ${cfg_sysctl} &>/dev/null
  if [[ $? -ne 0 && ${flag_enable_forward} -eq 0 ]]; then
    sed -Ei 's/^#*[[:space:]]*net.ipv4.ip_forward=1[[:space:]]*$/net.ipv4.ip_forward=1/g' ${cfg_sysctl}
  fi
  grep -E '^[[:space:]]*net.ipv6.conf.all.forwarding=1[[:space:]]*$' ${cfg_sysctl} &>/dev/null
  if [[ $? -ne 0 && ${flag_enable_forward} -eq 0 ]]; then
    sed -Ei 's/^#*[[:space:]]*net.ipv6.conf.all.forwarding=1[[:space:]]*$/net.ipv6.conf.all.forwarding=1/g' ${cfg_sysctl}
  fi
}

enable_bbr() {
  if [[ ${flag_enable_bbr} -eq 0 ]]; then
    cat ${cfg_sysctl} | grep 'add by arashi sysctl.sh enable_bbr' &>/dev/null
    if [[ $? -eq 0 ]]; then
      sed -i '/add by arashi sysctl.sh enable_bbr/,/end by arashi sysctl.sh enable_bbr/d' ${cfg_sysctl}
    fi
    cat >>${cfg_sysctl} <<EOF
# add by arashi sysctl.sh enable_bbr
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
# end by arashi sysctl.sh enable_bbr
EOF
  fi
}

apply_sysctl() {
  if [[ ${flag_apply_sysctl} -eq 0 ]]; then
    sysctl -p
  fi
}

main() {
  load_cfg
  enable_forward
  enable_bbr
  apply_sysctl
}

# main
main

exit 0
