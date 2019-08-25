#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.09
# last test environment: xxxx
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
cfg_file="$(dirname ${BASH_SOURCE[0]})/caddy_cfg.sh"
dir_getcaddy='/opt/git/getcaddy'

# function
load_cfg() {
  if [[ -r ${cfg_file} ]]; then
    source ${cfg_file}
  else
    exit 1
  fi
}

ins_caddy() {
  test_or_mkdir ${dir_getcaddy}
  wget https://getcaddy.com -O "${dir_getcaddy}/getcaddy.sh"
  caddy_pulgin_sp_by_comma="$(echo ${caddy_pulgin_s[@]} | sed 's/ /,/g')"
  bash "${dir_getcaddy}/getcaddy.sh" personal "${caddy_pulgin_sp_by_comma}"
  chown root:root /usr/local/bin/caddy
  setcap 'cap_net_bind_service=+eip' /usr/local/bin/caddy
  wget https://raw.githubusercontent.com/caddyserver/caddy/master/dist/init/linux-systemd/caddy.service -O /lib/systemd/system/caddy.service
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
