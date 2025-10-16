#!/bin/bash
# Quick Notes Manager - CronBarX

NOTES_FILE="$HOME/quick_notes.txt"
mkdir -p "$(dirname "$NOTES_FILE")"
touch "$NOTES_FILE"

# Функция для очистки текста от проблемных символов
clean_text() {
    local text="$1"
    # Заменяем двойные кавычки на одинарные
    text="${text//\"/\'}"
    # Удаляем экранированные символы
    text="${text//\\/}"
    # Удаляем другие проблемные символы
    text="${text//|/}"
    text="${text//$/}"
    text="${text//\`/}"
    text="${text//!/}"
    # Удаляем multiple spaces and trim
    echo "$text" | sed 's/  */ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

main() {
    echo "📝 Заметки"
    echo "---"
    
    # Статистика
    local note_count=$(wc -l < "$NOTES_FILE" 2>/dev/null || echo 0)
    local file_size=$(du -h "$NOTES_FILE" 2>/dev/null | cut -f1)
    
    echo "📊 Всего: $note_count заметок ($file_size)"
    echo "---"
    
    # Показываем все заметки сразу в главном меню (последние сверху)
    if [ "$note_count" -gt 0 ]; then
        echo "📖 Ваши заметки:"
        
        # Читаем файл и выводим заметки в обратном порядке (последние сверху)
        local lines=()
        while IFS= read -r line; do
            lines+=("$line")
        done < "$NOTES_FILE"
        
        # Выводим в обратном порядке
        for ((i=${#lines[@]}-1; i>=0; i--)); do
            local line="${lines[i]}"
            local note_id=$(echo "$line" | cut -d'|' -f1)
            local timestamp=$(echo "$line" | cut -d'|' -f2)
            local content=$(echo "$line" | cut -d'|' -f3-)
            local short_content=$(echo "$content" | cut -c1-50)
            
            # Форматируем вывод в одну строку
            echo "$short_content... | shell=\"$0\" param1=\"_view_note\" param2=\"$note_id\""
        done
        
        echo "---"
    else
        echo "📭 Нет заметок"
        echo "---"
    fi
    
    # Быстрое создание заметок
    echo "✏️ Быстрое создание:"
    echo "📝 Новая заметка | shell=\"$0\" param1=\"_new_note\" refresh=true"
    echo "💡 Идея | shell=\"$0\" param1=\"_template_note\" param2=\"💡 Идея\" refresh=true"
    echo "📅 Задача | shell=\"$0\" param1=\"_template_note\" param2=\"📅 Задача\" refresh=true"
    echo "🛒 Покупки | shell=\"$0\" param1=\"_template_note\" param2=\"🛒 Покупки\" refresh=true"
    
    echo "---"
    
    # Управление
    echo "🛠️ Управление:"
    if [ "$note_count" -gt 0 ]; then
        echo "🔍 Поиск | shell=\"$0\" param1=\"_search_notes\""
        echo "🗑️ Очистить все | shell=\"$0\" param1=\"_clear_notes\" refresh=true"
    fi
    echo "📁 Открыть файл | shell=\"$0\" param1=\"_open_file\""
    
    echo "---"
    echo "🔄 Обновить | refresh=true"
}

# Генератор ID для заметок
generate_id() {
    date +%s
}

# Новая заметка
new_note() {
    local result=$(osascript -e 'text returned of (display dialog "Введите текст заметки:" default answer "" buttons {"Отмена", "Сохранить"} default button "Сохранить")')
    
    if [ -n "$result" ]; then
        # Очищаем текст от проблемных символов
        local clean_result=$(clean_text "$result")
        
        local note_id=$(generate_id)
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "${note_id}|${timestamp}|${clean_result}" >> "$NOTES_FILE"
        osascript -e "display notification \"✅ Заметка сохранена\" with title \"Заметки\"" &>/dev/null
        echo "✅ Заметка сохранена"
    else
        echo "❌ Отменено"
    fi
}

# Заметка по шаблону
template_note() {
    local template="$1"
    local result=$(osascript -e "text returned of (display dialog \"${template}:\" default answer \"\" buttons {\"Отмена\", \"Сохранить\"} default button \"Сохранить\")")
    
    if [ -n "$result" ]; then
        # Очищаем текст от проблемных символов
        local clean_result=$(clean_text "$result")
        
        local note_id=$(generate_id)
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "${note_id}|${timestamp}|${template}: ${clean_result}" >> "$NOTES_FILE"
        osascript -e "display notification \"✅ ${template} сохранена\" with title \"Заметки\"" &>/dev/null
        echo "✅ ${template} сохранена"
    else
        echo "❌ Отменено"
    fi
}

# Просмотр конкретной заметки (ИСПРАВЛЕННАЯ ВЕРСИЯ)
view_note() {
    local note_id="$1"
    local note_line=$(grep "^${note_id}|" "$NOTES_FILE")
    
    if [ -z "$note_line" ]; then
        osascript -e 'display dialog "❌ Заметка не найдена" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
        echo "❌ Заметка не найдена"
        return
    fi
    
    local timestamp=$(echo "$note_line" | cut -d'|' -f2)
    local content=$(echo "$note_line" | cut -d'|' -f3-)
    
    # Очищаем текст перед показом
    local clean_content=$(clean_text "$content")
    
    # Используем простой диалог без сложного форматирования
    local action=$(osascript -e "button returned of (display dialog \"Заметка:\\nВремя: $timestamp\\n\\n$clean_content\" buttons {\"Назад\", \"Редактировать\", \"Удалить\"} default button \"Назад\")")
    
    case "$action" in
        "Редактировать")
            edit_note "$note_id" "$clean_content"
            ;;
        "Удалить")
            delete_note "$note_id"
            ;;
        *)
            echo "🔙 Назад"
            ;;
    esac
}

# Редактирование заметки
edit_note() {
    local note_id="$1"
    local old_content="$2"
    
    # Очищаем старый текст перед показом в диалоге редактирования
    local clean_old_content=$(clean_text "$old_content")
    
    local new_content=$(osascript -e "text returned of (display dialog \"Редактировать заметку:\" default answer \"$clean_old_content\" buttons {\"Отмена\", \"Сохранить\"} default button \"Сохранить\")")
    
    if [ -n "$new_content" ]; then
        # Очищаем новый текст перед сохранением
        local clean_content=$(clean_text "$new_content")
        
        # Создаем временный файл без этой заметки
        grep -v "^${note_id}|" "$NOTES_FILE" > "${NOTES_FILE}.tmp"
        
        # Добавляем обновленную заметку
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "${note_id}|${timestamp}|${clean_content}" >> "${NOTES_FILE}.tmp"
        
        # Заменяем оригинальный файл
        mv "${NOTES_FILE}.tmp" "$NOTES_FILE"
        
        osascript -e "display notification \"✅ Заметка обновлена\" with title \"Заметки\"" &>/dev/null
        echo "✅ Заметка обновлена"
    else
        echo "❌ Редактирование отменено"
    fi
}

# Удаление заметки
delete_note() {
    local note_id="$1"
    local note_line=$(grep "^${note_id}|" "$NOTES_FILE")
    local note_content=$(echo "$note_line" | cut -d'|' -f3- | cut -c1-30)
    
    # Очищаем текст перед показом в диалоге удаления
    local clean_note_content=$(clean_text "$note_content")
    
    local response=$(osascript -e "button returned of (display dialog \"Удалить заметку?\\n\\n$clean_note_content...\" buttons {\"Отмена\", \"Удалить\"} default button \"Отмена\" with icon caution)")
    
    if [ "$response" = "Удалить" ]; then
        grep -v "^${note_id}|" "$NOTES_FILE" > "${NOTES_FILE}.tmp"
        mv "${NOTES_FILE}.tmp" "$NOTES_FILE"
        osascript -e "display notification \"🗑️ Заметка удалена\" with title \"Заметки\"" &>/dev/null
        echo "🗑️ Заметка удалена"
    else
        echo "❌ Удаление отменено"
    fi
}

# Поиск в заметках
search_notes() {
    local note_count=$(wc -l < "$NOTES_FILE" 2>/dev/null || echo 0)
    
    if [ "$note_count" -eq 0 ]; then
        osascript -e 'display dialog "📝 Заметки пусты" buttons {"OK"} default button "OK" with icon note' &>/dev/null
        return
    fi
    
    local search_term=$(osascript -e 'text returned of (display dialog "Поиск в заметках:" default answer "" buttons {"Отмена", "Найти"} default button "Найти")')
    
    if [ -z "$search_term" ]; then
        echo "❌ Поиск отменен"
        return
    fi
    
    # Очищаем поисковый запрос
    local clean_search_term=$(clean_text "$search_term")
    
    local results=$(grep -i "$clean_search_term" "$NOTES_FILE")
    local result_count=$(echo "$results" | grep -c . || echo 0)
    
    if [ "$result_count" -eq 0 ]; then
        osascript -e "display dialog \"Ничего не найдено по запросу: '$clean_search_term'\" buttons {\"OK\"} default button \"OK\" with icon stop" &>/dev/null
        echo "❌ Не найдено: '$clean_search_term'"
        return
    fi
    
    echo "🔍 Найдено $result_count заметок по '$clean_search_term':"
    echo "---"
    
    echo "$results" | tail -10 | while IFS= read -r line; do
        local note_id=$(echo "$line" | cut -d'|' -f1)
        local content=$(echo "$line" | cut -d'|' -f3- | cut -c1-50)
        # Очищаем текст для отображения в результатах поиска
        local clean_content=$(clean_text "$content")
        echo "$clean_content... | shell=\"$0\" param1=\"_view_note\" param2=\"$note_id\""
    done
    
    echo "---"
    echo "🔙 Назад | shell=\"$0\""
}

# Очистить все заметки
clear_notes() {
    local note_count=$(wc -l < "$NOTES_FILE" 2>/dev/null || echo 0)
    
    if [ "$note_count" -eq 0 ]; then
        echo "📭 Заметки уже пусты"
        return
    fi
    
    local response=$(osascript -e "button returned of (display dialog \"Удалить ВСЕ $note_count заметок?\\n\\nЭто действие нельзя отменить!\" buttons {\"Отмена\", \"Удалить\"} default button \"Отмена\" with icon caution)")
    
    if [ "$response" = "Удалить" ]; then
        > "$NOTES_FILE"
        osascript -e 'display notification "🗑️ Все заметки удалены" with title "Заметки"' &>/dev/null
        echo "🗑️ Все заметки удалены"
    else
        echo "❌ Отменено"
    fi
}

# Открыть файл в редакторе
open_file() {
    if [ -f "$NOTES_FILE" ]; then
        open -e "$NOTES_FILE"
        echo "📁 Файл открыт в текстовом редакторе"
    else
        echo "❌ Файл не найден"
    fi
}

# Обработка команд
case "${1}" in
    "_new_note") new_note ;;
    "_template_note") template_note "${2}" ;;
    "_view_note") view_note "${2}" ;;
    "_search_notes") search_notes ;;
    "_clear_notes") clear_notes ;;
    "_open_file") open_file ;;
    *) main ;;
esac