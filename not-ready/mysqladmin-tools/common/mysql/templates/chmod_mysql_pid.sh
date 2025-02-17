#!/bin/bash

pid_file=$1
times=0
while [ ! -s ${pid_file} ]; do
    let times=${times}+1
    if [ ${times} -ge 15 ]; then
      echo ""
      echo "MySQL startup timed out."
      exit 2
    fi
    sleep 1;
    echo -e ".\c";
done
chmod a+r ${pid_file}