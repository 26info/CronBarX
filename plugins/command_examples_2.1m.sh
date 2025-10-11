#!/bin/bash
# Большая коллекция shell команд - CronBarX
# Все команды показывают результат пользователю

echo "🛠️ Примеры команд"
echo "---"

# 1. СИСТЕМНАЯ ИНФОРМАЦИЯ
echo "💻 Системная информация"
echo "-- Время и дата | shell=date > /tmp/date.txt; osascript -e 'display notification (do shell script \"cat /tmp/date.txt\") with title \"Текущее время\"'"
echo "-- Имя хоста | shell=hostname > /tmp/hostname.txt; osascript -e 'display dialog \"Имя компьютера: \" & (do shell script \"cat /tmp/hostname.txt\") buttons {\"OK\"}'"
echo "-- Версия macOS | shell=sw_vers > /tmp/macos.txt; osascript -e 'display dialog \"Версия macOS:\n\n\" & (do shell script \"cat /tmp/macos.txt\") buttons {\"OK\"}'"
echo "-- Имя пользователя | shell=whoami > /tmp/user.txt; osascript -e 'display notification (do shell script \"cat /tmp/user.txt\") with title \"Текущий пользователь\"'"
echo "-- uptime системы | shell=uptime > /tmp/uptime.txt; osascript -e 'display dialog \"Время работы:\n\n\" & (do shell script \"cat /tmp/uptime.txt\") buttons {\"OK\"}'"

echo "---"

# 2. ПРОЦЕССЫ И ПАМЯТЬ
echo "🔄 Процессы и память"
echo "-- Топ-5 процессов по CPU | shell=ps aux | sort -nrk 3 | head -5 > /tmp/cpu.txt; osascript -e 'display dialog \"Топ процессов по CPU:\n\n\" & (do shell script \"cat /tmp/cpu.txt\") buttons {\"OK\"}'"
echo "-- Топ-5 процессов по памяти | shell=ps aux | sort -nrk 4 | head -5 > /tmp/memory.txt; osascript -e 'display dialog \"Топ процессов по памяти:\n\n\" & (do shell script \"cat /tmp/memory.txt\") buttons {\"OK\"}'"
echo "-- Использование памяти | shell=top -l 1 | grep 'PhysMem' > /tmp/ram.txt; osascript -e 'display dialog \"Использование памяти:\n\n\" & (do shell script \"cat /tmp/ram.txt\") buttons {\"OK\"}'"
echo "-- Активность процессов | shell=ps -eo pid,pcpu,pmem,comm | head -6 > /tmp/processes.txt; osascript -e 'display dialog \"Активные процессы:\n\n\" & (do shell script \"cat /tmp/processes.txt\") buttons {\"OK\"}'"

echo "---"

# 3. ДИСК И ФАЙЛЫ
echo "💾 Диск и файлы"
echo "-- Свободное место на диске | shell=df -h / > /tmp/disk.txt; osascript -e 'display dialog \"Дисковое пространство:\n\n\" & (do shell script \"cat /tmp/disk.txt\") buttons {\"OK\"}'"
echo "-- Размер домашней папки | shell=du -sh ~/ | cut -f1 > /tmp/home.txt; osascript -e 'display notification \"Домашняя папка: \" & (do shell script \"cat /tmp/home.txt\") with title \"Размер папки\"'"
echo "-- Количество файлов в Загрузках | shell=find ~/Downloads -type f | wc -l | tr -d ' ' > /tmp/count.txt; osascript -e 'display notification \"Файлов в Загрузках: \" & (do shell script \"cat /tmp/count.txt\") with title \"Статистика\"'"
echo "-- Последние файлы в Загрузках | shell=ls -lt ~/Downloads | head -6 > /tmp/recent.txt; osascript -e 'display dialog \"Последние файлы:\n\n\" & (do shell script \"cat /tmp/recent.txt\") buttons {\"OK\"}'"

echo "---"

# 4. СЕТЬ
echo "🌐 Сеть"
echo "-- Локальный IP | shell=ipconfig getifaddr en0 > /tmp/localip.txt; osascript -e 'display notification \"Локальный IP: \" & (do shell script \"cat /tmp/localip.txt\") with title \"Сеть\"'"
echo "-- Внешний IP | shell=curl -s http://ifconfig.me > /tmp/externalip.txt; osascript -e 'display notification \"Внешний IP: \" & (do shell script \"cat /tmp/externalip.txt\") with title \"Интернет\"'"
echo "-- Пинг Google | shell=ping -c 2 8.8.8.8 > /tmp/ping.txt 2>&1; osascript -e 'display dialog \"Результат ping:\n\n\" & (do shell script \"cat /tmp/ping.txt\") buttons {\"OK\"}'"
echo "-- Открытые порты | shell=netstat -an | grep LISTEN | head -8 > /tmp/ports.txt; osascript -e 'display dialog \"Открытые порты:\n\n\" & (do shell script \"cat /tmp/ports.txt\") buttons {\"OK\"}'"

