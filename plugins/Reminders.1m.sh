#!/bin/bash
# Smart Reminders - CronBarX
# Умные напоминания с многоуровневыми уведомлениями

REMINDERS_FILE="$HOME/.smart_reminders"

# Создаем файл если не существует
if [ ! -f "$REMINDERS_FILE" ]; then
    touch "$REMINDERS_FILE"
fi

# Функция для очистки текста
clean_text() {
    local text="$1"
    text="${text//\"/\'}"
    text="${text//\\/}"
    text="${text//|/}"
    text="${text//\$/}"
    text="${text//\`/}"
    echo "$text" | sed 's/  */ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Генератор уникального ID
generate_id() {
    date +%s%N | cut -c1-16
}

# Проверка и выполнение напоминаний
check_reminders() {
    local current_timestamp=$(date "+%s")
    
    # Создаем временный файл
    local temp_file="${REMINDERS_FILE}.tmp"
    > "$temp_file"
    
    # Читаем оригинальный файл
    if [ -f "$REMINDERS_FILE" ] && [ -s "$REMINDERS_FILE" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [ -z "$line" ] && continue
            
            # Разбираем строку
            IFS='|' read -r id event_time event_title status last_notified <<< "$line"
            
            # Проверяем валидность времени
            local event_timestamp=$(date -j -f "%Y-%m-%d %H:%M" "$event_time" "+%s" 2>/dev/null)
            if [ -z "$event_timestamp" ]; then
                echo "$line" >> "$temp_file"
                continue
            fi
            
            local time_diff=$((event_timestamp - current_timestamp))
            
            # Обрабатываем статусы
            case "$status" in
                "pending")
                    # Если last_notified = "new", это новое напоминание - ждем минимум 5 минут перед первым уведомлением
                    if [ "$last_notified" = "new" ]; then
                        # Первое уведомление только через 5 минут после создания
                        local created_time=$(echo "$id" | cut -c1-10)
                        local current_time=$(date "+%s")
                        local time_since_created=$((current_time - created_time))
                        
                        if [ $time_since_created -ge 300 ]; then # 5 минут
                            # Переходим к обычной обработке
                            if [ $time_diff -le 3600 ] && [ $time_diff -gt 1800 ]; then
                                osascript -e "display notification \"⏰ Через 1 час: $event_title\" with title \"Напоминание\"" &>/dev/null
                                osascript -e "beep" &>/dev/null
                                echo "${id}|${event_time}|${event_title}|pending|1h" >> "$temp_file"
                            elif [ $time_diff -le 1800 ] && [ $time_diff -gt 600 ]; then
                                osascript -e "display notification \"⚠️ Через 30 минут: $event_title\" with title \"Напоминание\"" &>/dev/null
                                osascript -e "beep" &>/dev/null
                                echo "${id}|${event_time}|${event_title}|pending|30m" >> "$temp_file"
                            elif [ $time_diff -le 600 ] && [ $time_diff -gt 0 ]; then
                                osascript -e "display notification \"🔔 Через 10 минут: $event_title\" with title \"Скоро событие!\"" &>/dev/null
                                osascript -e "beep" &>/dev/null
                                echo "${id}|${event_time}|${event_title}|pending|10m" >> "$temp_file"
                            elif [ $time_diff -le 0 ]; then
                                osascript -e "display notification \"🚨 СЕЙЧАС: $event_title\" with title \"СОБЫТИЕ!\"" &>/dev/null
                                osascript -e "beep" &>/dev/null
                                echo "${id}|${event_time}|${event_title}|active|event" >> "$temp_file"
                            else
                                echo "${id}|${event_time}|${event_title}|pending|new" >> "$temp_file"
                            fi
                        else
                            # Еще не прошло 5 минут - оставляем как есть
                            echo "$line" >> "$temp_file"
                        fi
                    else
                        # Обычная обработка для существующих напоминаний
                        if [ $time_diff -le 3600 ] && [ $time_diff -gt 1800 ] && [ "$last_notified" != "1h" ]; then
                            osascript -e "display notification \"⏰ Через 1 час: $event_title\" with title \"Напоминание\"" &>/dev/null
                            osascript -e "beep" &>/dev/null
                            echo "${id}|${event_time}|${event_title}|pending|1h" >> "$temp_file"
                        elif [ $time_diff -le 1800 ] && [ $time_diff -gt 600 ] && [ "$last_notified" != "30m" ]; then
                            osascript -e "display notification \"⚠️ Через 30 минут: $event_title\" with title \"Напоминание\"" &>/dev/null
                            osascript -e "beep" &>/dev/null
                            echo "${id}|${event_time}|${event_title}|pending|30m" >> "$temp_file"
                        elif [ $time_diff -le 600 ] && [ $time_diff -gt 0 ] && [ "$last_notified" != "10m" ]; then
                            osascript -e "display notification \"🔔 Через 10 минут: $event_title\" with title \"Скоро событие!\"" &>/dev/null
                            osascript -e "beep" &>/dev/null
                            echo "${id}|${event_time}|${event_title}|pending|10m" >> "$temp_file"
                        elif [ $time_diff -le 0 ] && [ "$last_notified" != "event" ]; then
                            osascript -e "display notification \"🚨 СЕЙЧАС: $event_title\" with title \"СОБЫТИЕ!\"" &>/dev/null
                            osascript -e "beep" &>/dev/null
                            echo "${id}|${event_time}|${event_title}|active|event" >> "$temp_file"
                        else
                            echo "$line" >> "$temp_file"
                        fi
                    fi
                    ;;
                    
                "active")
                    local abs_time_diff=${time_diff#-}
                    local hours_passed=$((abs_time_diff / 3600))
                    if [ $hours_passed -gt 0 ] && [ "$last_notified" != "h${hours_passed}" ]; then
                        osascript -e "display notification \"⏳ Прошло ${hours_passed}ч: $event_title\" with title \"Напоминание\"" &>/dev/null
                        osascript -e "beep" &>/dev/null
                        echo "${id}|${event_time}|${event_title}|active|h${hours_passed}" >> "$temp_file"
                    else
                        echo "$line" >> "$temp_file"
                    fi
                    ;;
                    
                *)
                    echo "$line" >> "$temp_file"
                    ;;
            esac
        done < "$REMINDERS_FILE"
    fi
    
    # Заменяем файл
    mv "$temp_file" "$REMINDERS_FILE" 2>/dev/null
}

