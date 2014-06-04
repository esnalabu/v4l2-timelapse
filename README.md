v4l2-timelapse
==============
Linux bash script to make timelapse from v4l2 device.
DEPENDENCY:
    gstreamer0.10
    ffmpeg 0.8.10
    v4l2:
        libv4l and libv4l-dev
        v4l-utils
        qv4l2 (may be part of v4l-utils)
        v4l2ucp
    VLC for playback"
 
Your camera might require a different caps(default is made for Logitech c920). Check your camera capabilities with [ v4l2-ctl --list-formats-ext ] and then check the gstreamer pipeline in the script.

