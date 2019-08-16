#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/ssh_cfg.sh"

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

disable_root() {
  if [[ ${flag_disable_root} -eq 0 ]]; then
    sed -Ei '/^#*[[:space:]]*PermitRootLogin (yes|no|without-password)[[:space:]]*$/s/.*/PermitRootLogin no/g' /etc/ssh/sshd_config
  fi
}

disable_pass() {
  if [[ ${flag_disable_pass} -eq 0 ]]; then
    sed -Ei '/^#*[[:space:]]*PasswordAuthentication (no|yes)[[:space:]]*$/s/.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
  fi
}

limit_user() {
  if [[ ${flag_limit_user} -eq 0 ]]; then
    echo '# Added by arashi/ssh.sh' >>/etc/ssh/sshd_config
    echo "AllowUsers ${limit_user_s[@]}" >>/etc/ssh/sshd_config
  fi
}

limit_ip() {
  if [[ ${flag_limit_ip} -eq 0 ]]; then
    echo '# Added by arashi/ssh.sh' >>/etc/hosts.allow
    limit_ip_sp_by_comma=$(echo ${limit_ip_s[@]} | sed 's/ /,/g')
    echo "# sshd:${limit_ip_sp_by_comma}:allow" >>/etc/hosts.allow
    echo '# Added by arashi/ssh.sh' >>/etc/hosts.deny
    echo "# sshd::all:deny" >>/etc/hosts.allow
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
