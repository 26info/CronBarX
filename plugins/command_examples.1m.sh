#!/bin/bash
# Умные команды - CronBarX

# Функция для показа диалога
show_dialog() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button 1"
}

# Функция для показа уведомления
show_notification() {
    osascript -e "display notification \"$1\" with title \"$2\""
}

# Функции для команд
show_time() {
    show_notification "$(date)" "Текущее время"
}

show_system() {
    show_dialog "Системная информация:\n\nПользователь: $(whoami)\nХост: $(hostname)\nmacOS: $(sw_vers -productVersion)\nПроцессор: $(sysctl -n machdep.cpu.brand_string)"
}

show_processes() {
    show_dialog "Топ процессов:\n\n$(ps aux | head -6)"
}

show_disk() {
    show_dialog "Дисковое пространство:\n\n$(df -h / | head -2)"
}

show_network() {
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "Недоступно")
    show_dialog "Сетевая информация:\n\nЛокальный IP: $local_ip\nВнешний IP: $(curl -s http://ifconfig.me)"
}

show_battery() {
    battery_info=$(pmset -g batt | grep -E "([0-9]+%)|(AC|Battery)")
    show_notification "$battery_info" "Батарея"
}

# Основное меню
echo "🛠️ Умные команды"
echo "---"

echo "💻 Системная информация"
echo "-- 🕐 Показать время | shell=/bin/bash -c \"'$0' _show_time\""
echo "-- 🖥️ Показать систему | shell=/bin/bash -c \"'$0' _show_system\""
echo "-- 🔄 Показать процессы | shell=/bin/bash -c \"'$0' _show_processes\""
echo "-- 💾 Показать диск | shell=/bin/bash -c \"'$0' _show_disk\""
echo "-- 🌐 Показать сеть | shell=/bin/bash -c \"'$0' _show_network\""
echo "-- 🔋 Показать батарею | shell=/bin/bash -c \"'$0' _show_battery\""

echo "---"

echo "⚡ Быстрые действия"
echo "-- 📂 Открыть Терминал | shell=open -a Terminal"
echo "-- ⚙️ Открыть Настройки | shell=open x-apple.systempreferences:"
echo "-- 📊 Монитор активности | shell=open -a 'Activity Monitor'"
echo "-- 🏠 Домашняя папка | shell=open ~/"
echo "-- 📥 Загрузки | shell=open ~/Downloads"

echo "---"

echo "🔔 Тест уведомлений"
echo "-- 🔔 Простое уведомление | shell=osascript -e 'display notification \"Тест выполнен\" with title \"CronBarX\"'"
echo "-- 👋 Приветствие | shell=osascript -e 'display notification \"Привет, $(whoami)!\" with title \"Добро пожаловать\"'"

echo "---"
echo "🔄 Обновить | refresh=true"

# Обработка команд (с префиксом _ чтобы избежать конфликтов)
case "$1" in
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