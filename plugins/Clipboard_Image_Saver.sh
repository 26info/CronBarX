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
        echo "📦 Установить pngpaste | shell=\"$0\" param1=\"_install\""
        echo "---"
        echo "🔄 Обновить | refresh=true"
        return
    fi
    
    # Проверяем есть ли изображение в буфере
    local temp_file=$(mktemp).png
    if "$PNGPASTE" "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        local file_size=$(wc -c < "$temp_file" 2>/dev/null)
        local size_kb=$((file_size / 1024))
        
        echo "🖼️ В буфере изображение"
        echo "📏 Размер: ${size_kb} KB"
        echo "---"
        echo "💾 Сохранить PNG | shell=\"$0\" param1=\"_save\" refresh=true"
        echo "👀 Предпросмотр | shell=\"$0\" param1=\"_preview\""
        rm -f "$temp_file"
    else
        echo "📭 В буфере нет изображения"
        echo "---"
        echo "💡 Скопируйте изображение (⌘+C)"
        rm -f "$temp_file"
    fi
    
    echo "---"
    echo "📁 Открыть папку | shell=\"$0\" param1=\"_open_folder\""
    echo "🔄 Обновить | refresh=true"
}

save_image() {
    local filename="image_$(date +%Y%m%d_%H%M%S).png"
    local full_path="$SAVE_DIR/$filename"
    
    if "$PNGPASTE" "$full_path" 2>/dev/null && [ -s "$full_path" ]; then
        local file_size=$(wc -c < "$full_path" 2>/dev/null)
        local size_kb=$((file_size / 1024))
        osascript -e "display notification \"✅ Сохранено: $filename (${size_kb} KB)\" with title \"Clipboard Saver\""
        echo "✅ Изображение сохранено: $filename (${size_kb} KB)"
    else
        osascript -e 'display notification "❌ Не удалось сохранить" with title "Clipboard Saver"'
        echo "❌ Не удалось сохранить изображение"
    fi
}

preview_image() {
    local temp_file=$(mktemp).png
    
    if "$PNGPASTE" "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        open -a "Preview" "$temp_file"
        (sleep 3; rm -f "$temp_file") &
        echo "👀 Открыто в Preview"
    else
        osascript -e 'display notification "❌ Не удалось открыть" with title "Clipboard Saver"'
        rm -f "$temp_file"
        echo "❌ Не удалось открыть изображение"
    fi
}

install_pngpaste() {
    if command -v brew &> /dev/null; then
        osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "brew install pngpaste && echo \"✅ pngpaste установлен!\""'
        echo "📦 Запущена установка pngpaste через Homebrew"
    else
        osascript -e 'display dialog "❌ Homebrew не установлен\n\nУстановите Homebrew с сайта:\nhttps://brew.sh" buttons {"OK"} default button "OK" with icon stop'
        echo "❌ Homebrew не установлен"
    fi
}

open_folder() {
    open "$SAVE_DIR"
    echo "📁 Открыта папка: $SAVE_DIR"
}

# Обработка параметров
case "${1}" in
    "_save") save_image ;;
    "_preview") preview_image ;;
    "_install") install_pngpaste ;;
    "_open_folder") open_folder ;;
    *) main ;;
esac
