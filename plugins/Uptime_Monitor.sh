#!/bin/bash
# Uptime Monitor - CronBarX

uptime_info=$(uptime)
uptime_days=$(echo "$uptime_info" | awk '{print $3}' | sed 's/,//')
load_average=$(echo "$uptime_info" | awk -F'load averages: ' '{print $2}')

echo "⏱️ $uptime_days"
echo "---"
echo "🖥️ Время работы: $uptime_days"
echo "📊 Нагрузка: $load_average"
echo "---"
echo "🔄 Обновить | refresh=true"