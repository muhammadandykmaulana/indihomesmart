#!/bin/sh
#MODEM_START.sh V20160920
. /lib/lsb/init-functions

DATE=$(date +"%Y-%m-%d")
MODEM_LOG=/var/log/modem.log.$DATE

if [ -h /dev/gsmmodem ]
then
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "MODEM found on USB Mode" >> $MODEM_LOG
    if [ -f /tools/update/apn.txt ]; then
        APN=$(tail -1 /tools/update/apn.txt)
    else
        APN=internet;
    fi
    echo 'AT+CGDCONT=1,"IP","'$APN'"\r\n' >> /dev/ttyUSB1      
    
	if pgrep -f "/tools/modem/umtskeeper" > /dev/null
    then
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "UMTSKEEPER is Already running" >> $MODEM_LOG
    else
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Starting UMTSKEEPER" >> $MODEM_LOG
        /tools/modem/umtskeeper --sakisoperators "USBINTERFACE='1' OTHER='USBMODEM' \
        USBMODEM='12d1:1506' APN='CUSTOM_APN' CUSTOM_APN='m2minternet' SIM_PIN='1234' \
        APN_USER='0' APN_PASS='0'" --sakisswitches "--sudo --console" --devicename \
        'HUAWEI_MOBILE' --log --silent --monthstart 8 --nat 'no' --httpserver --httpport 8080 &
    fi
else
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "USB Modem NOT FOUND on USB. Let it start in HiLink Mode" >> $MODEM_LOG
fi
