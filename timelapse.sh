#!/bin/bash

echo ""
echo ""
echo "Script to make timelapse from v4l2 device."
echo "DEPENDENCY:
    gstreamer0.10
    ffmpeg 0.8.10
    v4l2:
        libv4l and libv4l-dev
        v4l-utils
        qv4l2 (may be part of v4l-utils)
        v4l2ucp
    VLC for playback"
echo 
echo "Your camera might require a different caps(default is made for Logitech c920). Check your camera capabilities with [ v4l2-ctl --list-formats-ext ] and then check the gstreamer pipeline in the script." 
echo ""
read -p "Press return to start this script."

# Set up variables
device=/dev/video0 # Change this to match your usb camera
width=1280
height=720
framedelay=30 # Seconds between snapshots
outputrate=50 # Frames per seconds in output file
video=n
videooutname=timelapse.mp4
audio=n
audiopath=timelapse.mp3

continues=n
starttime=`date +"%F-%H-%M"`
pwd_orig=$PWD


# Set up subfolder
echo ""
echo ""
echo -e "This is pwd: \n" $pwd_orig "\n Trying to make subdir based on time : $starttime"
mkdir $starttime
echo ""
echo ""

# Take the images
while [ ! "$continues" == "y" ]; do
    unixtime=`date +%s`
    echo "Capturing images, type y and return to stop"
    gst-launch -e v4l2src device=$device num-buffers=1 ! video/x-raw-yuv,format=\(fourcc\)YUY2,width=$width,height=$height,framerate=5/1 ! ffmpegcolorspace ! \
       timeoverlay halign=right valign=bottom ! clockoverlay halign=left valign=bottom time-format="%Y/%m/%d %H:%M:%S" ! \
   videorate ! video/x-raw-rgb,framerate=1/1 ! ffmpegcolorspace ! pngenc snapshot=false ! multifilesink location="$starttime/frame$unixtime.png"

# Wait and take user input to stop capturing
    echo ""
    echo ""
    echo "Waiting $framedelay seconds before taking next frame. Press y and return to continue to video prossesing. To capture another frame just press return."
    read -t $framedelay continues
done

# Rename files with printf
echo ""
echo ""
echo "Changing filenames to match printf()..." 
a=1
for i in $starttime/*.png; do
    new=$(printf "frame%06d.png" ${a}) #06 pad to length of 6, meaning a 6 digits counter.
    mv ${i} $starttime/${new}
    let a=a+1
done


# Ask if you would like to make a movie now, then if you want sound.
echo ""
echo ""
echo "Make a movie now? Could take some time..."
echo "If so, type [ y ]:"
read video
echo ""
echo "With audio track $pwd_orig/$audiopath?"
echo "If so, type [ y ], else just press return:"
read audio

# Make it so.
if [ $video == "y" ]; then
    echo "Make it so!"
    if [ $audio == "y" ]; then
        ffmpeg -i timelapse.mp3 -r 100 -i $starttime/frame%06d.png -sameq -r $outputrate -ab 320k $starttime/timelapse.mp4
    else
        ffmpeg -i $starttime/frame%06d.png -sameq -r $outputrate $starttime/$videooutname
    fi
    echo "I did it!"
fi

# Open in vlc
echo ""
echo ""
echo "Opening video in vlc..."
vlc $starttime/timelapse.mp4

echo ""
echo ""
echo "Exiting."
exit 0
