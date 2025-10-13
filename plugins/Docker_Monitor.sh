#!/bin/bash
# Docker Monitor - CronBarX

# Проверяем, установлен ли Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "🐳 Docker"
    echo "---"
    echo "❌ Docker не установлен"
    echo "📥 Установить Docker | shell=open param1=\"https://docs.docker.com/desktop/install/mac-install/\""
    exit 0
fi

# Проверяем, запущен ли Docker демон
if ! docker info >/dev/null 2>&1; then
    echo "🐳 Docker"
    echo "---"
    echo "🔴 Docker демон не запущен"
    echo "🚀 Запустить Docker Desktop | shell=open param1=-a param2=\"Docker\""
    echo "---"
    echo "📋 Проверить статус | shell=docker info"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Получаем информацию о контейнерах
containers_running=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
containers_total=$(docker ps -a -q 2>/dev/null | wc -l | tr -d ' ')

# Основная информация в статусной строке
if [ "$containers_running" -eq 0 ]; then
    echo "🐳 $containers_total"
else
    echo "🐳 $containers_running/$containers_total"
fi

echo "---"
echo "📦 Контейнеры: $containers_running запущено, $containers_total всего"

# Показываем запущенные контейнеры
if [ "$containers_running" -gt 0 ]; then
    echo "---"
    echo "🚀 Запущенные контейнеры:"
    docker ps --format "• {{.Names}} ({{.Status}})| color=green" | head -5
fi

# Показываем остановленные контейнеры (если есть)
stopped_containers=$((containers_total - containers_running))
if [ "$stopped_containers" -gt 0 ]; then
    echo "---"
    echo "⏸️ Остановленные: $stopped_containers"
    docker ps -a --filter "status=exited" --filter "status=created" --format "• {{.Names}}| color=gray" | head -3
fi

echo "---"
echo "🎛️ Docker Desktop | shell=open param1=-a param2=\"Docker\""
echo "📊 Подробная информация | shell=docker param1=stats param2=--no-stream"
echo "---"
echo "🔄 Обновить | refresh=true"
echo "⚙️ Настройки | shell=open param1=-a param2=\"Docker\""
