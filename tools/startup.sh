#!/bin/sh
#Versi GW_20180319a
. /lib/lsb/init-functions

MAC=$(cat /sys/class/net/eth0/address | tr -d :)
SER=$(cat /proc/cpuinfo | grep 'Serial'|awk '{print $3}')
PREFIXHOSTNAME="c0"
TMPHOSTNAME=$PREFIXHOSTNAME$(echo $MAC$SER | md5sum | awk '{print $1}'|tail -c 11)

#####Setting UP hostname based on $TMPHOSTNAME
echo $TMPHOSTNAME > /etc/hostname
sysctl -w kernel.hostname=$TMPHOSTNAME

WIFIMAC1=$(shuf -i 1-255 -n 1)
WIFIMAC2=$(shuf -i 1-255 -n 1)
WIFIMAC3=$(shuf -i 1-255 -n 1)

#Setting GPIO PIN 3,5,7	
gpio mode 3 out #(led-1)
gpio mode 5 out #(led-2)
gpio write 7 0
gpio mode 7 in
gpio write 3 0 #-matikankan LED-2
gpio write 5 0 #-matikan LED-2
/tools/zigbee/heartbeat.sh

#####Remove log files
mv -f /var/log/umtskeeper.log /var/log/umtskeeper.log.old 2> /dev/null

#####HOSTAPD SETTING
if [ ! -f /etc/modprobe.d/xradio_wlan.conf ]; then
    MACADDRWIFI=$(printf 'DC:44:6D:%02X:%02X:%02X\n' $WIFIMAC1 $WIFIMAC2 $WIFIMAC3);
    echo "options xradio_wlan macaddr=${MACADDRWIFI}" >/etc/modprobe.d/xradio_wlan.conf
fi
iw wlan0 set power_save off > /dev/null &
#/tools/hostapd/hostapd_start.sh start &

#####Starting up iptables NAT
#iptables-restore < /tools/iptables.ipv4.nat

/tools/zigbee/zigbee_control.sh start > /dev/null &
systemctl start watchdog > /dev/null &

#/tools/modem/modem_start.sh &

echo $TMPHOSTNAME > /tools/openvpn/auth.txt
echo $TMPHOSTNAME >> /tools/openvpn/auth.txt
openvpn --config /tools/openvpn/client.ovpn > /dev/null &
#iptables-restore < /tools/iptables.ipv4.nat > /dev/null &
