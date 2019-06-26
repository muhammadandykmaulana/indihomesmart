#!/bin/bash
#zigbee_control ORANGE V4.1_20180326
. /lib/lsb/init-functions
    JRE_HOME="/usr/lib/jvm/java-8-oracle"
    JVM_FLAGS=""
    APP_NAME="ZIGBEE_GW"
    APP_PROG="jvZIGBEE"
    DATE=$(date +"%Y-%m-%d")
    APP_LOG="/tools/log/zigbee.log."$DATE
    SCREEN_LOG=/dev/null
    APP_PID="/var/run/ZIGBEE_GW.pid"
    APP_PATH="/tools/zigbee/"
    TMPHOSTNAME=$(cat /etc/hostname)
    DEVICE="ttyS2"

start() {
    if [ -n "`/bin/pidof "$APP_PROG"`" ]; then
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME"" Module: already running" >> $APP_LOG
        echo "$APP_NAME"" Module: already running"
        exit 11
    fi
    cd $APP_PATH
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "ZIGBEE Coordinator NOT FOUND on USB. Try to start in Serial Mode " >> $APP_LOG
    exec "$JRE_HOME"/bin/"$APP_PROG" -Djava.library.path=/usr/lib/jvm/java-8-oracle/lib/arm/jli/:/usr/lib/jni/ -cp .:SmartControlGW.jar:SmartControlLib.jar:RXTXcomm.jar:pi4j-core.jar:pi4j-device.jar:pi4j-gpio-extension.jar:pi4j-service.jar:log4j-1.2.16.jar:com.google.guava_1.6.0.jar:commons-collections4-4.1.jar:iothub-java-device-client-1.0.14.jar:org.eclipse.paho.client.mqttv3-1.0.2.jar:commons-codec-1.10.jar:snmp4j-2.5.8.jar:snmp4j-agent-2.6.0.jar main/SmartControlGW /dev/$DEVICE $TMPHOSTNAME /tools/update/ >> $SCREEN_LOG &
    echo $! > "$APP_PID"
    exit 0
}

open() {
    echo "Open join for 10seconds..."
    echo "Press CTRL-] and type quit to Exit"
    echo -n -e "\x41\x54\x2B\x08\x08\x50\x4A\x10\x85">/dev/$DEVICE;
    timeout 11 telnet 127.0.0.1 1023 |grep -ia ZGB
}

case "$1" in
  start)
    start
    ;;
  stop)
    if [ -f $APP_PID ]; then
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Stopping $APP_NAME" >> $APP_LOG
        PID=`cat $APP_PID`
        cd $APP_PATH
        kill -HUP $PID
        rm -f $APP_PID
        if [ -f /var/lock/LCK..$DEVICE ];
        then
            rm -f /var/lock/LCK..$DEVICE
        fi
    else
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is not running"
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is not running" >> $APP_LOG
    fi
    ;;
  status)
    printf "%-50s" "Checking $APP_NAME..."
    if [ -f $APP_PID ]; then
       PID=`cat $APP_PID`
       if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
           printf "%s\n" "Process dead but pidfile exists"
           exit 3
       else
           echo "Running"
           exit 0
       fi
    else
       printf "%s\n" "Service not running"
       exit 10
    fi
    ;;
  restart|reload)
    $0 stop
    sleep 10
    $0 start
    ;;
  display)
    #tail "$APP_LOG" -f
    telnet 127.0.0.1 1023
    ;;
  join)
    open
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|reload|display|join}"
    exit 1
esac
exit 0
