#!/bin/bash

# tcneko <tcneko@outlook.com>
# create: 2019.08
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
install_dir='/opt/sh/arashi'

# function

# main
if [ $(id -u) -ne 0 ]; then
  echo 'Please rerun as root'
  exit 1
fi

if [ ! -d ${install_dir} ]; then
  mkdir -p ${install_dir}
fi
cp -rf *.sh base_sh ${install_dir}
mkdir ${install_dir}/ext_sh
chmod +x ${install_dir}/arashi.sh

echo 'Init succeeded if no error is reported above'
echo "Please run \"bash ${install_dir}/arashi.sh\" as root"

exit 0
