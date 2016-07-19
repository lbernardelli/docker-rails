#!/bin/bash -e
sv -w7 check syslog-ng
cd /$_USER
sleep 1
exec 2>&1 /sbin/setuser nobody \
  ./app.sh
  