echo "---"

# 5. АКТИВНОСТЬ ПОЛЬЗОВАТЕЛЯ
echo "👤 Активность пользователя"
echo "-- Текущие сессии | shell=who > /tmp/sessions.txt; osascript -e 'display dialog \"Активные сессии:\n\n\" & (do shell script \"cat /tmp/sessions.txt\") buttons {\"OK\"}'"
echo "-- Запущенные приложения | shell=osascript -e 'tell app \"System Events\" to get name of every process whose background only is false' | tr ',' '\n' > /tmp/apps.txt; osascript -e 'display dialog \"Запущенные приложения:\n\n\" & (do shell script \"cat /tmp/apps.txt\") buttons {\"OK\"}'"
echo "-- Активное окно | shell=osascript -e 'tell app \"System Events\" to get name of first application process whose frontmost is true' > /tmp/active.txt; osascript -e 'display notification \"Активное окно: \" & (do shell script \"cat /tmp/active.txt\") with title \"Фокус\"'"

echo "---"

# 6. БАТАРЕЯ И ЭНЕРГИЯ
echo "🔋 Батарея и энергия"
echo "-- Уровень заряда | shell=pmset -g batt | grep -Eo '\\d+%' > /tmp/battery.txt; osascript -e 'display notification \"Заряд батареи: \" & (do shell script \"cat /tmp/battery.txt\") with title \"Батарея\"'"
echo "-- Состояние батареи | shell=pmset -g batt | grep -o 'AC Power\\|Battery Power' > /tmp/power.txt; osascript -e 'display notification (do shell script \"cat /tmp/power.txt\") with title \"Питание\"'"

echo "---"

# 7. АППАРАТУРА
echo "🔧 Аппаратура"
echo "-- Модель Mac | shell=sysctl -n hw.model > /tmp/model.txt; osascript -e 'display notification \"Модель: \" & (do shell script \"cat /tmp/model.txt\") with title \"Mac\"'"
echo "-- Процессор | shell=sysctl -n machdep.cpu.brand_string > /tmp/cpuinfo.txt; osascript -e 'display dialog \"Процессор:\n\n\" & (do shell script \"cat /tmp/cpuinfo.txt\") buttons {\"OK\"}'"
echo "-- Объем памяти | shell=sysctl -n hw.memsize | awk '{\$1=\$1/1073741824; print \$1\" GB\";}' > /tmp/ram.txt; osascript -e 'display notification \"Оперативная память: \" & (do shell script \"cat /tmp/ram.txt\") with title \"Память\"'"

echo "---"

# 8. ПРИЛОЖЕНИЯ И СЛУЖБЫ
echo "📱 Приложения и службы"
echo "-- Запущенные службы | shell=launchctl list | grep -v '\-' | head -10 > /tmp/services.txt; osascript -e 'display dialog \"Запущенные службы:\n\n\" & (do shell script \"cat /tmp/services.txt\") buttons {\"OK\"}'"
echo "-- Установленные приложения | shell=ls /Applications | head -10 > /tmp/applications.txt; osascript -e 'display dialog \"Приложения в системе:\n\n\" & (do shell script \"cat /tmp/applications.txt\") buttons {\"OK\"}'"
echo "-- Версия Python | shell=python --version 2>/dev/null > /tmp/python.txt || echo 'Python не установлен' > /tmp/python.txt; osascript -e 'display notification (do shell script \"cat /tmp/python.txt\") with title \"Python\"'"

echo "---"

# 9. БЕЗОПАСНОСТЬ
echo "🛡️ Безопасность"
echo "-- Статус Gatekeeper | shell=spctl --status > /tmp/gatekeeper.txt; osascript -e 'display notification (do shell script \"cat /tmp/gatekeeper.txt\") with title \"Gatekeeper\"'"
echo "-- Статус SIP | shell=csrutil status 2>/dev/null | head -1 > /tmp/sip.txt; osascript -e 'display notification (do shell script \"cat /tmp/sip.txt\") with title \"SIP\"'"
echo "-- Статус файрволла | shell=defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null > /tmp/firewall.txt || echo 'Неизвестно' > /tmp/firewall.txt; osascript -e 'display notification \"Файрволл: \" & (do shell script \"cat /tmp/firewall.txt\") with title \"Безопасность\"'"

echo "---"