# Основная функция
main() {
    check_reminders
    
    echo "⏰ Напоминания"
    echo "---"
    
    # Проверяем есть ли напоминания
    if [ ! -s "$REMINDERS_FILE" ]; then
        echo "📭 Нет напоминаний"
        echo "---"
    else
        echo "🎯 Ближайшие события:"
        
        # Собираем и сортируем напоминания
        local reminders=()
        while IFS= read -r line || [ -n "$line" ]; do
            [ -z "$line" ] && continue
            IFS='|' read -r id event_time event_title status last_notified <<< "$line"
            local timestamp=$(date -j -f "%Y-%m-%d %H:%M" "$event_time" "+%s" 2>/dev/null)
            if [ -n "$timestamp" ]; then
                reminders+=("${timestamp}|${id}|${event_time}|${event_title}|${status}")
            fi
        done < "$REMINDERS_FILE"
        
        # Сортируем по времени
        if [ ${#reminders[@]} -gt 0 ]; then
            printf '%s\n' "${reminders[@]}" | sort -n | head -5 | while IFS='|' read -r timestamp id event_time event_title status; do
                local time_display=$(date -j -f "%s" "$timestamp" "+%H:%M" 2>/dev/null)
                local today=$(date "+%Y-%m-%d")
                local event_date=$(echo "$event_time" | cut -d' ' -f1)
                
                if [ "$event_date" = "$today" ]; then
                    echo "🕐 $time_display: $event_title | shell=\"$0\" param1=\"_manage\" param2=\"$id\" refresh=true"
                else
                    echo "📅 $event_time: $event_title | shell=\"$0\" param1=\"_manage\" param2=\"$id\" refresh=true"
                fi
            done
        else
            echo "📭 Нет активных напоминаний"
        fi
        echo "---"
    fi
    
    # Управление
    echo "⚙️ Управление:"
    echo "⏰ Новое напоминание | shell=\"$0\" param1=\"_new\" refresh=true"
    if [ -s "$REMINDERS_FILE" ]; then
        echo "🗑️ Очистить все | shell=\"$0\" param1=\"_clear\" refresh=true"
    fi
}

# Новое напоминание
new_reminder() {
    local default_time=$(date -v+1H "+%Y-%m-%d %H:%M")
    
    local result=$(osascript <<EOF
    set defaultTime to do shell script "date -v+1H '+%Y-%m-%d %H:%M'"
    try
        set timeResult to text returned of (display dialog "Создать напоминание:\n\nФормат: ГГГГ-ММ-ДД ЧЧ:ММ\nПример: " & defaultTime default answer defaultTime buttons {"Отмена", "Далее"} default button "Далее")
        
        set titleResult to text returned of (display dialog "Текст напоминания:" default answer "" buttons {"Отмена", "Сохранить"} default button "Сохранить")
        
        timeResult & "|" & titleResult
    on error
        "CANCEL"
    end try
EOF
    )
    
    # Если пользователь нажал Отмена
    if [ "$result" = "CANCEL" ] || [ -z "$result" ]; then
        echo "❌ Отменено"
        return
    fi
    
    local event_time=$(echo "$result" | cut -d'|' -f1)
    local event_title=$(echo "$result" | cut -d'|' -f2-)
    
    if date -j -f "%Y-%m-%d %H:%M" "$event_time" "+%s" &>/dev/null; then
        local clean_title=$(clean_text "$event_title")
        local reminder_id=$(generate_id)
        
        # Сохраняем с статусом "new" - защита от мгновенных уведомлений
        echo "${reminder_id}|${event_time}|${clean_title}|pending|new" >> "$REMINDERS_FILE"
        osascript -e "display notification \"✅ Напоминание создано на $event_time\" with title \"Напоминания\"" &>/dev/null
        echo "✅ Напоминание создано: $event_time - $clean_title"
    else
        osascript -e 'display dialog "❌ Неверный формат времени!" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
        echo "❌ Неверный формат времени"
    fi
}

# Управление напоминанием
manage_reminder() {
    local reminder_id="$1"
    
    # Ищем напоминание
    local reminder_line=""
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" == "${reminder_id}|"* ]]; then
            reminder_line="$line"
            break
        fi
    done < "$REMINDERS_FILE"
    
    if [ -z "$reminder_line" ]; then
        osascript -e 'display dialog "❌ Напоминание не найдено" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
        echo "❌ Напоминание не найдено"
        return
    fi
    
    IFS='|' read -r id event_time event_title status last_notified <<< "$reminder_line"
    
    local action=$(osascript -e "button returned of (display dialog \"Управление напоминанием:\\nВремя: $event_time\\nТекст: $event_title\" buttons {\"Назад\", \"Редактировать\", \"Удалить\"} default button \"Назад\")")
    
    case "$action" in
        "Редактировать")
            # Редактирование
            local result=$(osascript <<EOF
            set oldTime to "$event_time"
            set oldTitle to "$event_title"
            
            try
                set timeResult to text returned of (display dialog "Новое время:\n\nФормат: ГГГГ-ММ-ДД ЧЧ:ММ" default answer oldTime buttons {"Отмена", "Далее"} default button "Далее")
                
                set titleResult to text returned of (display dialog "Новый текст напоминания:" default answer oldTitle buttons {"Отмена", "Сохранить"} default button "Сохранить")
                
                timeResult & "|" & titleResult
            on error
                "CANCEL"
            end try
EOF
            )
            
            # Если пользователь нажал Отмена
            if [ "$result" = "CANCEL" ] || [ -z "$result" ]; then
                echo "❌ Редактирование отменено"
                return
            fi
            
            local new_time=$(echo "$result" | cut -d'|' -f1)
            local new_title=$(echo "$result" | cut -d'|' -f2-)
            
            if date -j -f "%Y-%m-%d %H:%M" "$new_time" "+%s" &>/dev/null; then
                local clean_title=$(clean_text "$new_title")
                
                # Создаем временный файл без старой записи
                local temp_file="${REMINDERS_FILE}.tmp"
                > "$temp_file"
                while IFS= read -r line || [ -n "$line" ]; do
                    if [[ "$line" != "${reminder_id}|"* ]]; then
                        echo "$line" >> "$temp_file"
                    fi
                done < "$REMINDERS_FILE"
                
                # Добавляем обновленную запись с защитой от мгновенных уведомлений
                echo "${reminder_id}|${new_time}|${clean_title}|pending|new" >> "$temp_file"
                mv "$temp_file" "$REMINDERS_FILE"
                
                osascript -e "display notification \"✏️ Напоминание обновлено\" with title \"Напоминания\"" &>/dev/null
                echo "✏️ Напоминание обновлено: $new_time - $clean_title"
            else
                osascript -e 'display dialog "❌ Неверный формат времени!" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
                echo "❌ Неверный формат времени"
            fi
            ;;
            
        "Удалить")
            # Удаление
            local temp_file="${REMINDERS_FILE}.tmp"
            > "$temp_file"
            while IFS= read -r line || [ -n "$line" ]; do
                if [[ "$line" != "${reminder_id}|"* ]]; then
                    echo "$line" >> "$temp_file"
                fi
            done < "$REMINDERS_FILE"
            mv "$temp_file" "$REMINDERS_FILE"
            
            osascript -e "display notification \"🗑️ Напоминание удалено\" with title \"Напоминания\"" &>/dev/null
            echo "🗑️ Напоминание удалено"
            ;;
            
        *)
            echo "🔙 Назад"
            ;;
    esac
}

# Очистить все
clear_reminders() {
    if [ ! -s "$REMINDERS_FILE" ]; then
        echo "📭 Напоминания уже пусты"
        return
    fi
    
    local response=$(osascript -e "button returned of (display dialog \"Удалить ВСЕ напоминания?\" buttons {\"Отмена\", \"Удалить\"} default button \"Отмена\" with icon caution)")
    
    if [ "$response" = "Удалить" ]; then
        > "$REMINDERS_FILE"
        osascript -e 'display notification "🗑️ Все напоминания удалены" with title "Напоминания"' &>/dev/null
        echo "🗑️ Все напоминания удалены"
    else
        echo "❌ Отменено"
    fi
}

# Обработка команд
case "${1}" in
    "_new") new_reminder ;;
    "_manage") manage_reminder "${2}" ;;
    "_clear") clear_reminders ;;
    *) main ;;
esac