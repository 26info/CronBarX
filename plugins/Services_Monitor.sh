#!/bin/bash
# Services Monitor - CronBarX

echo "⚙️ Сервисы"
echo "---"

# Проверяем ключевые сервисы
services=("com.apple.apsd" "com.apple.netbiosd" "com.apple.mDNSResponder")

for service in "${services[@]}"; do
    if launchctl list | grep -q "$service"; then
        status="✅"
    else
        status="❌"
    fi
    # Выводим имя сервиса без префикса com.apple. для лучшей читаемости
    display_name=$(echo "$service" | sed 's/^com\.apple\.//')
    echo "$status $display_name"
done

echo "---"
echo "🔄 Обновить | refresh=true"
echo "🔍 Монитор активности | shell=open param1=\"-a\" param2=\"Activity Monitor\""
echo "⚙️ Системные настройки | shell=open param1=\"x-apple.systempreferences:\""
echo "---"
echo "📊 Всего сервисов: $(launchctl list | wc -l | tr -d ' ')"
echo "🕐 $(date '+%H:%M:%S')"