# 10. УВЕДОМЛЕНИЯ И ДИАЛОГИ
echo "💬 Уведомления и диалоги"
echo "-- Простое уведомление | shell=osascript -e 'display notification \"Это тестовое уведомление\" with title \"CronBarX\"'"
echo "-- Диалог с кнопкой OK | shell=osascript -e 'display dialog \"Это тестовое сообщение в диалоговом окне\" buttons {\"OK\"} default button 1'"
echo "-- Диалог с выбором | shell=osascript -e 'display dialog \"Выберите действие:\" buttons {\"Отмена\", \"Продолжить\"} default button 2'"
echo "-- Ввод текста | shell=result=$(osascript -e 'text returned of (display dialog \"Введите ваш текст:\" default answer \"\" buttons {\"Cancel\", \"OK\"} default button 2)'); osascript -e 'display notification \"Вы ввели: \" & \"'\"'\"'\"$result\"'\"'\"'\" with title \"Результат\"'"

echo "---"

# 11. ФАЙЛОВЫЕ ОПЕРАЦИИ
echo "📁 Файловые операции"
echo "-- Создать тестовый файл | shell=touch /tmp/test_$(date +%s).txt && osascript -e 'display notification \"Тестовый файл создан\" with title \"Файловая система\"'"
echo "-- Удалить тестовые файлы | shell=rm -f /tmp/test_*.txt && osascript -e 'display notification \"Тестовые файлы удалены\" with title \"Очистка\"'"
echo "-- Создать папку | shell=mkdir -p ~/Desktop/test_folder && osascript -e 'display notification \"Папка создана на Рабочем столе\" with title \"Файловая система\"'"
echo "-- Список временных файлов | shell=ls -la /tmp/*.txt 2>/dev/null | head -5 > /tmp/tempfiles.txt; osascript -e 'display dialog \"Временные файлы:\n\n\" & (do shell script \"cat /tmp/tempfiles.txt\") buttons {\"OK\"}'"

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
echo "-- Случайное число | shell=echo \$((RANDOM % 100)) > /tmp/random.txt; osascript -e 'display notification \"Случайное число: \" & (do shell script \"cat /tmp/random.txt\") with title \"Генератор\"'"
echo "-- Погода | shell=curl -s 'wttr.in?format=3' > /tmp/weather.txt; osascript -e 'display notification (do shell script \"cat /tmp/weather.txt\") with title \"Погода\"'"
echo "-- Текущий каталог | shell=ls -la | head -5 > /tmp/ls.txt; osascript -e 'display dialog \"Содержимое папки:\n\n\" & (do shell script \"cat /tmp/ls.txt\") buttons {\"OK\"}'"

echo "---"

# 14. КОМАНДЫ С ВЫВОДОМ В ДИАЛОГ
echo "📋 Команды с полным выводом"
echo "-- Полная системная информация | shell=system_profiler SPSoftwareDataType SPHardwareDataType 2>/dev/null | head -15 > /tmp/full_system.txt; osascript -e 'display dialog (do shell script \"cat /tmp/full_system.txt\") buttons {\"OK\"} default button 1'"
echo "-- Сетевые настройки | shell=ifconfig > /tmp/ifconfig.txt; osascript -e 'display dialog (do shell script \"head -20 /tmp/ifconfig.txt\") buttons {\"OK\"} default button 1'"
echo "-- История терминала | shell=history | tail -10 > /tmp/history.txt; osascript -e 'display dialog \"Последние команды:\n\n\" & (do shell script \"cat /tmp/history.txt\") buttons {\"OK\"}'"

echo "---"

# 15. ПРОДВИНУТЫЕ КОМАНДЫ
echo "🚀 Продвинутые команды"
echo "-- Статистика использования команд | shell=history | awk '{print \$2}' | sort | uniq -c | sort -nr | head -5 > /tmp/command_stats.txt; osascript -e 'display dialog \"Частота команд:\n\n\" & (do shell script \"cat /tmp/command_stats.txt\") buttons {\"OK\"}'"
echo "-- Размер папок в домашней директории | shell=du -sh ~/* 2>/dev/null | sort -hr > /tmp/folder_sizes.txt; osascript -e 'display dialog \"Размеры папок:\n\n\" & (do shell script \"cat /tmp/folder_sizes.txt\") buttons {\"OK\"}'"
echo "-- Системные логи (последние) | shell=log show --last 1m --info | tail -3 > /tmp/system_logs.txt; osascript -e 'display dialog \"Системные логи:\n\n\" & (do shell script \"cat /tmp/system_logs.txt\") buttons {\"OK\"}'"

echo "---"

# ОЧИСТКА
echo "🧹 Очистка временных файлов"
echo "-- Удалить все временные файлы | shell=rm -f /tmp/*.txt && osascript -e 'display notification \"Временные файлы удалены\" with title \"Очистка\"'"

echo "---"

echo "🔄 Обновить примеры | refresh=true"