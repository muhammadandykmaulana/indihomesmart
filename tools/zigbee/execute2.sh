#!/bin/sh
#execute2.sh version 2016.11.04
   FLDRACTION=/tools/update/action_flag.txt
   LOGFILE=/var/log/execute2.log
   FLDRUPDATE=/tools/zigbee/remote.zip

echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") $1 >> $LOGFILE;

if [ -f $1 ]; then
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "file zip exist. proceeding " >> $LOGFILE;
   unzip -l $1 >> $LOGFILE;
   unzip -o $1 -d /tools/zigbee/
   rm -f $1
else
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "file update not exist" >> $LOGFILE;
fi
