#!/bin/bash

# auther: tcneko <tcneko@outlook.com>
# start from: 2019.09
# last test environment: ubuntu 18.04
# description:

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# variables
file_rc_local='/etc/rc.local'

# function
enable_rc_local() {
  if [[ ! -x ${file_rc_local} ]]; then
    touch ${file_rc_local}
    chmod +x ${file_rc_local}
    echo '#!/bin/bash' >${file_rc_local}
  fi
}

main() {
  enable_rc_local
}

# main
main

exit 0
