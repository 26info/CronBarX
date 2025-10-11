#!/bin/bash
# System Dashboard - CronBarX

# Память
memory_percent=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100 - $5}' | sed 's/%//')

# CPU
cpu_percent=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')

# Диск
disk_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')

# Батарея
battery_percent=$(pmset -g batt | grep -o "[0-9]*%" | sed 's/%//')

echo "📊 $cpu_percent%/$memory_percent%"
echo "---"
echo "🚀 Системный дашборд"
echo "---"
echo "🧠 Память: ${memory_percent}% | color=$(get_color $memory_percent)"
echo "💻 CPU: ${cpu_percent}% | color=$(get_color $cpu_percent)"
echo "💾 Диск: ${disk_usage}% | color=$(get_color $disk_usage)"
echo "🔋 Батарея: ${battery_percent}% | color=$(get_color $battery_percent)"
echo "---"
echo "🔄 Обновить | refresh=true"