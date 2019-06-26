if pgrep -f "umtskeeper" > /dev/null
then
    echo "Running"
else
    echo "Stopped"
fi
