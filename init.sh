#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
install_dir='/opt/sh/arashi'

# function
echo_info() {
  echo -e "\e[1;32m[Info]\e[0m $@"
}

# main
if [ $(id -u) -ne 0 ]; then
  echo 'Please rerun as root'
  exit 1
fi

if [ ! -d ${install_dir} ]; then
  mkdir -p ${install_dir}
  mkdir -p ${install_dir}/ext_sh
fi
cp -rf *.sh base_sh ${install_dir}
chmod +x ${install_dir}/arashi.sh

echo_info 'Init succeeded if no error is reported above'
echo_info "Please run : sudo bash ${install_dir}/arashi.sh"

exit 0
