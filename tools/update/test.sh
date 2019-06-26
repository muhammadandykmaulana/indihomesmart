#!/bin/sh

echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") >> /var/log/zigbee.log
