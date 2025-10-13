#!/bin/bash
# Battery Monitor - CronBarX

battery_info=$(pmset -g batt)
battery_percent=$(echo "$battery_info" | grep -o "[0-9]*%" | sed 's/%//')
battery_status=$(echo "$battery_info" | grep -o "charging\|discharging\|AC attached")
battery_time=$(echo "$battery_info" | grep -o "[0-9]*:[0-9]* remaining" | head -1)

# Определяем иконку
if [ "$battery_status" = "charging" ]; then
    icon="⚡"
elif [ "$battery_percent" -gt 80 ]; then
    icon="🔋"
elif [ "$battery_percent" -gt 20 ]; then
    icon="🔋"
else
    icon="🪫"
fi

echo "${icon} ${battery_percent}%"
echo "---"
echo "🔋 Батарея: ${battery_percent}%"
echo "📊 Статус: $battery_status"
echo "⏱️ Осталось: $battery_time"
echo "---"
echo "⚙️ Настройки энергии | shell=open open \"x-apple.systempreferences:com.apple.preference.battery\""
