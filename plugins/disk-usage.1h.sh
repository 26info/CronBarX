#!/bin/bash

# Получаем информацию о диске в переменную
disk_info=$(df -h | grep -E "(Volumes/Data)" | grep "/dev/disk3s1")

# Проверяем, есть ли данные
if [ -n "$disk_info" ]; then
    # Пример обработки - извлекаем процент использования
    usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
    used=$(echo "$disk_info" | awk '{print $3}')
    total=$(echo "$disk_info" | awk '{print $2}')
    
    # Определяем иконку в зависимости от процента использования
    if [ "$usage_percent" -lt 70 ]; then
        icon="💾"
    elif [ "$usage_percent" -lt 90 ]; then
        icon="⚠️"
    else
        icon="🚨"
    fi
    
    echo "$icon $usage_percent%"
    echo "---"
    echo "Информация о диске:"
    echo "$disk_info"
    echo "Использовано: $used из $total"
else
    echo "💾 не найден"
    echo "---"
fi

echo "---"
echo "🔄 Обновить | refresh=true"
