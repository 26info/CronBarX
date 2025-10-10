#!/bin/bash

# Parser Test Script - Проверка парсинга сложных команд

echo "🔍 Тест Парсера Команд"
echo "---"

# Тестовые команды для проверки парсинга
echo "1. Команды с pipe символами"
echo "-- Pipe в кавычках | shell=echo \"текст | текст\""
echo "-- Pipe вне кавычек | shell=ps aux | grep Dock"

echo "---"

# Команды с экранированием
echo "2. Экранирование символов"
echo "-- Экранированный pipe | shell=echo текст \\| текст"
echo "-- Экранированные кавычки | shell=echo \\\"hello\\\""

echo "---"

# Многострочные команды
echo "3. Многострочные команды"
echo "-- Многострочная команда | shell=echo 'строка1' && echo 'строка2'"
echo "-- Команда с переносами | shell=for i in 1 2 3; do echo \"номер: \$i\"; done"

echo "---"

# Сложные параметры
echo "4. Сложные параметры"
echo "-- JSON вывод | shell=system_profiler SPHardwareDataType -json | head -5"
echo "-- XML вывод | shell=system_profiler SPHardwareDataType -xml | head -5"

echo "---"

# Команды с временными файлами
echo "5. Работа с файлами"
echo "-- Создание файла | shell=echo 'тест' > /tmp/cronbarx_test.txt && cat /tmp/cronbarx_test.txt"
echo "-- Удаление файла | shell=rm -f /tmp/cronbarx_test.txt && echo 'файл удален'"

echo "---"

# Сетевые команды
echo "6. Сетевые команды"
echo "-- Проверка сети | shell=curl -s https://httpbin.org/get | head -3"
echo "-- Локальный хост | shell=ping -c 1 localhost"

echo "---"

echo "📊 Статус тестирования | refresh=true"