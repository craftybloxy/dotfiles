#!/bin/bash
default_sink=$(pactl get-default-sink | sed 's/[._].*//')
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)

#!/bin/bash

# Get the mute status of the default sink
mute=$(pactl get-sink-mute @DEFAULT_SINK@)

# Check if the output indicates the sink is muted
if [ "$mute" == "Mute: oui" ]; then
  echo "Muted [$default_sink]"
else
  echo "$volume [$default_sink]"
fi



