#!/bin/bash
# Простые команды - CronBarX

echo "🔧 Быстрые команды"
echo "---"

echo "🕐 Время и дата"
echo "-- Текущее время: $(date '+%H:%M')"
echo "-- Текущая дата: $(date '+%d.%m.%Y')"

echo "---"

echo "💻 Система"
echo "-- Открыть Терминал | shell=open -a Terminal"
echo "-- Открыть Настройки | shell=open x-apple.systempreferences:"
echo "-- Монитор активности | shell=open -a 'Activity Monitor'"

echo "---"

echo "📁 Файлы"
echo "-- Домашняя папка | shell=open ~/"
echo "-- Загрузки | shell=open ~/Downloads"
echo "-- Документы | shell=open ~/Documents"

echo "---"

echo "🌐 Интернет"
echo "-- Браузер | shell=open -a Safari"
echo "-- Google | shell=open https://google.com"

echo "---"

echo "⚙️ Системные команды"
echo "-- Перезапустить Dock | shell=killall Dock"
echo "-- Скрыть/показать Dock | shell=defaults write com.apple.dock autohide -bool true; killall Dock"

echo "---"

echo "🔔 Уведомления"
echo "-- Тест уведомления | shell=osascript -e 'display notification \"Тест выполнен\" with title \"CronBarX\"'"
echo "-- Приветствие | shell=osascript -e 'display notification \"Привет, $(whoami)!\" with title \"Добро пожаловать\"'"

echo "---"
echo "🔄 Обновить | refresh=true"