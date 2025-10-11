#!/bin/bash
# Clipboard Monitor - CronBarX

# Надежная функция для отображения буфера обмена
show_clipboard_safe() {
    # Создаем временный файл для содержимого буфера
    local temp_file=$(mktemp)
    pbpaste > "$temp_file" 2>/dev/null
    
    # Проверяем, есть ли содержимое
    if [ ! -s "$temp_file" ]; then
        osascript -e 'display dialog "Буфер обмена пуст" buttons {"OK"} with icon note'
        rm -f "$temp_file"
        return 1
    fi
    
    # Получаем информацию о размере
    local file_size=$(wc -c < "$temp_file")
    local line_count=$(wc -l < "$temp_file")
    
    # Если файл слишком большой, предлагаем открыть в редакторе
    if [ "$file_size" -gt 2000 ]; then
        osascript << 'EOF'
        display dialog "Содержимое буфера слишком длинное для отображения в диалоге (" & (count of contents) & " символов). Открыть в текстовом редакторе?" ¬
        buttons {"Открыть", "Показать часть", "Отмена"} ¬
        default button "Открыть" ¬
        with icon note
EOF
        local choice=$?
        
        if [ $choice -eq 0 ]; then
            # Открыть в редакторе
            open -a "TextEdit" "$temp_file"
            # Не удаляем файл сразу, чтобы пользователь мог с ним работать
            echo "📝 Файл сохранен: $temp_file"
        elif [ $choice -eq 1 ]; then
            # Показать первую часть
            local first_part=$(head -c 500 "$temp_file")
            local clean_part=$(echo "$first_part" | tr -d '\000-\011\013-\037' | sed 's/"/'\''/g')
            osascript -e "display dialog \"Буфер обмена (первые 500 символов):\n\n$clean_part\n\n... всего $file_size символов, $line_count строк\" buttons {\"OK\", \"Открыть полностью\"} with icon note"
            if [ $? -eq 1 ]; then
                open -a "TextEdit" "$temp_file"
            else
                rm -f "$temp_file"
            fi
        else
            rm -f "$temp_file"
        fi
    else
        # Для короткого текста показываем полностью
        local content=$(cat "$temp_file")
        # Очищаем текст от проблемных символов
        local clean_content=$(echo "$content" | tr -d '\000-\011\013-\037' | sed 's/"/'\''/g')
        
        osascript -e "display dialog \"Буфер обмена ($file_size символов, $line_count строк):\n\n$clean_content\" buttons {\"OK\", \"Открыть в редакторе\"} with icon note"
        
        if [ $? -eq 1 ]; then
            open -a "TextEdit" "$temp_file"
        else
            rm -f "$temp_file"
        fi
    fi
}

# Альтернативная простая функция для короткого текста
show_clipboard_simple() {
    local clipboard_text=$(pbpaste 2>/dev/null | head -c 1000)
    
    if [ -z "$clipboard_text" ]; then
        osascript -e 'display dialog "Буфер обмена пуст" buttons {"OK"} with icon note'
        return 1
    fi
    
    # Базовая очистка текста
    clipboard_text=$(echo "$clipboard_text" | tr -d '\000-\011\013-\037' | sed 's/"/'\''/g')
    
    local text_length=${#clipboard_text}
    
    if [ "$text_length" -le 500 ]; then
        osascript -e "display dialog \"Буфер обмена ($text_length символов):\n\n$clipboard_text\" buttons {\"OK\"} with icon note giving up after 30"
    else
        # Для длинного текста показываем первую часть
        local first_part="${clipboard_text:0:500}"
        osascript -e "display dialog \"Буфер обмена (первые 500 из $text_length символов):\n\n$first_part\n\n... (текст обрезан)\" buttons {\"OK\"} with icon note giving up after 30"
    fi
}

# Основной код
main() {
    local clipboard_content=$(pbpaste 2>/dev/null | head -c 50)
    local clipboard_length=$(pbpaste 2>/dev/null | wc -c 2>/dev/null || echo 0)

    echo "📋 Буфер"
    echo "---"

    if [ "$clipboard_length" -gt 1 ]; then
        # Показываем тип содержимого
        local content_type="текст"
        if pbpaste | file - | grep -q "rich text"; then
            content_type="форматированный текст"
        elif pbpaste | file - | grep -q "image"; then
            content_type="изображение"
        fi
        
        echo "📝 Содержимое: ${clipboard_content}..."
        echo "📏 Длина: $clipboard_length символов"
        echo "📊 Тип: $content_type"
        echo "---"
        echo "👀 Показать (простой способ) | shell=\"$0\" _show_simple"
        echo "📋 Показать (надежный способ) | shell=\"$0\" _show_safe"
        echo "🧹 Очистить буфер | shell=\"$0\" _clear_clipboard"
        echo "📎 Экспорт в файл | shell=\"$0\" _export_clipboard"
    else
        echo "📭 Буфер пуст"
    fi

    echo "---"
    echo "🔄 Обновить | refresh=true"
}

# Обработка команд
case "$1" in
    "_clear_clipboard")
        pbcopy < /dev/null
        echo "🧹 Буфер очищен"
        ;;
    "_show_simple")
        show_clipboard_simple
        ;;
    "_show_safe")
        show_clipboard_safe
        ;;
    "_export_clipboard")
        clipboard_text=$(pbpaste 2>/dev/null)
        if [ -n "$clipboard_text" ]; then
            clipboard_export="$HOME/Desktop/clipboard_export_$(date +%Y%m%d_%H%M%S).txt"
            echo "$clipboard_text" > "$clipboard_export"
            osascript -e "display dialog \"Буфер экспортирован в файл:\n\n$clipboard_export\" buttons {\"OK\", \"Открыть\"} with icon note"
            if [ $? -eq 1 ]; then
                open "$clipboard_export"
            fi
        else
            osascript -e 'display dialog "Буфер пуст" buttons {"OK"} with icon note'
        fi
        ;;
    *)
        main
        ;;
esac