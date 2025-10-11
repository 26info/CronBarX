#!/bin/bash
# Docker Monitor - CronBarX

if command -v docker >/dev/null 2>&1; then
    containers_running=$(docker ps -q | wc -l)
    containers_total=$(docker ps -a -q | wc -l)
    
    echo "🐳 $containers_running/$containers_total"
    echo "---"
    echo "📦 Контейнеры: $containers_running запущено, $containers_total всего"
    
    # Показываем запущенные контейнеры
    if [ "$containers_running" -gt 0 ]; then
        echo "---"
        echo "🚀 Запущенные контейнеры:"
        docker ps --format "• {{.Names}} ({{.Status}})" | head -5
    fi
else
    echo "🐳 Docker"
    echo "---"
    echo "Docker не установлен"
fi

echo "---"
echo "🔄 Обновить | refresh=true"