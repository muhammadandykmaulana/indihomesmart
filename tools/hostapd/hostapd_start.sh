#!/bin/sh
#hostapd_start.sh Versi 20160826
. /lib/lsb/init-functions

    DATE=$(date +"%Y-%m-%d")
    APP_NAME=hostpad
    APP_LOG=/tools/log/hostapd.log.$DATE
    DEFPASS=12345678
    TMPHOSTNAME=$(cat /sys/class/net/eth0/address | tr -d : |grep -o '.\{6\}$')
    SSID=homegateway

status() {
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Checking $APP_NAME..." >> $APP_LOG
    echo "Checking $APP_NAME..."
    if pgrep -f "/usr/sbin/hostapd" > /dev/null; then
        PID=`pgrep hostapd`
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is Running. begin compare wifi_password.txt" >> $APP_LOG
        echo "$APP_NAME is Running. begin compare wifi_password.txt"
        CHANGE=0
        if [ -f /tools/update/wifi_password.txt ]; then
            OLD=$(tail -1 /tools/previous/wifi_password.txt)
            NEW=$(tail -1 /tools/update/wifi_password.txt)
            if [ "$OLD" = "$NEW" ]; then 
                echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Previous and update wifi password are the same" >> $APP_LOG
            else 
                echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Previous and update wifi password are different. will restart hostapd" >> $APP_LOG
                CHANGE=$((CHANGE+1)); 
            fi
        else
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "no update file found. abort compare wifi_password.txt" >> $APP_LOG
        fi

        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is Running. begin compare wifi_name.txt" >> $APP_LOG
        if [ -f /tools/update/wifi_name.txt ]; then
            OLD=$(tail -1 /tools/previous/wifi_name.txt)
            NEW=$(tail -1 /tools/update/wifi_name.txt)
            if [ "$OLD" = "$NEW" ]; then 
                echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Previous and update wifi name are the same" >> $APP_LOG
            else 
                echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Previous and update wifi name are different. will restart hostapd" >> $APP_LOG
                CHANGE=$((CHANGE+1)); 
            fi
        else
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "no update file found. abort compare wifi_name.txt" >> $APP_LOG
        fi

        if [ "$CHANGE" -gt 0 ]; then sh $0 restart; fi
        exit 0
    else
       echo "$APP_NAME is not running"
       echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is not running" >> $APP_LOG
       #exit 1
       retval=1
    fi
}


start() {
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Starting $APP_NAME" >> $APP_LOG
    if pgrep -f "/usr/sbin/hostapd" > /dev/null; then
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is already running" >> $APP_LOG;
        exit 2;
    else
        #####HOSTAPD SETTING
        cat /tools/hostapd_template.conf > /etc/hostapd.conf
        if [ -f /tools/update/wifi_password.txt ]; then
            echo wpa_passphrase=$(tail -1 /tools/update/wifi_password.txt) >> /etc/hostapd.conf;
            cp /tools/update/wifi_password.txt /tools/previous/wifi_password.txt
        else
            if [ -f /tools/previous/wifi_password.txt ]; then
                echo wpa_passphrase=$(tail -1 /tools/previous/wifi_password.txt) >> /etc/hostapd.conf;
            else
                echo wpa_passphrase=$DEFPASS >> /etc/hostapd.conf
            fi
        fi

        if [ -f /tools/update/wifi_name.txt ]; then
            echo ssid=$(tail -1 /tools/update/wifi_name.txt) >> /etc/hostapd.conf;
            cp /tools/update/wifi_name.txt /tools/previous/wifi_name.txt
        else
            if [ -f /tools/previous/wifi_name.txt ]; then
                echo ssid=$(tail -1 /tools/previous/wifi_name.txt) >> /etc/hostapd.conf;
            else
                echo ssid=$SSID >> /etc/hostapd.conf;
            fi
        fi

        /usr/sbin/hostapd -B /etc/hostapd.conf >> $APP_LOG;
        if [ $? = 0 ]; then 
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Starting $APP_NAME SUCCESS" >> $APP_LOG;
            exit 0;
        else
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Starting $APP_NAME FAILED" >> $APP_LOG;
            exit 1;
        fi
    fi
}

stop() {
    echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Stopping $APP_NAME" >> $APP_LOG
    if pgrep -f "/usr/sbin/hostapd" > /dev/null; then
        PID=`pgrep hostapd`
        killall hostapd
        if [ $? = 0 ]; then 
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Stopping $APP_NAME SUCCESS" >> $APP_LOG;
        else
            echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "Stopping $APP_NAME FAILED" >> $APP_LOG;
        fi
    else
        echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") "$APP_NAME is not running" >> $APP_LOG
    fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    exit $retval
    ;;
  restart|reload)
    sh $0 stop
    sleep 10
    sh $0 start
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart}"
    exit 1
esac
