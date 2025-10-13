#!/bin/bash
# CPU Load Monitor - CronBarX

get_cpu_usage() {
    # Получаем загрузку CPU
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    local load_avg=$(sysctl -n vm.loadavg | awk '{print $2, $3, $4}')
    
    echo "$cpu_usage:$load_avg"
}

# Получаем информацию
IFS=':' read -r cpu_percent load_avg <<< "$(get_cpu_usage)"

echo "🚀 ${cpu_percent}%"
echo "---"
echo "💻 Загрузка CPU: ${cpu_percent}%"
echo "📊 Нагрузка: $load_avg"
echo "---"
echo "🔥 Топ процессов по CPU:"
ps -erco %cpu,comm | head -6 | while read line; do
    echo "• $line"
done
echo "---"
echo "🔍 Монитор активности | shell=open \"Activity Monitor\""
