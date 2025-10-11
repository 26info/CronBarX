#!/bin/bash
# Image Buffer Manager - CronBarX

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
    
    local which_path=$(which pngpaste 2>/dev/null)
    if [ -n "$which_path" ] && [ -x "$which_path" ]; then
        echo "$which_path"
        return 0
    fi
    
    return 1
}

PNGPASTE=$(find_pngpaste)

# Сохраняем буфер во временный файл
save_to_tmp() {
    local tmp_file=$(mktemp).png
    
    if [ -z "$PNGPASTE" ]; then
        return 1
    fi
    
    # Сохраняем в временный файл
    if "$PNGPASTE" "$tmp_file" 2>/dev/null; then
        # Проверяем что файл создан и не пустой
        if [ -f "$tmp_file" ] && [ -s "$tmp_file" ]; then
            local file_size=$(wc -c < "$tmp_file" 2>/dev/null)
            if [ "$file_size" -gt 100 ]; then
                echo "$tmp_file:$file_size"
                return 0
            fi
        fi
    fi
    
    rm -f "$tmp_file" 2>/dev/null
    return 1
}

# Основная функция
main() {
    echo "📸"
    echo "---"
    
    if [ -z "$PNGPASTE" ]; then
        echo "❌ pngpaste не установлен"
        echo "---"
        echo "📦 Установить pngpaste | shell=\"$0\" _install"
        return
    fi
    
    # Сохраняем буфер во временный файл
    local buffer_info=$(save_to_tmp)
    
    if [ -n "$buffer_info" ]; then
        local tmp_file="${buffer_info%:*}"
        local file_size="${buffer_info#*:}"
        local size_kb=$((file_size / 1024))
        
        echo "✅ В буфере изображение"
        echo "📏 Размер: ${size_kb} KB"
        
        # Сохраняем путь к временному файлу для использования в командах
        echo "$tmp_file" > "/tmp/current_clipboard_image.txt"
        
    else
        echo "📭 В буфере нет изображения"
        echo "💡 Скопируйте изображение (⌘+C)"
    fi
    
    echo "---"
    
    if [ -n "$buffer_info" ]; then
        echo "💾 Сохранить изображение | shell=\"$0\" _save"
        echo "👀 Предпросмотр | shell=\"$0\" _preview"
    fi
    
    echo "📁 Открыть папку | shell=\"$0\" _open_folder"
}

# Сохранить изображение
_save() {
    local tmp_file
    if [ -f "/tmp/current_clipboard_image.txt" ]; then
        tmp_file=$(cat "/tmp/current_clipboard_image.txt")
    fi
    
    if [ -z "$tmp_file" ] || [ ! -f "$tmp_file" ]; then
        osascript -e 'display dialog "❌ Нет изображения в буфере" buttons {"OK"} with icon stop'
        return
    fi
    
    local filename="img_$(date +%Y%m%d_%H%M%S).png"
    local full_path="$SAVE_DIR/$filename"
    
    # Копируем из временного файла в папку
    if cp "$tmp_file" "$full_path" 2>/dev/null && [ -f "$full_path" ]; then
        local file_size=$(wc -c < "$full_path" 2>/dev/null)
        local file_size_kb=$((file_size / 1024))
        
        # Очищаем временный файл
        rm -f "$tmp_file" "/tmp/current_clipboard_image.txt" 2>/dev/null
        
        osascript -e "display notification \"📸 $filename (${file_size_kb} KB)\" with title \"Image Saved\""
    else
        osascript -e 'display notification "❌ Ошибка сохранения" with title "Error"'
    fi
}

# Предпросмотр
_preview() {
    local tmp_file
    if [ -f "/tmp/current_clipboard_image.txt" ]; then
        tmp_file=$(cat "/tmp/current_clipboard_image.txt")
    fi
    
    if [ -z "$tmp_file" ] || [ ! -f "$tmp_file" ]; then
        osascript -e 'display dialog "❌ Нет изображения в буфере" buttons {"OK"} with icon stop'
        return
    fi
    
    open -a "Preview" "$tmp_file"
    # Удаляем временный файл через несколько секунд
    (sleep 5; rm -f "$tmp_file" "/tmp/current_clipboard_image.txt" 2>/dev/null) &
}

install_pngpaste() {
    osascript -e 'tell application "Terminal" to do script "brew install pngpaste"'
}

open_folder() {
    open "$SAVE_DIR"
}

case "$1" in
    "_save") _save ;;
    "_preview") _preview ;;
    "_install") install_pngpaste ;;
    "_open_folder") open_folder ;;
    *) main ;;
esac