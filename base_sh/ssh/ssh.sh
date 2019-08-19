#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last update:
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
dir_cur="$(dirname ${BASH_SOURCE[0]})"
cfg_main="${dir_cur}/ssh_cfg.sh"
cfg_sshd='/etc/ssh/sshd_config'
cfg_hosts_allow='/etc/hosts.allow'
cfg_hosts_deny='/etc/hosts.deny'

# function
load_cfg() {
  if [[ -r ${cfg_main} ]]; then
    source ${cfg_main}
  else
    exit 1
  fi
}

disable_root() {
  if [[ ${flag_disable_root} -eq 0 ]]; then
    sed -Ei 's/^#*[[:space:]]*PermitRootLogin[[:space:]]+(yes|no|without-password|prohibit-password)[[:space:]]*$/PermitRootLogin no/g' ${cfg_sshd}
  fi
}

disable_pass() {
  if [[ ${flag_disable_pass} -eq 0 ]]; then
    sed -Ei 's/^#*[[:space:]]*PasswordAuthentication[[:space:]]+(no|yes)[[:space:]]*$/PasswordAuthentication no/g' ${cfg_sshd}
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
    limit_ip_sp_by_comma="$(echo ${limit_ip_s[@]} | sed 's/ /,/g')"
    cat >>${cfg_hosts_allow} <<EOF
# add by arashi ssh.sh limit_ip
sshd:${limit_ip_sp_by_comma}:allow
# end by arashi ssh.sh limit_ip
EOF
    cat ${cfg_hosts_deny} | grep 'add by arashi ssh.sh limit_ip' &>/dev/null
    if [[ $? -ne 0 ]]; then
      sed -i '/add by arashi ssh.sh limit_ip/,/end by arashi ssh.sh limit_ip/d' ${cfg_hosts_deny}
    fi
    cat >>${cfg_hosts_deny} <<EOF
# add by arashi ssh.sh limit_ip
sshd:all:deny
# end by arashi ssh.sh limit_ip
EOF
  fi
}

change_port() {
  if [[ -n ${sshd_port} ]]; then
    sed -Ei "s/^#*[[:space:]]*Port [0-9]{1,5}[[:space:]]*$/Port ${sshd_port}/g" ${cfg_sshd}
  fi
}

add_pubkey() {
  for pubkey_user in ${pubkey_user_s[@]}; do
    if [[ -f "${dir_cur}/${pubkey_user}.pub" && ! -f "/home/${pubkey_user}/.ssh/authorized_keys" ]]; then
      test_or_mkdir "/home/${pubkey_user}/.ssh"
      chown "${pubkey_user}:" "/home/${pubkey_user}/.ssh"
      chmod 700 "/home/${pubkey_user}/.ssh"
      cp "${dir_cur}/${pubkey_user}.pub" "/home/${pubkey_user}/.ssh/authorized_keys"
      chown "${pubkey_user}:" "/home/${pubkey_user}/.ssh/authorized_keys"
      chmod 600 "/home/${pubkey_user}/.ssh/authorized_keys"
    else
      echo_warning "Skip add user ${1}"
    fi
  done
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
  change_port
  add_pubkey
  restart_sshd
}

# main
main

exit 0
