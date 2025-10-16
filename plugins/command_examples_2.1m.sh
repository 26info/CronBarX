#!/bin/bash
# Большая коллекция shell команд - CronBarX
# Все команды показывают результат пользователю

echo "🛠️ Примеры команд"
echo "---"

# 1. СИСТЕМНАЯ ИНФОРМАЦИЯ
echo "💻 Системная информация"
echo "-- Время и дата | shell=date | osascript -e 'display notification (do shell script \"date\") with title \"Текущее время\"'"
echo "-- Имя хоста | shell=hostname | osascript -e 'display dialog \"Имя компьютера: \" & (do shell script \"hostname\") buttons {\"OK\"}'"
echo "-- Версия macOS | shell=sw_vers | osascript -e 'display dialog \"Версия macOS:\n\n\" & (do shell script \"sw_vers\") buttons {\"OK\"}'"
echo "-- Имя пользователя | shell=whoami | osascript -e 'display notification (do shell script \"whoami\") with title \"Текущий пользователь\"'"
echo "-- uptime системы | shell=uptime | osascript -e 'display dialog \"Время работы:\n\n\" & (do shell script \"uptime\") buttons {\"OK\"}'"

echo "---"

# 2. ПРОЦЕССЫ И ПАМЯТЬ
echo "🔄 Процессы и память"
echo "-- Топ-5 процессов по CPU | shell=ps aux | sort -nrk 3 | head -5 | osascript -e 'display dialog \"Топ процессов по CPU:\n\n\" & (do shell script \"ps aux | sort -nrk 3 | head -5\") buttons {\"OK\"}'"
echo "-- Топ-5 процессов по памяти | shell=ps aux | sort -nrk 4 | head -5 | osascript -e 'display dialog \"Топ процессов по памяти:\n\n\" & (do shell script \"ps aux | sort -nrk 4 | head -5\") buttons {\"OK\"}'"
echo "-- Использование памяти | shell=top -l 1 | grep 'PhysMem' | osascript -e 'display dialog \"Использование памяти:\n\n\" & (do shell script \"top -l 1 | grep \\\"PhysMem\\\"\") buttons {\"OK\"}'"
echo "-- Активность процессов | shell=ps -eo pid,pcpu,pmem,comm | head -6 | osascript -e 'display dialog \"Активные процессы:\n\n\" & (do shell script \"ps -eo pid,pcpu,pmem,comm | head -6\") buttons {\"OK\"}'"

echo "---"

# 3. ДИСК И ФАЙЛЫ
echo "💾 Диск и файлы"
echo "-- Свободное место на диске | shell=df -h / | osascript -e 'display dialog \"Дисковое пространство:\n\n\" & (do shell script \"df -h /\") buttons {\"OK\"}'"
echo "-- Размер домашней папки | shell=du -sh ~/ | cut -f1 | osascript -e 'display notification \"Домашняя папка: \" & (do shell script \"du -sh ~/ | cut -f1\") with title \"Размер папки\"'"
echo "-- Количество файлов в Загрузках | shell=find ~/Downloads -type f | wc -l | tr -d ' ' | osascript -e 'display notification \"Файлов в Загрузках: \" & (do shell script \"find ~/Downloads -type f | wc -l | tr -d \\\" \\\"\") with title \"Статистика\"'"
echo "-- Последние файлы в Загрузках | shell=ls -lt ~/Downloads | head -6 | osascript -e 'display dialog \"Последние файлы:\n\n\" & (do shell script \"ls -lt ~/Downloads | head -6\") buttons {\"OK\"}'"

echo "---"

# 4. СЕТЬ
echo "🌐 Сеть"
echo "-- Локальный IP | shell=ipconfig getifaddr en0 | osascript -e 'display notification \"Локальный IP: \" & (do shell script \"ipconfig getifaddr en0\") with title \"Сеть\"'"
echo "-- Внешний IP | shell=curl -s http://ifconfig.me | osascript -e 'display notification \"Внешний IP: \" & (do shell script \"curl -s http://ifconfig.me\") with title \"Интернет\"'"
echo "-- Пинг Google | shell=ping -c 2 8.8.8.8 | osascript -e 'display dialog \"Результат ping:\n\n\" & (do shell script \"ping -c 2 8.8.8.8 2>&1\") buttons {\"OK\"}'"
echo "-- Открытые порты | shell=netstat -an | grep LISTEN | head -8 | osascript -e 'display dialog \"Открытые порты:\n\n\" & (do shell script \"netstat -an | grep LISTEN | head -8\") buttons {\"OK\"}'"

echo "---"

