#!/bin/bash
# Disk Space Monitor - CronBarX

echo "💾 Диски"
echo "---"

# Получаем информацию о всех смонтированных дисках
df -h | grep "^/dev/" | while read device size used free percent mount; do
    disk_name=$(echo $device | sed 's/\/dev\///')
    usage_percent=$(echo $percent | sed 's/%//')
    
    if [ "$usage_percent" -gt 90 ]; then
        echo "🔴 $disk_name: $used/$size ($percent)"
    elif [ "$usage_percent" -gt 70 ]; then
        echo "🟡 $disk_name: $used/$size ($percent)"
    else
        echo "🟢 $disk_name: $used/$size ($percent)"
    fi
done

echo "---"
echo "🔄 Обновить | refresh=true"
echo "📊 Дисковая утилита | shell=open -a \"Disk Utility\""