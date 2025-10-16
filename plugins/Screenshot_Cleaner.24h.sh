#!/bin/bash

# =============================================================================
# Screenshot Cleaner for CronBarX / Очиститель скриншотов для CronBarX
# =============================================================================
#
# ENGLISH:
# Automatically removes screenshot files older than 24 hours from desktop.
# Targets files with naming pattern: "Снимок экрана YYYY-MM-DD at HH.MM.SS"
#
# РУССКИЙ:
# Автоматически удаляет файлы скриншотов старше 24 часов с рабочего стола.
# Работает с файлами по шаблону: "Снимок экрана ГГГГ-ММ-ДД в ЧЧ.ММ.СС"
#
# FEATURES / ОСОБЕННОСТИ:
# - 🕐 Age-based cleaning (24+ hours) / Очистка по возрасту (24+ часов)
# - 🎯 Precise pattern matching / Точное совпадение по шаблону имен
# - 📊 Smart monitoring with size calculation / Умный мониторинг с расчетом размера
# - 👀 Visual dialog preview / Визуальный предпросмотр в диалоге
# - 🔔 System notifications / Системные уведомления
# - 🛡️ Safe operation with confirmation / Безопасная работа с подтверждением
#
# USAGE / ИСПОЛЬЗОВАНИЕ:
# Add to CronBarX and click menu items / Добавить в CronBarX и использовать через меню
# =============================================================================

DESKTOP_PATH="$HOME/Desktop"

# Функция поиска и подсчета скриншотов
# Function to find and count screenshots
find_screenshots() {
    local count=0
    local total_size=0
    local current_time=$(date +%s)
    local one_day_ago=$((current_time - 86400)) # 24 часа в секундах / 24 hours in seconds
    
    # Точный паттерн для скриншотов macOS на русском
    # Exact pattern for Russian macOS screenshots
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            if [[ -n "$file_time" && "$file_time" -lt "$one_day_ago" ]]; then
                ((count++))
                local size=$(stat -f %z "$file" 2>/dev/null || stat -c %s "$file" 2>/dev/null)
                total_size=$((total_size + size))
            fi
        fi
    done < <(find "$DESKTOP_PATH" -maxdepth 1 -name "Снимок экрана *" -type f 2>/dev/null)
    
    echo "$count:$total_size"
}

# Функция удаления старых скриншотов
# Function to delete old screenshots
delete_old_screenshots() {
    local deleted_count=0
    local freed_space=0
    local current_time=$(date +%s)
    local one_day_ago=$((current_time - 86400))
    
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            if [[ -n "$file_time" && "$file_time" -lt "$one_day_ago" ]]; then
                local size=$(stat -f %z "$file" 2>/dev/null || stat -c %s "$file" 2>/dev/null)
                local filename=$(basename "$file")
                
                echo "🗑️ Удаляем: $filename"
                rm "$file"
                
                ((deleted_count++))
                freed_space=$((freed_space + size))
            fi
        fi
    done < <(find "$DESKTOP_PATH" -maxdepth 1 -name "Снимок экрана *" -type f 2>/dev/null)
    
    echo "$deleted_count:$freed_space"
}

# Функция для форматирования размера
# Function to format file size
format_size() {
    local bytes=$1
    if [[ $bytes -ge 1048576 ]]; then
        echo "$((bytes / 1048576)) MB"
    elif [[ $bytes -ge 1024 ]]; then
        echo "$((bytes / 1024)) KB"
    else
        echo "${bytes} B"
    fi
}

# Функция для показа диалога со списком
# Function to show list dialog
show_list_dialog() {
    local current_time=$(date +%s)
    local one_day_ago=$((current_time - 86400))
    local file_list=""
    local total_count=0
    local total_size=0
    
    # Собираем список файлов
    # Collect file list
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            if [[ -n "$file_time" && "$file_time" -lt "$one_day_ago" ]]; then
                local filename=$(basename "$file")
                local size=$(stat -f %z "$file" 2>/dev/null || stat -c %s "$file" 2>/dev/null)
                local age=$(( (current_time - file_time) / 3600 ))
                local size_kb=$((size / 1024))
                
                file_list="${file_list}• ${filename}\n   📏 ${size_kb} KB • 🕐 ${age} часов\n"
                ((total_count++))
                total_size=$((total_size + size))
            fi
        fi
    done < <(find "$DESKTOP_PATH" -maxdepth 1 -name "Снимок экрана *" -type f 2>/dev/null | sort -r)
    
    if [[ $total_count -eq 0 ]]; then
        osascript -e 'display dialog "✅ Старых скриншотов не найдено\n\nФайлы старше 24 часов отсутствуют на рабочем столе." buttons {"OK"} default button "OK" with icon note'
    else
        local message="📋 Найдено старых скриншотов: ${total_count}\n💾 Общий размер: $(format_size $total_size)\n\n${file_list}\n\nЭти файлы будут удалены при очистке."
        
        # Показываем диалог с кнопкой очистки
        # Show dialog with cleanup button
        local result=$(osascript -e "button returned of (display dialog \"$message\" buttons {\"Отмена\", \"Очистить всё\"} default button \"Отмена\" with icon caution)")
        
        if [[ "$result" == "Очистить всё" ]]; then
            # Запускаем очистку
            # Start cleanup
            "$0" _clean
        fi
    fi
}

# Основное меню CronBarX
# Main CronBarX menu
main() {
    local screenshot_info=$(find_screenshots)
    local old_count=$(echo "$screenshot_info" | cut -d: -f1)
    local old_size=$(echo "$screenshot_info" | cut -d: -f2)
    
    echo "🗑️"
    echo "---"
    
    if [ "$old_count" -eq 0 ]; then
        echo "✅ Старых скриншотов не найдено"
        echo "📅 Удаляются файлы старше 24 часов"
    else
        echo "📸 Найдено старых скриншотов: $old_count"
        echo "💾 Можно освободить: $(format_size $old_size)"
        echo "⏰ Возраст: более 24 часов"
    fi
    
    echo "---"
    
    if [ "$old_count" -gt 0 ]; then
        echo "🚀 Очистить старые скриншоты | shell=\"$0\" param1=\"_clean\" refresh=true"
        echo "👀 Показать список | shell=\"$0\" param1=\"_list_dialog\""
    fi
    
    echo "📁 Открыть рабочий стол | shell=open param1=\"$DESKTOP_PATH\""
    echo "🔄 Обновить | refresh=true"
}

# Очистить старые скриншоты
# Clean old screenshots
_clean() {
    local delete_info=$(delete_old_screenshots)
    local deleted_count=$(echo "$delete_info" | cut -d: -f1)
    local freed_space=$(echo "$delete_info" | cut -d: -f2)
    
    if [ "$deleted_count" -gt 0 ]; then
        # Показываем уведомление
        # Show notification
        osascript -e "display notification \"Удалено $deleted_count старых скриншотов\" with title \"CronBarX Cleaner\" subtitle=\"Освобождено: $(format_size $freed_space)\""
        
        # Обновляем интерфейс
        # Update interface
        echo "✅ Удалено: $deleted_count скриншотов"
        echo "💾 Освобождено: $(format_size $freed_space)"
        echo "---"
        echo "🗑️  Старые файлы очищены"
    else
        echo "ℹ️  Старых скриншотов не найдено"
        echo "---"
    fi
}

# Обработка параметров
# Parameter handling
case "${1}" in
    "_clean") _clean ;;
    "_list_dialog") show_list_dialog ;;
    *) main ;;
esac
