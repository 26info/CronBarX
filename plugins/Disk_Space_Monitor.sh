#!/bin/bash
# Disk Space Monitor - CronBarX

echo "💾 Диски"
echo "---"

# Получаем информацию о всех смонтированных дисках
df -h | grep "^/dev/" | while read -r device size used free percent mount; do
    disk_name=$(echo "$device" | sed 's/\/dev\///')
    usage_percent=$(echo "$percent" | sed 's/%//')
    
    # Проверяем что usage_percent является числом
    if [[ "$usage_percent" =~ ^[0-9]+$ ]]; then
        if [ "$usage_percent" -gt 90 ]; then
            echo "🔴 $disk_name: $used/$size ($percent)"
        elif [ "$usage_percent" -gt 70 ]; then
            echo "🟡 $disk_name: $used/$size ($percent)"
        else
            echo "🟢 $disk_name: $used/$size ($percent)"
        fi
    else
        # Если не удалось распарсить проценты, выводим без цветовой индикации
        echo "💿 $disk_name: $used/$size ($percent)"
    fi
done

echo "---"

# Добавляем информацию о домашней директории
home_usage=$(df -h "$HOME" | awk 'NR==2 {print $5 " " $3 "/" $2}')
if [ -n "$home_usage" ]; then
    echo "🏠 Домашняя папка: $home_usage"
    echo "---"
fi

echo "🔄 Обновить | refresh=true"
echo "📊 Дисковая утилита | shell=open param1=-a param2=\"Disk Utility\""
echo "📁 Открыть домашнюю папку | shell=open param1=\"$HOME\""

# Добавляем время обновления
echo "---"
echo "🕐 Обновлено: $(date '+%H:%M:%S')"
