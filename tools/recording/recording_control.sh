#!/bin/sh
#recording_control ORANGE V4.2_20180322
. /lib/lsb/init-functions
    JRE_HOME="/usr/lib/jvm/java-8-oracle"
    JVM_FLAGS=""
    APP_NAME="RECORDING"
    APP_PROG="jvRECORD"
    DATE=$(date +"%Y-%m-%d")
    APP_LOG="/tools/log/recording.log."$DATE
    SCREEN_LOG=/tools/log/zigbee_screen.log.$DATE
    APP_PID="/var/run/RECORDING.pid"
    APP_PATH="/tools/recording/"
    TMPHOSTNAME=$(cat /etc/hostname)

start() {
    if [ -n "`/bin/pidof "$APP_PROG"`" ]; then
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME"" Module: already running" >> $APP_LOG
        echo "$APP_NAME"" Module: already running"
        exit 11
    fi
    cd $APP_PATH
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Begin Cloud Recording" >> $APP_LOG
    exec "$JRE_HOME"/bin/"$APP_PROG" -Djava.library.path=/usr/lib/jvm/java-8-oracle/lib/arm/jli/:/usr/lib/jni/ -cp .:CloudIPCamera.jar: cloudipcamera/CloudIPCamera /dev/null $TMPHOSTNAME /tools/update/ >> $APP_LOG &
    echo $! > "$APP_PID"
    exit 0
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
    else
        echo "$APP_NAME is not running"
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
    tail "$APP_LOG" -f
    #telnet 127.0.0.1 1023
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|reload|display|force}"
    exit 1
esac
exit 0
