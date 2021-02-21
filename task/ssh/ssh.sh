#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
d_cur="$(dirname ${BASH_SOURCE[0]})"
f_cfg="${d_cur}/ssh.json"
f_lib="${d_cur}/../../lib/lib_arashi.sh"
f_cfg_sshd='/etc/ssh/sshd_config'
f_hosts_allow='/etc/hosts.allow'
f_hosts_deny='/etc/hosts.deny'

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
    b_disable_root=$(jq -r ".b_disable_root" ${f_cfg})
    b_disable_pass=$(jq -r ".b_disable_pass" ${f_cfg})
    i_sshd_port=$(jq -r ".i_sshd_port" ${f_cfg})
    mapfile -t l_limit_user < <(jq -r ".l_limit_user[]" ${f_cfg})
    mapfile -t l_limit_ip < <(jq -r ".l_limit_ip[]" ${f_cfg})
    mapfile -t l_pubkey_user < <(jq -r ".l_pubkey_user[]" ${f_cfg})
    b_restart_sshd=$(jq -r ".b_restart_sshd" ${f_cfg})
  else
    exit 1
  fi
}

disable_root() {
  if ((${b_disable_root} == 0)); then
    sed -Ei 's/^#*[[:space:]]*PermitRootLogin[[:space:]]+(yes|no|without-password|prohibit-password)[[:space:]]*$/PermitRootLogin no/g' ${f_cfg_sshd}
    check_sh_retrun
  fi
}

disable_pass() {
  if ((${b_disable_pass} == 0)); then
    sed -Ei 's/^#*[[:space:]]*PasswordAuthentication[[:space:]]+(no|yes)[[:space:]]*$/PasswordAuthentication no/g' ${f_cfg_sshd}
    check_sh_retrun
  fi
}

change_port() {
  if [[ -n "${i_sshd_port}" ]]; then
    sed -Ei "s/^#*[[:space:]]*Port[[:space:]]+[0-9]{1,5}[[:space:]]*$/Port ${i_sshd_port}/g" ${f_cfg_sshd}
    check_sh_retrun
  fi
}

limit_user() {
  if [[ -n "${l_limit_user[@]}" ]]; then
    sed -i '/add by arashi ssh.sh limit_user/,/end by arashi ssh.sh limit_user/d' ${f_cfg_sshd}
    cat >>${f_cfg_sshd} <<EOF
# add by arashi ssh.sh limit_user
AllowUsers ${l_limit_user[@]}
# end by arashi ssh.sh limit_user
EOF
    check_sh_retrun
  fi
}

limit_ip() {
  if [[ -n "${l_limit_ip[@]}" ]]; then
    sed -i '/add by arashi ssh.sh limit_ip/,/end by arashi ssh.sh limit_ip/d' ${f_hosts_allow}
    limit_ip_sp_by_comma="$(echo ${l_limit_ip[@]} | sed 's/ /,/g')"
    cat >>${f_hosts_allow} <<EOF
# add by arashi ssh.sh limit_ip
sshd:${limit_ip_sp_by_comma}:allow
# end by arashi ssh.sh limit_ip
EOF
    check_sh_retrun
    sed -i '/add by arashi ssh.sh limit_ip/,/end by arashi ssh.sh limit_ip/d' ${f_hosts_deny}
    cat >>${f_hosts_deny} <<EOF
# add by arashi ssh.sh limit_ip
sshd:all:deny
# end by arashi ssh.sh limit_ip
EOF
    check_sh_retrun
  fi
}

add_pubkey() {
  for pubkey_user in ${l_pubkey_user[@]}; do
    if [[ -f "${d_cur}/${pubkey_user}.pub" ]]; then
      mkdir -p "/home/${pubkey_user}/.ssh"
      chown "${pubkey_user}:" "/home/${pubkey_user}/.ssh"
      chmod 700 "/home/${pubkey_user}/.ssh"
      cp "${d_cur}/${pubkey_user}.pub" "/home/${pubkey_user}/.ssh/authorized_keys"
      chown "${pubkey_user}:" "/home/${pubkey_user}/.ssh/authorized_keys"
      chmod 600 "/home/${pubkey_user}/.ssh/authorized_keys"
    else
      echo_warning "Skip add ssh public key for user ${pubkey_user}"
      sh_return=1
    fi
  done
}

restart_serv() {
  if ((${b_restart_sshd} == 0)); then
    systemctl restart sshd
    check_sh_retrun
  fi
}

main() {
  load_lib
  load_cfg
  sh_return=0
  disable_root
  disable_pass
  change_port
  limit_user
  limit_ip
  add_pubkey
  restart_serv
}

# main
main

exit ${sh_return}
