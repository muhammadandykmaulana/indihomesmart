#!/bin/sh
#Versi 20161110
. /lib/lsb/init-functions

MAC=$(cat /sys/class/net/eth0/address | tr -d :)

#####Setting UP hostname based on MAC eth0
TMPHOSTNAME=$(cat /sys/class/net/eth0/address | tr -d : |grep -o '.\{6\}$')
echo t-home_$TMPHOSTNAME > /etc/hostname
sysctl -w kernel.hostname=t-home_$TMPHOSTNAME
#####Remove log files
mv -f /var/log/umtskeeper.log /var/log/umtskeeper.log.old 2> /dev/null

#####HOSTAPD SETTING
iw wlan0 set power_save off > /dev/null &
/tools/hostapd/hostapd_start.sh start &

#####Starting up iptables NAT
iptables-restore < /tools/iptables.ipv4.nat

/tools/zigbee/zigbee_control.sh start &

/tools/modem/modem_start.sh &

echo $MAC > /tools/openvpn/auth.txt
echo $MAC >> /tools/openvpn/auth.txt
openvpn --config /tools/openvpn/client.ovpn
