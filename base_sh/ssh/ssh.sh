#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/ssh_cfg.sh"
cfg_sshd='/etc/ssh/sshd_config'
cfg_hosts_allow='/etc/hosts.allow'
cfg_hosts_deny='/etc/hosts.deny'

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

disable_root() {
  grep '^[[:space:]]*PermitRootLogin no' ${cfg_sshd} &>/dev/null
  if [[ $? -ne 0 && ${flag_disable_root} -eq 0 ]]; then
    sed -Ei '/^#*[[:space:]]*PermitRootLogin (yes|no|without-password|prohibit-password)[[:space:]]*$/s/.*/PermitRootLogin no/g' ${cfg_sshd}
  fi
}

disable_pass() {
  grep '^[[:space:]]*PasswordAuthentication no' ${cfg_sshd} &>/dev/null
  if [[ $? -ne 0 && ${flag_disable_pass} -eq 0 ]]; then
    sed -Ei '/^#*[[:space:]]*PasswordAuthentication (no|yes)[[:space:]]*$/s/.*/PasswordAuthentication no/g' ${cfg_sshd}
  fi
}

limit_user() {
  if [[ ${flag_limit_user} -eq 0 && -n ${limit_user_s[@]} ]]; then
    cat ${cfg_sshd} | grep 'add by arashi ssh.sh limit_user' &>/dev/null
    if [[ $? -eq 0 ]]; then
      sed -i '/add by arashi ssh.sh limit_user/,/end by arashi ssh.sh limit_user/d' ${cfg_sshd}
    fi
    cat >>${cfg_sshd} <<EOF
# add by arashi ssh.sh limit_user
AllowUsers ${limit_user_s[@]}
# end by arashi ssh.sh limit_user
EOF
  fi
}

limit_ip() {
  if [[ ${flag_limit_ip} -eq 0 && -n ${limit_ip_s[@]} ]]; then
    cat ${cfg_hosts_allow} | grep 'add by arashi ssh.sh limit_ip' &>/dev/null
    if [[ $? -eq 0 ]]; then
      sed -i '/add by arashi ssh.sh limit_ip/,/end by arashi ssh.sh limit_ip/d' ${cfg_hosts_allow}
    fi
    limit_ip_sp_by_comma=$(echo ${limit_ip_s[@]} | sed 's/ /,/g')
    cat >>${cfg_hosts_allow} <<EOF
# add by arashi ssh.sh limit_ip
sshd:${limit_ip_sp_by_comma}:allow
# end by arashi ssh.sh limit_ip
EOF
    cat ${cfg_hosts_deny} | grep 'add by arashi ssh.sh limit_ip' &>/dev/null
    if [[ $? -ne 0 ]]; then
      cat >>${cfg_hosts_deny} <<EOF
# add by arashi ssh.sh limit_ip
sshd:all:deny
# end by arashi ssh.sh limit_ip
EOF
    fi
  fi
}

restart_sshd() {
  if [[ ${flag_restart_sshd} -eq 0 ]]; then
    systemctl restart sshd
  fi
}

main() {
  load_cfg
  disable_root
  disable_pass
  limit_user
  limit_ip
  restart_sshd
}

# main
main

exit 0
