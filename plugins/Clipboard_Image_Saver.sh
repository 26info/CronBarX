#!/bin/bash
# Simple Clipboard Image Saver - CronBarX

SAVE_DIR="$HOME/Desktop/Clipboard_Images"
mkdir -p "$SAVE_DIR"

# Функция для поиска pngpaste
find_pngpaste() {
    local paths=(
        "/usr/local/bin/pngpaste"
        "/opt/homebrew/bin/pngpaste"
        "/opt/local/bin/pngpaste"
    )
    
    for path in "${paths[@]}"; do
        if [ -x "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    # Пробуем which как запасной вариант
    local which_path=$(which pngpaste 2>/dev/null)
    if [ -n "$which_path" ] && [ -x "$which_path" ]; then
        echo "$which_path"
        return 0
    fi
    
    return 1
}

PNGPASTE=$(find_pngpaste)

main() {
    echo "📸 Буфер"
    echo "---"
    
    if [ -z "$PNGPASTE" ]; then
        echo "❌ pngpaste не установлен"
        echo "---"
        echo "📦 Установить pngpaste | shell=\"$0\" _install"
        echo "---"
        echo "🔄 Обновить | refresh=true"
        return
    fi
    
    # Проверяем есть ли изображение в буфере
    local temp_file=$(mktemp).png
    if "$PNGPASTE" "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        echo "🖼️ В буфере изображение"
        echo "---"
        echo "💾 Сохранить PNG | shell=\"$0\" _save"
        echo "👀 Предпросмотр | shell=\"$0\" _preview"
        rm -f "$temp_file"
    else
        echo "📭 В буфере нет изображения"
        echo "---"
        echo "💡 Скопируйте изображение (⌘+C)"
        rm -f "$temp_file"
    fi
    
    echo "---"
    echo "📁 Открыть папку | shell=\"$0\" _open_folder"
}

save_image() {
    local filename="image_$(date +%Y%m%d_%H%M%S).png"
    local full_path="$SAVE_DIR/$filename"
    
    if "$PNGPASTE" "$full_path" 2>/dev/null && [ -s "$full_path" ]; then
        local file_size=$(du -h "$full_path" | cut -f1)
        osascript -e "display notification \"✅ Сохранено: $filename ($file_size)\" with title \"Clipboard Saver\""
    else
        osascript -e 'display notification "❌ Не удалось сохранить" with title "Clipboard Saver"'
    fi
}

preview_image() {
    local temp_file=$(mktemp).png
    
    if "$PNGPASTE" "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        open -a "Preview" "$temp_file"
        (sleep 3; rm -f "$temp_file") &
    else
        osascript -e 'display notification "❌ Не удалось открыть" with title "Clipboard Saver"'
        rm -f "$temp_file"
    fi
}

install_pngpaste() {
    osascript -e 'tell application "Terminal" to do script "brew install pngpaste && echo \\\"✅ pngpaste установлен!\\\""'
}

open_folder() {
    open "$SAVE_DIR"
}

case "$1" in
    "_save") save_image ;;
    "_preview") preview_image ;;
    "_install") install_pngpaste ;;
    "_open_folder") open_folder ;;
    *) main ;;
esac