# 5. АКТИВНОСТЬ ПОЛЬЗОВАТЕЛЯ
echo "👤 Активность пользователя"
echo "-- Текущие сессии | shell=who | osascript -e 'display dialog \"Активные сессии:\n\n\" & (do shell script \"who\") buttons {\"OK\"}'"
echo "-- Запущенные приложения | shell=osascript -e 'tell app \"System Events\" to get name of every process whose background only is false' | tr ',' '\\n' | osascript -e 'display dialog \"Запущенные приложения:\n\n\" & (do shell script \"osascript -e \\\"tell app \\\\\\\"System Events\\\\\\\" to get name of every process whose background only is false\\\" | tr \\\",\\\" \\\"\\n\\\"\") buttons {\"OK\"}'"
echo "-- Активное окно | shell=osascript -e 'tell app \"System Events\" to get name of first application process whose frontmost is true' | osascript -e 'display notification \"Активное окно: \" & (do shell script \"osascript -e \\\"tell app \\\\\\\"System Events\\\\\\\" to get name of first application process whose frontmost is true\\\"\") with title \"Фокус\"'"

echo "---"

# 6. БАТАРЕЯ И ЭНЕРГИЯ
echo "🔋 Батарея и энергия"
echo "-- Уровень заряда | shell=pmset -g batt | grep -Eo '\\d+%' | head -1 | osascript -e 'display notification \"Заряд батареи: \" & (do shell script \"pmset -g batt | grep -Eo \\\"\\\\\\\\d+%\\\" | head -1\") with title \"Батарея\"'"
echo "-- Состояние батареи | shell=pmset -g batt | grep -o 'AC Power\\|Battery Power' | head -1 | osascript -e 'display notification (do shell script \"pmset -g batt | grep -o \\\"AC Power\\\\\\\\|Battery Power\\\" | head -1\") with title \"Питание\"'"

echo "---"

# 7. АППАРАТУРА
echo "🔧 Аппаратура"
echo "-- Модель Mac | shell=sysctl -n hw.model | osascript -e 'display notification \"Модель: \" & (do shell script \"sysctl -n hw.model\") with title \"Mac\"'"
echo "-- Процессор | shell=sysctl -n machdep.cpu.brand_string | osascript -e 'display dialog \"Процессор:\n\n\" & (do shell script \"sysctl -n machdep.cpu.brand_string\") buttons {\"OK\"}'"
echo "-- Объем памяти | shell=sysctl -n hw.memsize | awk '{print \$1/1073741824\" GB\"}' | osascript -e 'display notification \"Оперативная память: \" & (do shell script \"sysctl -n hw.memsize | awk '{print \\\$1/1073741824\\\" GB\\\"}'\") with title \"Память\"'"

echo "---"

# 8. ПРИЛОЖЕНИЯ И СЛУЖБЫ
echo "📱 Приложения и службы"
echo "-- Запущенные службы | shell=launchctl list | grep -v '\\-' | head -10 | osascript -e 'display dialog \"Запущенные службы:\n\n\" & (do shell script \"launchctl list | grep -v \\\"-\\\" | head -10\") buttons {\"OK\"}'"
echo "-- Установленные приложения | shell=ls /Applications | head -10 | osascript -e 'display dialog \"Приложения в системе:\n\n\" & (do shell script \"ls /Applications | head -10\") buttons {\"OK\"}'"
echo "-- Версия Python | shell=python --version 2>/dev/null || echo 'Python не установлен' | osascript -e 'display notification (do shell script \"python --version 2>/dev/null || echo \\\"Python не установлен\\\"\") with title \"Python\"'"

echo "---"

# 9. БЕЗОПАСНОСТЬ
echo "🛡️ Безопасность"
echo "-- Статус Gatekeeper | shell=spctl --status | osascript -e 'display notification (do shell script \"spctl --status\") with title \"Gatekeeper\"'"
echo "-- Статус SIP | shell=csrutil status 2>/dev/null | head -1 | osascript -e 'display notification (do shell script \"csrutil status 2>/dev/null | head -1\") with title \"SIP\"'"
echo "-- Статус файрволла | shell=defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo 'Неизвестно' | osascript -e 'display notification \"Файрволл: \" & (do shell script \"defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo \\\"Неизвестно\\\"\") with title \"Безопасность\"'"

echo "---"

# 10. УВЕДОМЛЕНИЯ И ДИАЛОГИ
echo "💬 Уведомления и диалоги"
echo "-- Простое уведомление | shell=osascript -e 'display notification \"Это тестовое уведомление\" with title \"CronBarX\"'"
echo "-- Диалог с кнопкой OK | shell=osascript -e 'display dialog \"Это тестовое сообщение в диалоговом окне\" buttons {\"OK\"} default button 1'"
echo "-- Диалог с выбором | shell=osascript -e 'display dialog \"Выберите действие:\" buttons {\"Отмена\", \"Продолжить\"} default button 2'"
echo "-- Ввод текста | shell=result=\$(osascript -e 'text returned of (display dialog \"Введите ваш текст:\" default answer \"\" buttons {\"Cancel\", \"OK\"} default button 2)'); osascript -e 'display notification \"Вы ввели: \" & \"'\"'\"'\"\$result\"'\"'\"'\" with title \"Результат\"'"

