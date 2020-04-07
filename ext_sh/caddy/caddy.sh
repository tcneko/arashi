#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/caddy_cfg.sh"
dir_git='/opt/git'

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

ins_caddy() {
  caddy_pulgin_sp_by_comma="$(echo ${caddy_pulgin_s[@]} | sed 's/ /,/g')"
  wget https://caddyserver.com/download/linux/amd64?plugins=${caddy_pulgin_sp_by_comma}&license=personal&telemetry=off -O ${dir_git}/caddy.tar.gz
  rm -rf /usr/local/bin/caddy
  tar -C /usr/local/bin -zxf ${dir_git}/caddy.tar.gz caddy
  rm -rf /lib/systemd/system/caddy.service
  tar -C /lib/systemd/system --strip-components 2 -zxf ${dir_git}/caddy.tar.gz init/linux-systemd/caddy.service
  chown root:root /usr/local/bin/caddy
  setcap 'cap_net_bind_service=+eip' /usr/local/bin/caddy
  test_or_mkdir /etc/caddy
  test_or_mkdir /etc/caddy/vhosts
  chown -R root:www-data /etc/caddy
  test_or_mkdir /etc/ssl/caddy
  chown -R www-data:root /etc/ssl/caddy
  chmod 770 /etc/ssl/caddy
  touch /etc/caddy/Caddyfile
}

main() {
  load_cfg
  ins_caddy
}

# main
main

exit 0
