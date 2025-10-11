#!/bin/bash
# Memory Usage Monitor - CronBarX
# Показывает использование памяти в реальном времени

# Функция для получения информации о памяти
get_memory_info() {
    # Используем vm_stat для получения детальной информации
    local vm_stat_output=$(vm_stat)
    
    # Получаем общую память
    local total_memory=$(sysctl -n hw.memsize)
    total_memory=$((total_memory / 1024 / 1024)) # Конвертируем в MB
    
    # Парсим vm_stat output
    local pages_free=$(echo "$vm_stat_output" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local pages_active=$(echo "$vm_stat_output" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    local pages_inactive=$(echo "$vm_stat_output" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    local pages_wired=$(echo "$vm_stat_output" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    local pages_compressed=$(echo "$vm_stat_output" | grep "Pages occupied by compressor" | awk '{print $5}' | sed 's/\.//')
    
    # Размер страницы (обычно 4096 байт)
    local page_size=$(vm_stat | grep "page size" | awk '{print $8}')
    
    # Вычисляем использованную память
    local used_pages=$((pages_active + pages_wired + pages_compressed))
    local used_memory=$((used_pages * page_size / 1024 / 1024)) # MB
    
    # Вычисляем свободную память
    local free_memory=$((pages_free * page_size / 1024 / 1024)) # MB
    local inactive_memory=$((pages_inactive * page_size / 1024 / 1024)) # MB
    
    # Общая доступная память (использованная + свободная)
    local available_memory=$((used_memory + free_memory + inactive_memory))
    
    # Процент использования
    local usage_percent=$((used_memory * 100 / total_memory))
    
    echo "$used_memory:$free_memory:$total_memory:$usage_percent:$inactive_memory"
}

# Функция для получения информации о swap
get_swap_info() {
    local swap_used=$(sysctl -n vm.swapusage | awk '{print $4}' | sed 's/M//')
    local swap_total=$(sysctl -n vm.swapusage | awk '{print $7}' | sed 's/M//')
    local swap_percent=0
    
    if [ "$swap_total" -gt 0 ]; then
        swap_percent=$((swap_used * 100 / swap_total))
    fi
    
    echo "$swap_used:$swap_total:$swap_percent"
}

# Функция для получения топ процессов по памяти
get_top_memory_processes() {
    # Получаем топ-5 процессов по использованию памяти
    ps -eo pid,ppid,user,%mem,%cpu,rss,comm -c | head -6 | tail -5
}

# Функция для форматирования размера памяти
format_memory() {
    local size_mb="$1"
    if [ "$size_mb" -ge 1024 ]; then
        local size_gb=$(echo "scale=1; $size_mb / 1024" | bc)
        echo "${size_gb} GB"
    else
        echo "${size_mb} MB"
    fi
}

# Функция для создания графического индикатора
create_memory_bar() {
    local percent="$1"
    local width=10
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local bar="["
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    bar+="]"
    
    echo "$bar"
}

# Основная логика
main() {
    # Получаем информацию о памяти
    IFS=':' read -r used_memory free_memory total_memory usage_percent inactive_memory <<< "$(get_memory_info)"
    IFS=':' read -r swap_used swap_total swap_percent <<< "$(get_swap_info)"
    
    # Форматируем размеры
    used_formatted=$(format_memory "$used_memory")
    free_formatted=$(format_memory "$free_memory")
    total_formatted=$(format_memory "$total_memory")
    inactive_formatted=$(format_memory "$inactive_memory")
    swap_used_formatted=$(format_memory "$swap_used")
    swap_total_formatted=$(format_memory "$swap_total")
    
    # Создаем графический индикатор
    memory_bar=$(create_memory_bar "$usage_percent")
    swap_bar=$(create_memory_bar "$swap_percent")
    
    # Вывод в строку меню
    echo "🧠 ${usage_percent}%"
    echo "---"
    
    # Основная информация
    echo "💾 Использование памяти: ${usage_percent}%"
    echo "---"
    echo "📊 Оперативная память (RAM)"
    echo "• Использовано: ${used_formatted} / ${total_formatted}"
    echo "• Свободно: ${free_formatted}"
    echo "• Неактивно: ${inactive_formatted}"
    echo "• $memory_bar ${usage_percent}%"
    echo "---"
    
    # Swap информация
    echo "🔄 Файл подкачки (Swap)"
    echo "• Использовано: ${swap_used_formatted} / ${swap_total_formatted}"
    echo "• $swap_bar ${swap_percent}%"
    echo "---"
    
    # Топ процессов по памяти
    echo "🔥 Топ процессов по памяти:"
    get_top_memory_processes | while read line; do
        if [ -n "$line" ]; then
            echo "• $line" | awk '{printf "%-30s %4s%% %8s MB\n", $7, $4, $6/1024}'
        fi
    done
    
    echo "---"
    
    # Действия
    echo "📊 Действия:"
    echo "🔄 Обновить | refresh=true"
    echo "🔍 Монитор активности | shell=open -a \"Activity Monitor\""
    echo "🗑️ Очистить память (purge) | shell=\"$0\" _purge_memory"
}

# Обработка команд
case "$1" in
    "_purge_memory")
        osascript -e 'tell application "Terminal" to activate' -e 'delay 0.5'
        osascript -e 'tell application "Terminal" to do script "sudo purge"'
        ;;
    *)
        main
        ;;
esac