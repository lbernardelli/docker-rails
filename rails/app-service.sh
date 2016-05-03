#!/bin/bash -e
sv -w7 check syslog-ng
cd /$_USER
sleep 1
[[ -p pipe.log ]] || { echo "${PWD}/pipe.log is not a pipe"; exit 1; }
exec >pipe.log 2>&1 /sbin/setuser nobody \
  ./app.sh
  
