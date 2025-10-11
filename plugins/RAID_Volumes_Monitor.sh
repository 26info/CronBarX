#!/bin/bash
# RAID & Volumes Monitor - CronBarX

echo "🔗 Тома"
echo "---"

# Проверяем наличие RAID массивов
if diskutil list | grep -q "Apple_RAID"; then
    echo "🎯 RAID массивы:"
    diskutil list | grep -A 5 "Apple_RAID" | while read line; do
        if [[ "$line" =~ /dev/disk* ]]; then
            echo "• $line"
        fi
    done
else
    echo "🔍 RAID массивы не найдены"
fi

# Показываем все тома
echo "---"
echo "💾 Смонтированные тома:"
mount | grep "^/dev" | while read device on mountpoint type options; do
    disk_name=$(basename "$device")
    echo "• $disk_name → $mountpoint"
done

echo "---"
echo "🔄 Обновить | refresh=true"
echo "📊 Дисковая утилита | shell=open -a \"Disk Utility\""