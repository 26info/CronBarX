#!/bin/bash
# Services Monitor - CronBarX

echo "⚙️ Сервисы"
echo "---"

# Проверяем ключевые сервисы
services=("com.apple.apsd" "com.apple.netbiosd" "com.apple.mDNSResponder")

for service in "${services[@]}"; do
    if launchctl list | grep -q "$service"; then
        echo "✅ $service"
    else
        echo "❌ $service"
    fi
done

echo "---"
echo "🔄 Обновить | refresh=true"
echo "🔍 Монитор активности | shell=open -a \"Activity Monitor\""