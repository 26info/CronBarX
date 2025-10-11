#!/bin/bash

# =============================================================================
# Downloads Cleaner for CronBarX / Очиститель загрузок для CronBarX
# =============================================================================
# 
# ENGLISH:
# Automatically removes files and folders older than 24 hours from Downloads.
# Works with all file types and directories in Downloads folder.
# 
# РУССКИЙ:
# Автоматически удаляет файлы и папки старше 24 часов из папки Загрузки.
# Работает со всеми типами файлов и директориями в папке Загрузки.
#
# FEATURES / ОСОБЕННОСТИ:
# - 🕐 Age-based cleaning (24+ hours) / Очистка по возрасту (24+ часов)
# - 📁 Works with files AND folders / Работает с файлами И папками
# - 📊 Smart monitoring with size calculation / Умный мониторинг с расчетом размера
# - 👀 Visual dialog preview / Визуальный предпросмотр в диалоге
# - 🔔 System notifications / Системные уведомления
# - 🛡️ Safe operation with confirmation / Безопасная работа с подтверждением
#
# USAGE / ИСПОЛЬЗОВАНИЕ:
# Add to CronBarX and click menu items / Добавить в CronBarX и использовать через меню
# =============================================================================

DOWNLOADS_PATH="$HOME/Downloads"

# Функция поиска и подсчета старых элементов
# Function to find and count old items
find_old_items() {
    local count=0
    local total_size=0
    local current_time=$(date +%s)
    local one_day_ago=$((current_time - 86400)) # 24 часа в секундах / 24 hours in seconds
    
    # Ищем все файлы и папки старше 24 часов
    # Find all files and folders older than 24 hours
    while IFS= read -r item; do
        if [[ -e "$item" ]]; then
            local item_time=$(stat -f %m "$item" 2>/dev/null || stat -c %Y "$item" 2>/dev/null)
            if [[ -n "$item_time" && "$item_time" -lt "$one_day_ago" ]]; then
                ((count++))
                if [[ -f "$item" ]]; then
                    local size=$(stat -f %z "$item" 2>/dev/null || stat -c %s "$item" 2>/dev/null)
                    total_size=$((total_size + size))
                elif [[ -d "$item" ]]; then
                    local size=$(du -sk "$item" 2>/dev/null | cut -f1)
                    total_size=$((total_size + size * 1024))
                fi
            fi
        fi
    done < <(find "$DOWNLOADS_PATH" -maxdepth 1 -mindepth 1 -not -name ".DS_Store" -not -name ".localized" 2>/dev/null)
    
    echo "$count:$total_size"
}

# Функция удаления старых элементов
# Function to delete old items
delete_old_items() {
    local deleted_count=0
    local freed_space=0
    local current_time=$(date +%s)
    local one_day_ago=$((current_time - 86400))
    
    while IFS= read -r item; do
        if [[ -e "$item" ]]; then
            local item_time=$(stat -f %m "$item" 2>/dev/null || stat -c %Y "$item" 2>/dev/null)
            if [[ -n "$item_time" && "$item_time" -lt "$one_day_ago" ]]; then
                local item_name=$(basename "$item")
                local item_size=0
                
                if [[ -f "$item" ]]; then
                    item_size=$(stat -f %z "$item" 2>/dev/null || stat -c %s "$item" 2>/dev/null)
                    echo "🗑️ Удаляем файл: $item_name"
                    rm "$item"
                elif [[ -d "$item" ]]; then
                    item_size=$(du -sk "$item" 2>/dev/null | cut -f1)
                    item_size=$((item_size * 1024))
                    echo "🗑️ Удаляем папку: $item_name"
                    rm -rf "$item"
                fi
                
                ((deleted_count++))
                freed_space=$((freed_space + item_size))
            fi
        fi
    done < <(find "$DOWNLOADS_PATH" -maxdepth 1 -mindepth 1 -not -name ".DS_Store" -not -name ".localized" 2>/dev/null)
    
    echo "$deleted_count:$freed_space"
}

