#!/bin/bash

#echo "$(date '+%Y-%m-%d %H:%M:%S')"
#echo "---"

# Получаем информацию о диске в переменную
disk_info=$(df -h | grep -E "(Volumes/Data)" | grep "/dev/disk3s1")

# Проверяем, есть ли данные
if [ -n "$disk_info" ]; then
    # Пример обработки - извлекаем процент использования
    usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')

    used=$(echo "$disk_info" | awk '{print $3}')
    total=$(echo "$disk_info" | awk '{print $2}')

    # Выводим информацию с цветовой индикацией
    if [ "$usage_percent" -lt 70 ]; then
        color="green"  # зеленый
    elif [ "$usage_percent" -lt 85 ]; then
        color="orange"  # желтый/оранжевый
     else
        color="red"  # красный
    fi

    echo "💾 $usage_percent% | color=${color}"
    echo "---"
    echo "Информация о диске:"
    echo "$disk_info | color=${color}"
    echo "Использовано: $used из $total"
else
    echo "💾 не найден"
    echo "---"
fi


echo "---"
echo "Refresh | refresh=true terminal=false"
