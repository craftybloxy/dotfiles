#!/bin/bash

brightness=$(xrandr --verbose | grep -i brightness |tail -1)

if [ "$brightness" == "	Brightness: 0.30" ]; then
  xrandr --output HDMI-1 --brightness 1
else
  xrandr --output HDMI-1 --brightness 0.3
fi
