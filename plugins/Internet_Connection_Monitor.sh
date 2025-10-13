#!/bin/bash
# Internet Connection Monitor - CronBarX

# Проверяем соединение с Google DNS
if ping -c 1 -W 1000 8.8.8.8 &> /dev/null; then
    echo "✅ Интернет"
    echo "---"
    echo "🌐 Соединение: ✅ Активно"
    
    # Проверяем DNS
    if nslookup google.com &> /dev/null; then
        echo "🔗 DNS: ✅ Работает"
    else
        echo "🔗 DNS: ❌ Ошибка"
    fi
    
else
    echo "❌ Интернет"
    echo "---"
    echo "🌐 Соединение: ❌ Прервано"
fi

echo "---"
echo "🔄 Обновить | refresh=true"
echo "🔧 Настройки сети | shell=open \"System Settings\""
