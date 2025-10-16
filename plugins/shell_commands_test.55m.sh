#!/bin/bash

# Test Script for Shell Commands - CronBarX Plugin Debug
# Проверка разных вариантов shell команд

echo "🔧 Тестирование Shell Команд"
echo "---"

# Простые команды
echo "1. Простые команды"
echo "-- Проверить дату | shell=date"
echo "-- Список процессов | shell=ps aux | head -5"
echo "-- Текущая директория | shell=pwd"

echo "---"

# Команды с кавычками
echo "2. Команды с кавычками"
echo "-- Одинарные кавычки | shell=echo 'Hello World'"
echo "-- Двойные кавычки | shell=echo \"Current user: \$USER\""
echo "-- Смешанные кавычки | shell=echo 'User: '\$USER''"

echo "---"

# Команды с параметрами
echo "3. Команды с параметрами"
echo "-- Много параметров | shell=ls -la /Applications | head -3"
echo "-- Сложные параметры | shell=find ~/Downloads -name \"*.txt\" -maxdepth 1 | head -3"

echo "---"

# Системные команды
echo "4. Системные команды"
echo "-- Статус Gatekeeper | shell=spctl --status"
echo "-- Список разрешений | shell=spctl --list | head -5"
echo "-- Инфо о системе | shell=sw_vers"

echo "---"

# Команды с перенаправлением
echo "5. Команды с перенаправлением"
echo "-- Перенаправление вывода | shell=ls /Applications > /tmp/test_apps.txt && cat /tmp/test_apps.txt | head -3"
echo "-- Конвейер | shell=ps aux | grep -v grep | grep -i dock | head -2"

echo "---"

# Команды с переменными
echo "6. Команды с переменными"
echo "-- Переменные среды | shell=echo \"PATH: \$PATH\" | head -1"
echo "-- Вычисляемые переменные | shell=echo \"Домашняя папка: \$HOME, Пользователь: \$USER\""

echo "---"

# Команды с условиями
echo "7. Команды с условиями"
echo "-- Проверка файла | shell=if [ -f ~/.bash_profile ]; then echo \"Файл существует\"; else echo \"Файл отсутствует\"; fi"
echo "-- Проверка директории | shell=if [ -d /Applications ]; then echo \"Директория найдена\"; else echo \"Директория не найдена\"; fi"

echo "---"

# Команды sudo
echo "8. Команды sudo (осторожно!)"
echo "-- Статус SIP | shell=csrutil status"
echo "-- Список запущенных служб | shell=launchctl list | head -5"

echo "---"

# Команды с ошибками
echo "9. Команды с ошибками (для теста)"
echo "-- Несуществующая команда | shell=some_nonexistent_command"
echo "-- Неправильный путь | shell=ls /nonexistent/path"
echo "-- Отказ в доступе | shell=cat /etc/sudoers"

echo "---"

# Длительные команды
echo "10. Длительные команды"
echo "-- Списк больших файлов | shell=find /System -type f -size +10M 2>/dev/null | head -3"
echo "-- Проверка сети | shell=ping -c 2 google.com"

echo "---"

# Команды AppleScript
echo "11. Команды AppleScript"
echo "-- Простой AppleScript | shell=osascript -e 'display notification \"Тестовое уведомление\" with title \"CronBarX\"'"
echo "-- Диалоговое окно | shell=osascript -e 'tell app \"System Events\" to display dialog \"Тестовое сообщение\"'"

echo "---"

# Команды открытия приложений
echo "12. Команды открытия приложений"
echo "-- Открыть Finder | shell=open /System/Library/CoreServices/Finder.app"
echo "-- Открыть Настройки | shell=open x-apple.systempreferences:com.apple.preference.security"
echo "-- Открыть Терминал | shell=open -a Terminal"

echo "---"

# Специальные символы
echo "13. Специальные символы"
echo "-- Символы в путях | shell=ls /Library/Application\\ Support/ | head -3"
echo "-- Подстановочные знаки | shell=ls ~/Desktop/*.txt 2>/dev/null | head -3"

echo "---"

echo "🔄 Обновить тесты | refresh=true"
echo "🧹 Очистить логи | shell=rm -f /tmp/test_*.txt && echo \"Логи очищены\""