# Функция для форматирования размера
# Function to format file size
format_size() {
    local bytes=$1
    if [[ $bytes -ge 1073741824 ]]; then
        echo "$((bytes / 1073741824)) GB"
    elif [[ $bytes -ge 1048576 ]]; then
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
    local item_list=""
    local total_count=0
    local total_size=0
    
    # Собираем список элементов
    # Collect items list
    while IFS= read -r item; do
        if [[ -e "$item" ]]; then
            local item_time=$(stat -f %m "$item" 2>/dev/null || stat -c %Y "$item" 2>/dev/null)
            if [[ -n "$item_time" && "$item_time" -lt "$one_day_ago" ]]; then
                local item_name=$(basename "$item")
                local item_age=$(( (current_time - item_time) / 3600 ))
                local item_size=0
                local item_type=""
                
                if [[ -f "$item" ]]; then
                    item_type="📄"
                    item_size=$(stat -f %z "$item" 2>/dev/null || stat -c %s "$item" 2>/dev/null)
                elif [[ -d "$item" ]]; then
                    item_type="📁"
                    item_size=$(du -sk "$item" 2>/dev/null | cut -f1)
                    item_size=$((item_size * 1024))
                fi
                
                local size_kb=$((item_size / 1024))
                item_list="${item_list}${item_type} ${item_name}\n   📏 ${size_kb} KB • 🕐 ${item_age} часов\n"
                ((total_count++))
                total_size=$((total_size + item_size))
            fi
        fi
    done < <(find "$DOWNLOADS_PATH" -maxdepth 1 -mindepth 1 -not -name ".DS_Store" -not -name ".localized" 2>/dev/null | sort -r)
    
    if [[ $total_count -eq 0 ]]; then
        osascript -e 'display dialog "✅ Старых элементов не найдено\n\nФайлы и папки старше 24 часов отсутствуют в Загрузках." buttons {"OK"} default button "OK" with icon note'
    else
        local message="📋 Найдено старых элементов: ${total_count}\n💾 Общий размер: $(format_size $total_size)\n\n${item_list}\n\nЭти файлы и папки будут удалены при очистке."
        
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
    local items_info=$(find_old_items)
    local old_count=$(echo "$items_info" | cut -d: -f1)
    local old_size=$(echo "$items_info" | cut -d: -f2)
    
    echo "📁"
    echo "---"
    
    if [ "$old_count" -eq 0 ]; then
        echo "✅ Старых элементов не найдено"
        echo "📅 Удаляются файлы и папки старше 24 часов"
        echo "📍 Папка: Загрузки"
    else
        echo "📦 Найдено старых элементов: $old_count"
        echo "💾 Можно освободить: $(format_size $old_size)"
        echo "⏰ Возраст: более 24 часов"
        echo "📍 Папка: Загрузки"
    fi
    
    echo "---"
    
    if [ "$old_count" -gt 0 ]; then
        echo "🚀 Очистить старые элементы | shell=\"$0\" param1=\"_clean\" refresh=true"
        echo "👀 Показать список | shell=\"$0\" _list_dialog"
    fi
    
    echo "📂 Открыть папку Загрузки | shell=open \"$DOWNLOADS_PATH\""
    echo "🔍 Обновить | refresh=true"
}

# Очистить старые элементы
# Clean old items
_clean() {
    local delete_info=$(delete_old_items)
    local deleted_count=$(echo "$delete_info" | cut -d: -f1)
    local freed_space=$(echo "$delete_info" | cut -d: -f2)
    
    if [ "$deleted_count" -gt 0 ]; then
        # Показываем уведомление
        # Show notification
        osascript -e "display notification \"Удалено $deleted_count старых элементов\" with title \"Downloads Cleaner\" subtitle=\"Освобождено: $(format_size $freed_space)\""
        
        # Обновляем интерфейс
        # Update interface
        echo "✅ Удалено: $deleted_count элементов"
        echo "💾 Освобождено: $(format_size $freed_space)"
        echo "---"
        echo "🗑️  Старые файлы и папки очищены"
        echo "🔍 Обновить | refresh=true"
    else
        echo "ℹ️  Старых элементов не найдено"
        echo "---"
        echo "🔍 Обновить | refresh=true"
    fi
}

# Обработка параметров
# Parameter handling
case "${1}" in
    "_clean") _clean ;;
    "_list_dialog") show_list_dialog ;;
    *) main ;;
esac