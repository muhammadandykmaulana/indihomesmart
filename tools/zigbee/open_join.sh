echo "Open join for 10seconds..."
echo "Press CTRL-] and type quit to Exit"
echo -n -e "\x41\x54\x2B\x08\x08\x50\x4A\x10\x85" > /dev/ttyS2; cat -v < /dev/ttyS2
zigbee_control display |grep -ia ZGB
