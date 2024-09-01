#!/bin/bash

# echo -E "\033[0;36ma"

BATTERY=0
BATTERY_INFO=$(acpi -b | grep "Battery ${BATTERY}")
BATTERY_STATE=$(echo "${BATTERY_INFO}" | grep -wo "Full\|Charging\|Discharging")
BATTERY_POWER=$(echo "${BATTERY_INFO}" | grep -o '[0-9]\+%' | tr -d '%')

URGENT_VALUE=15

if [[ "${BATTERY_STATE}" = "Charging" ]]; then
  echo "${BATTERY_POWER}% +󰂀"
  echo "${BATTERY_POWER}% +󰂀"
  echo "#FFD3B4"
elif [[ "${BATTERY_STATE}" = "Discharging" ]]; then
  echo "${BATTERY_POWER}% -󰂀"
  echo "${BATTERY_POWER}% -󰂀"
  
  if [[ "${BATTERY_POWER}" -le "${URGENT_VALUE}" ]]; then
    echo "#cc241d"
    notify-send -u critical "Battery low!" "Plug your laptop"
  else
    echo "#FFD3B4"
  fi
  
else
  echo "${BATTERY_POWER}% 󰂀"
  echo "${BATTERY_POWER}% 󰂀"
  echo "#FFD3B4"
fi

