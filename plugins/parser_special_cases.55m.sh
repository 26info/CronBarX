#!/bin/bash

# Parser Test Script - Проверка парсинга сложных команд

echo "🔍 Тест Парсера Команд"
echo "---"

# Тестовые команды для проверки парсинга
echo "1. Команды с pipe символами"
echo "-- Pipe в кавычках | shell=echo \"текст | текст\" > /tmp/pipe_test.txt && osascript -e 'display notification (do shell script \"cat /tmp/pipe_test.txt\") with title \"Pipe Test\"'"
echo "-- Pipe вне кавычек | shell=ps aux | grep Dock | head -3 > /tmp/dock_process.txt && osascript -e 'display dialog \"Процессы Dock:\n\n\" & (do shell script \"cat /tmp/dock_process.txt\") buttons {\"OK\"}'"

echo "---"

# Команды с экранированием
echo "2. Экранирование символов"
echo "-- Экранированный pipe | shell=echo текст \\| текст > /tmp/escape_test.txt && osascript -e 'display notification (do shell script \"cat /tmp/escape_test.txt\") with title \"Escape Test\"'"
echo "-- Экранированные кавычки | shell=echo \\\"hello\\\" > /tmp/quotes_test.txt && osascript -e 'display dialog \"Экранированные кавычки:\n\n\" & (do shell script \"cat /tmp/quotes_test.txt\") buttons {\"OK\"}'"

echo "---"

# Многострочные команды
echo "3. Многострочные команды"
echo "-- Многострочная команда | shell=echo 'строка1' && echo 'строка2' > /tmp/multiline.txt && osascript -e 'display dialog \"Многострочный вывод:\n\n\" & (do shell script \"cat /tmp/multiline.txt\") buttons {\"OK\"}'"
echo "-- Команда с переносами | shell=for i in 1 2 3; do echo \"номер: \$i\"; done > /tmp/loop_test.txt && osascript -e 'display notification (do shell script \"cat /tmp/loop_test.txt\") with title \"Loop Test\"'"

echo "---"

# Сложные параметры
echo "4. Сложные параметры"
echo "-- JSON вывод | shell=system_profiler SPHardwareDataType -json 2>/dev/null | head -10 > /tmp/json_test.txt && osascript -e 'display dialog \"JSON вывод системы:\n\n\" & (do shell script \"head -5 /tmp/json_test.txt\") buttons {\"OK\"}'"
echo "-- XML вывод | shell=system_profiler SPHardwareDataType -xml 2>/dev/null | head -10 > /tmp/xml_test.txt && osascript -e 'display notification \"XML вывод сохранен в /tmp/xml_test.txt\" with title \"XML Test\"'"

echo "---"

# Команды с временными файлами
echo "5. Работа с файлами"
echo "-- Создание файла | shell=echo 'тест создания файла' > /tmp/cronbarx_test.txt && cat /tmp/cronbarx_test.txt && osascript -e 'display notification \"Файл создан: /tmp/cronbarx_test.txt\" with title \"File Test\"'"
echo "-- Удаление файла | shell=rm -f /tmp/cronbarx_test.txt && osascript -e 'display dialog \"Файл /tmp/cronbarx_test.txt удален\" buttons {\"OK\"} default button 1'"

echo "---"

# Сетевые команды
echo "6. Сетевые команды"
echo "-- Проверка сети | shell=curl -s --connect-timeout 5 https://httpbin.org/get | head -5 > /tmp/network_test.txt && osascript -e 'display dialog \"Ответ сервера:\n\n\" & (do shell script \"cat /tmp/network_test.txt\") buttons {\"OK\"}'"
echo "-- Локальный хост | shell=ping -c 2 localhost > /tmp/ping_test.txt && osascript -e 'display notification (do shell script \"tail -1 /tmp/ping_test.txt\") with title \"Ping Test\"'"

echo "---"

# Команды с переменными окружения
echo "7. Переменные окружения"
echo "-- Переменные пользователя | shell=echo \"Пользователь: \$USER\nДомашняя папка: \$HOME\" > /tmp/env_test.txt && osascript -e 'display dialog (do shell script \"cat /tmp/env_test.txt\") buttons {\"OK\"} default button 1'"
echo "-- Переменные пути | shell=echo \"PATH: \$PATH\" | head -1 > /tmp/path_test.txt && osascript -e 'display notification (do shell script \"cut -c1-50 /tmp/path_test.txt\") with title \"PATH Variable\"'"

echo "---"

# Команды с условиями
echo "8. Команды с условиями"
echo "-- Проверка файла | shell=if [ -f ~/.bash_profile ]; then echo 'Файл .bash_profile существует' > /tmp/check_test.txt; else echo 'Файл .bash_profile не найден' > /tmp/check_test.txt; fi && osascript -e 'display notification (do shell script \"cat /tmp/check_test.txt\") with title \"File Check\"'"
echo "-- Проверка команды | shell=which git > /tmp/git_test.txt 2>&1 && echo 'Git установлен' >> /tmp/git_test.txt || echo 'Git не найден' >> /tmp/git_test.txt && osascript -e 'display dialog \"Проверка Git:\n\n\" & (do shell script \"cat /tmp/git_test.txt\") buttons {\"OK\"}'"

echo "---"

# Команды с функциями
echo "9. Команды с функциями"
echo "-- Функция в одной строке | shell=test_func() { echo \"Тест функции выполнен успешно\"; }; test_func > /tmp/func_test.txt && osascript -e 'display notification (do shell script \"cat /tmp/func_test.txt\") with title \"Function Test\"'"
echo "-- Арифметические операции | shell=echo \"Результат: \$(( 5 + 3 ))\" > /tmp/math_test.txt && osascript -e 'display dialog \"Арифметическая операция:\n\n\" & (do shell script \"cat /tmp/math_test.txt\") buttons {\"OK\"}'"

echo "---"

# Тесты с уведомлениями и диалогами
echo "10. Прямые уведомления"
echo "-- Простое уведомление | shell=osascript -e 'display notification \"Тестовое уведомление через команду\" with title \"CronBarX Test\"'"
echo "-- Диалог с кнопками | shell=osascript -e 'display dialog \"Тестовый диалог с выбором\" buttons {\"Отмена\", \"Продолжить\"} default button 2'"
echo "-- Уведомление с результатом команды | shell=date | osascript -e 'display notification (do shell script \"date\") with title \"Текущее время\"'"
echo "-- Диалог с системной информацией | shell=user=\$(whoami); host=\$(hostname); os_version=\$(sw_vers -productVersion); osascript -e \"display dialog \\\"Пользователь: $user\\nХост: $host\\nОС: $os_version\\\" buttons {\\\"OK\\\"} default button 1\""

echo "---"

# Очистка временных файлов
echo "🧹 Очистка"
echo "-- Удалить все тестовые файлы | shell=rm -f /tmp/*_test.txt /tmp/*.txt && osascript -e 'display notification \"Все тестовые файлы удалены\" with title \"Очистка\"'"
echo "-- Показать оставшиеся файлы | shell=ls -la /tmp/*_test.txt 2>/dev/null > /tmp/remaining_files.txt || echo 'Файлов не найдено' > /tmp/remaining_files.txt && osascript -e 'display dialog \"Оставшиеся тестовые файлы:\n\n\" & (do shell script \"cat /tmp/remaining_files.txt\") buttons {\"OK\"}'"

echo "---"

echo "🔄 Обновить тесты | refresh=true"
