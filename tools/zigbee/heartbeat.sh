#!/bin/sh
LOG='/dev/null/'

echo echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "mode 7 out" >> $LOG
gpio write 7 0
gpio mode 7 out
sleep 1
gpio mode 7 in
echo echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "mode 7 in" >> $LOG
exit 0
