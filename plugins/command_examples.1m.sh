#!/bin/bash
# Умные команды - CronBarX

# Получаем абсолютный путь к скрипту
SCRIPT_PATH="$0"

# Функция для показа диалога
show_dialog() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button 1" &>/dev/null
}

# Функция для показа уведомления
show_notification() {
    osascript -e "display notification \"$1\" with title \"$2\"" &>/dev/null
}

# Функции для команд
show_time() {
    show_notification "$(date +'%H:%M:%S %d.%m.%Y')" "Текущее время"
}

show_system() {
    local user=$(whoami)
    local host=$(hostname)
    local os_version=$(sw_vers -productVersion 2>/dev/null || echo "Неизвестно")
    local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Неизвестно")
    show_dialog "Системная информация:\n\nПользователь: $user\nХост: $host\nmacOS: $os_version\nПроцессор: $cpu"
}

show_processes() {
    local processes=$(ps aux | head -6 2>/dev/null || echo "Не удалось получить процессы")
    show_dialog "Топ процессов:\n\n$processes"
}

show_disk() {
    local disk_info=$(df -h / | head -2 2>/dev/null || echo "Не удалось получить информацию о диске")
    show_dialog "Дисковое пространство:\n\n$disk_info"
}

show_network() {
    local local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "Недоступно")
    local external_ip=$(curl -s --connect-timeout 5 http://ifconfig.me 2>/dev/null || echo "Недоступно")
    show_dialog "Сетевая информация:\n\nЛокальный IP: $local_ip\nВнешний IP: $external_ip"
}

show_battery() {
    local battery_info=$(pmset -g batt 2>/dev/null | grep -E "([0-9]+%)|(AC|Battery)" | head -1 || echo "Информация о батарее недоступна")
    show_notification "$battery_info" "Батарея"
}

# Основное меню
echo "🛠️ Умные команды"
echo "---"

echo "💻 Системная информация"
echo "-- 🕐 Показать время | shell=\"$SCRIPT_PATH\" param1=\"_show_time\""
echo "-- 🖥️ Показать систему | shell=\"$SCRIPT_PATH\" param1=\"_show_system\""
echo "-- 🔄 Показать процессы | shell=\"$SCRIPT_PATH\" param1=\"_show_processes\""
echo "-- 💾 Показать диск | shell=\"$SCRIPT_PATH\" param1=\"_show_disk"\
echo "-- 🌐 Показать сеть | shell=\"$SCRIPT_PATH\" param1=\"_show_network\""
echo "-- 🔋 Показать батарею | shell=\"$SCRIPT_PATH\" param1=\"_show_battery\""

echo "---"

echo "⚡ Быстрые действия"
echo "-- 📂 Открыть Терминал | shell=open -a 'Terminal' ."
echo "-- ⚙️ Открыть Настройки | shell=open 'x-apple.systempreferences:'"
echo "-- 📊 Монитор активности | shell=open -a 'Activity Monitor'"
echo "-- 🏠 Домашняя папка | shell=open param1=\"$HOME\""
echo "-- 📥 Загрузки | shell=open param1=\"$HOME/Downloads\""

echo "---"

echo "🔔 Тест уведомлений"
echo "-- 🔔 Простое уведомление | shell=osascript -e 'display notification \"Тест выполнен\" with title \"CronBarX\"'"
echo "-- 👋 Приветствие | shell=osascript -e 'display notification \"Привет, $(whoami)!\" with title \"Добро пожаловать\"'"

echo "---"

echo "🧹 Системные утилиты"
echo "-- 📝 Редактор plist | shell=open -a 'Property List Editor'"
echo "-- 🔍 Просмотр логов | shell=open -a 'Console'"
echo "-- 🎨 Цветовой профиль | shell=open -a 'ColorSync Utility'"

echo "---"

echo "🔄 Обновить | refresh=true"

# Обработка команд
case "${1:-}" in
    "_show_time")
        show_time
        ;;
    "_show_system")
        show_system
        ;;
    "_show_processes")
        show_processes
        ;;
    "_show_disk")
        show_disk
        ;;
    "_show_network")
        show_network
        ;;
    "_show_battery")
        show_battery
        ;;
esac
