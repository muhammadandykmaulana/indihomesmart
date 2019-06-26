#!/bin/sh
#delete_log.sh 2017-09-07
. /lib/lsb/init-functions

find /tools/log/ -mindepth 1 -maxdepth 1 -type f -mtime +3 -name *.log* -exec rm -fv {} \;
