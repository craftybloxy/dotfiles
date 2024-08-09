while true; do
	BATTERY_INFO=$(acpi -b | grep "Battery ${BATTERY}")
	BATTERY_POWER=$(echo "${BATTERY_INFO}" | grep -o '[0-9]\+%' | tr -d '%')
  if [[ "${BATTERY_POWER}" -le 19 ]]; then
		loginctl suspend
  fi
	sleep 180
done
