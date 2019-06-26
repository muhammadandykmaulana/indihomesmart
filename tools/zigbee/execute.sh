#!/bin/sh
#execute.sh ORANGE version 2018.03.22b
   FLDRACTION=/tools/update/action_flag.txt
   DATE=$(date +"%Y-%m-%d")
   LOGFILE=/tools/log/zigbee.log.$DATE
   FLDRUPDATE=/tools/update/firmware.zip

if [ -f $FLDRUPDATE ]; then
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "file update exist. proceed with update" >> $LOGFILE;
   unzip -l $FLDRUPDATE >> $LOGFILE;
   unzip -o $FLDRUPDATE -d /tools/
   rm -f $FLDRUPDATE
else
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "file update not exist" >> $LOGFILE;
fi

if [ -f $FLDRACTION ] 
then
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Action_flag Found..." >> $LOGFILE;
   ACTIONFLAG=`cat $FLDRACTION`;
   if [ $ACTIONFLAG -eq 1 ]
   then
      echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Action_flag 1 Found. Restarting Zigbee Application in 3 seconds..." >> $LOGFILE
      sleep 3
      /tools/zigbee/zigbee_control.sh restart > /dev/null &
      echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Restart Complete.." >> $LOGFILE
   fi
   rm -f $FLDRACTION

else
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Completed without action_flag.." >> $LOGFILE
   exit 1
fi