echo "---"

# 11. ФАЙЛОВЫЕ ОПЕРАЦИИ
echo "📁 Файловые операции"
echo "-- Создать тестовый файл | shell=touch /tmp/test_\$(date +%s).txt && osascript -e 'display notification \"Тестовый файл создан\" with title \"Файловая система\"'"
echo "-- Удалить тестовые файлы | shell=rm -f /tmp/test_*.txt && osascript -e 'display notification \"Тестовые файлы удалены\" with title \"Очистка\"'"
echo "-- Создать папку | shell=mkdir -p ~/Desktop/test_folder && osascript -e 'display notification \"Папка создана на Рабочем столе\" with title \"Файловая система\"'"
echo "-- Список временных файлов | shell=ls -la /tmp/*.txt 2>/dev/null | head -5 | osascript -e 'display dialog \"Временные файлы:\n\n\" & (do shell script \"ls -la /tmp/*.txt 2>/dev/null | head -5\") buttons {\"OK\"}'"

echo "---"

# 12. СИСТЕМНЫЕ НАСТРОЙКИ
echo "⚙️ Системные настройки"
echo "-- Открыть настройки | shell=open x-apple.systempreferences:"
echo "-- Настройки безопасности | shell=open x-apple.systempreferences:com.apple.preference.security"
echo "-- Настройки дисплея | shell=open x-apple.systempreferences:com.apple.preference.displays"
echo "-- Настройки звука | shell=open x-apple.systempreferences:com.apple.preference.sound"

echo "---"

# 13. РАЗНОЕ
echo "🎯 Разное"
echo "-- Случайное число | shell=echo \$((RANDOM % 100)) | osascript -e 'display notification \"Случайное число: \" & (do shell script \"echo \\\$((RANDOM % 100))\") with title \"Генератор\"'"
echo "-- Погода | shell=curl -s 'wttr.in?format=3' | osascript -e 'display notification (do shell script \"curl -s \\\"wttr.in?format=3\\\"\") with title \"Погода\"'"
echo "-- Текущий каталог | shell=ls -la | head -5 | osascript -e 'display dialog \"Содержимое папки:\n\n\" & (do shell script \"ls -la | head -5\") buttons {\"OK\"}'"

echo "---"

# 14. КОМАНДЫ С ВЫВОДОМ В ДИАЛОГ
echo "📋 Команды с полным выводом"
echo "-- Полная системная информация | shell=system_profiler SPSoftwareDataType SPHardwareDataType 2>/dev/null | head -15 | osascript -e 'display dialog (do shell script \"system_profiler SPSoftwareDataType SPHardwareDataType 2>/dev/null | head -15\") buttons {\"OK\"} default button 1'"
echo "-- Сетевые настройки | shell=ifconfig | head -20 | osascript -e 'display dialog (do shell script \"ifconfig | head -20\") buttons {\"OK\"} default button 1'"
echo "-- История терминала | shell=history | tail -10 | osascript -e 'display dialog \"Последние команды:\n\n\" & (do shell script \"history | tail -10\") buttons {\"OK\"}'"

echo "---"

# 15. ПРОДВИНУТЫЕ КОМАНДЫ
echo "🚀 Продвинутые команды"
echo "-- Статистика использования команд | shell=history | awk '{print \$2}' | sort | uniq -c | sort -nr | head -5 | osascript -e 'display dialog \"Частота команд:\n\n\" & (do shell script \"history | awk '{print \\\$2}' | sort | uniq -c | sort -nr | head -5\") buttons {\"OK\"}'"
echo "-- Размер папок в домашней директории | shell=du -sh ~/* 2>/dev/null | sort -hr | osascript -e 'display dialog \"Размеры папок:\n\n\" & (do shell script \"du -sh ~/* 2>/dev/null | sort -hr\") buttons {\"OK\"}'"
echo "-- Системные логи (последние) | shell=log show --last 1m --info | tail -3 | osascript -e 'display dialog \"Системные логи:\n\n\" & (do shell script \"log show --last 1m --info | tail -3\") buttons {\"OK\"}'"

echo "---"

# ОЧИСТКА
echo "🧹 Очистка временных файлов"
echo "-- Удалить все временные файлы | shell=rm -f /tmp/*.txt && osascript -e 'display notification \"Временные файлы удалены\" with title \"Очистка\"'"

echo "---"

echo "🔄 Обновить примеры | refresh=true"
