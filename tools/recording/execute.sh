#!/bin/sh
#execute.sh RECORDING ORANGE version 2018.03.22
   #FLDRACTION=/tools/update/action_flag.txt
   DATE=$(date +"%Y-%m-%d")
   LOGFILE=/tools/log/recording.log.$DATE
   TIMEOUT=$2
   OUTPUTFILE=$3
   CAMERAADDR=$1
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") timeout $TIMEOUT ffmpeg -i rtsp://@$CAMERAADDR:554/onvif2 -acodec copy -vcodec copy ./$OUTPUTFILE >> $LOGFILE
   #ffmpeg -i rtsp://@$1:554/onvif2 -f segment -segment_time $2 -acodec copy -vcodec copy ./$3.mp4
   #timeout $2 /usr/bin/ffmpeg -nostdin -i rtsp://@$1:554/onvif2 -vf "select=gt(scene\,0.003),setpts=N/(25*TB)" $3
   timeout $2 /usr/bin/ffmpeg -nostdin -i rtsp://@$1:554/onvif2 -acodec copy -vcodec copy $3
   #timeout $2 /usr/bin/ffmpeg -nostdin -i rtsp://$1:554/onvif1 -c:a aac -c:v copy -hls_list_size 65535 -strict -2 -hls_time 2 $3
   echo ${0##*/} $(date +"%Y-%m-%d %H:%M:%S") finish >> $LOGFILE
