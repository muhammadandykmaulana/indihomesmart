zigbee_control stop
stty -F /dev/ttyS2 raw
echo -n -e "\x41\x54\x2B\x07\x08\x52\x43\x9B">/dev/ttyS2;cat -v < /dev/ttyS2
zigbee_control start
