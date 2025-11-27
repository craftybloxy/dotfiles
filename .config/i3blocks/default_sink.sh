#!/bin/bash

# Get default sink name
default_sink=$(pactl get-default-sink | sed 's/[._].*//')

# Get volume of the default sink
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)

# Get mute status
mute=$(pactl get-sink-mute @DEFAULT_SINK@)

# Determine the sink type (alsa or bluez)
if [[ "$default_sink" == bluez* ]]; then
  sink_type="󰂯"

else
  sink_type="󰓃"
fi

# Output based on mute status
if [ "$mute" == "Mute: yes" ]; then
  echo "$sink_type $default_sink"
else
  echo "$sink_type $default_sink"
fi
