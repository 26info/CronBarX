#!/bin/bash
#
# Менеджер Cron заданий для CronBarX
#

get_cron_status() {
    local cron_status=""
    if pgrep cron &>/dev/null; then
        cron_status="🟢"
    else
        cron_status="🔴"
    fi
    
    if crontab -l &>/dev/null; then
        local job_count=$(crontab -l | grep -c '^[^#]')
        local active_count=$(crontab -l | grep -v '^[[:space:]]*#' | grep -c '^[^#]')
        echo "⏰ $active_count/$job_count активны $cron_status"
    else
        echo "⏰ 0 заданий $cron_status"
    fi
}

# Функция для обработки редактирования задания
process_cron_edit() {
    local user_input="$1"
    local line_num="$2"
    local original_line="$3"
    
    # Показываем что получили от пользователя
    osascript -e "tell application \"System Events\" to display dialog \"Получено от пользователя:\n\n$user_input\n\nОригинальная строка:\n$original_line\n\nНомер строки: $line_num\n\nНажмите OK для применения изменений\" with title \"Проверка ввода\""
    
    # Применяем изменения к crontab
    if crontab -l &>/dev/null; then
        crontab -l | sed "${line_num}s|.*|${user_input}|" | crontab -
        echo "✅ Задание обновлено"
    else
        echo "$user_input" | crontab -
        echo "✅ Задание добавлено"
    fi
}

# Функция для обработки создания нового задания
process_cron_create() {
    local user_input="$1"
    
    # Показываем что получили от пользователя
    osascript -e "tell application \"System Events\" to display dialog \"Получено новое задание:\n\n$user_input\n\nНажмите OK для добавления\" with title \"Проверка ввода\""
    
    # Добавляем новое задание в crontab
    if crontab -l &>/dev/null; then
        crontab -l | cat - <(echo "$user_input") | crontab -
    else
        echo "$user_input" | crontab -
    fi
    echo "✅ Новое задание добавлено"
}

show_current_jobs() {
    echo "---"
    echo "📋 Текущие задания | refresh=true"
    
    if crontab -l &>/dev/null; then
        # Создаем временный файл с нумерацией строк
        local temp_file=$(mktemp)
        crontab -l | cat -n > "$temp_file"
        
        while IFS= read -r numbered_line; do
            # Извлекаем номер строки и содержимое
            local line_num=$(echo "$numbered_line" | awk '{print $1}')
            local line=$(echo "$numbered_line" | cut -f2-)
            
            if [[ ! -z "$line" ]]; then
                # Экранируем кавычки для AppleScript
                local escaped_line=$(echo "$line" | sed 's/"/\\\\"/g')
                # Экранируем кавычки также для передачи в process_cron_edit
                local escaped_line_for_edit=$(echo "$line" | sed 's/"/\\"/g')
                
                if [[ "$line" =~ ^[[:space:]]*# ]]; then
                    # Отключенное задание
                    local clean_line=$(echo "$line" | sed 's/^[[:space:]]*#//')
                    echo "❌ $clean_line"
                    echo "--✅ Включить | shell=crontab -l | sed '${line_num}s/^[[:space:]]*#//' | crontab - refresh=true"
                    echo "--✏️ Редактировать | shell=osascript -e 'tell application \"System Events\" to display dialog \"Редактирование cron задания:\n\nТекущее задание:\n$escaped_line\n\nВведите новое задание:\" default answer \"$escaped_line\" with title \"Редактирование Cron\"' -e 'text returned of result' 2>/dev/null | xargs -I {} /bin/bash -c 'source \"$0\"; process_cron_edit \"{}\" \"'\"$line_num\"'\" \"'\"$escaped_line_for_edit\"'\"' \"$0\" refresh=true terminal=false"
                    echo "--🗑️ Удалить | shell=crontab -l | sed '${line_num}d' | crontab - refresh=true"
                else
                    # Активное задание
                    echo "✅ $line"
                    echo "--✏️ Редактировать | shell=osascript -e 'tell application \"System Events\" to display dialog \"Редактирование cron задания:\n\nТекущее задание:\n$escaped_line\n\nВведите новое задание:\" default answer \"$escaped_line\" with title \"Редактирование Cron\"' -e 'text returned of result' 2>/dev/null | xargs -I {} /bin/bash -c 'source \"$0\"; process_cron_edit \"{}\" \"'\"$line_num\"'\" \"'\"$escaped_line_for_edit\"'\"' \"$0\" refresh=true terminal=false"
                    echo "--⏸️ Отключить | shell=crontab -l | sed '${line_num}s/^/#/' | crontab - refresh=true"
                    echo "--🗑️ Удалить | shell=crontab -l | sed '${line_num}d' | crontab - refresh=true"
                fi
            fi
        done < "$temp_file"
        
        rm -f "$temp_file"
    else
        echo "Crontab пуст"
    fi
}

echo "$(get_cron_status)"
show_current_jobs

echo "---"
echo "➕ Быстрое добавление"

# Основные интервалы - теперь как вложенное меню
echo "🔄 Основные интервалы"
echo "--🔄 Каждую минуту | shell=crontab -l 2>/dev/null | cat - <(echo '* * * * * echo \"🕒 Минутное задание выполено: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--⏰ Каждый час | shell=crontab -l 2>/dev/null | cat - <(echo '0 * * * * echo \"🕐 Часовое задание выполено: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--🌅 Ежедневно 9:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 9 * * * echo \"☀️ Ежедневное задание выполено: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--🌙 Ежедневно 18:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 18 * * * echo \"🌙 Вечернее задание выполено: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"

# По дням недели - теперь как вложенное меню
echo "📅 По дням недели"
echo "--📌 Каждый понедельник 9:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 9 * * 1 echo \"📅 Понедельник: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--📌 Каждую пятницу 17:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 17 * * 5 echo \"🎉 Пятница: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--📌 Каждые выходные 10:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 10 * * 0,6 echo \"🏠 Выходные: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"

# По дням месяца - теперь как вложенное меню
echo "🗓️ По дням месяца"
echo "--📆 1-го числа 8:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 8 1 * * echo \"📆 Первое число: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--📆 15-го числа 12:00 | shell=crontab -l 2>/dev/null | cat - <(echo '0 12 15 * * echo \"📆 Середина месяца: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"

# Системные задачи - теперь как вложенное меню
echo "⚡ Системные задачи"
echo "--🧹 Очистка логов | shell=crontab -l 2>/dev/null | cat - <(echo '0 2 * * * find /tmp -name \"cron-test.log\" -mtime +7 -delete') | crontab - refresh=true"
echo "--💾 Бэкап crontab | shell=crontab -l 2>/dev/null | cat - <(echo '0 3 * * * crontab -l > ~/crontab-backup-$(date +%Y%m%d).txt') | crontab - refresh=true"
echo "--📊 Статистика диска | shell=crontab -l 2>/dev/null | cat - <(echo '0 6 * * * df -h >> /tmp/disk-stats.log') | crontab - refresh=true"

# Специальные интервалы - теперь как вложенное меню
echo "🎯 Специальные интервалы"
echo "--⏱️ Каждые 5 минут | shell=crontab -l 2>/dev/null | cat - <(echo '*/5 * * * * echo \"⏱️ Каждые 5 минут: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--⏱️ Каждые 15 минут | shell=crontab -l 2>/dev/null | cat - <(echo '*/15 * * * * echo \"⏱️ Каждые 15 минут: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"
echo "--⏱️ Каждые 30 минут | shell=crontab -l 2>/dev/null | cat - <(echo '*/30 * * * * echo \"⏱️ Каждые 30 минут: $(date)\" >> /tmp/cron-test.log') | crontab - refresh=true"

echo "---"
echo "⚙️ Управление"
echo "✏️ Новое задание | shell=osascript -e 'tell application \"System Events\" to display dialog \"Создание нового cron задания:\n\nФормат: минута час день_месяца месяц день_недели команда\n\nПримеры:\n* * * * *    /path/to/script.sh\n0 * * * *    Каждый час\n0 9 * * *    Каждый день в 9:00\n0 9 * * 1    Каждый понедельник в 9:00\" default answer \"\" with title \"Новое Cron задание\"' -e 'text returned of result' 2>/dev/null | xargs -I {} /bin/bash -c 'source \"$0\"; process_cron_create \"{}\"' \"$0\" refresh=true terminal=false"
echo "📋 Просмотреть все | shell=osascript -e 'tell application \"Terminal\" to activate' -e 'delay 0.5' -e 'tell application \"Terminal\" to do script \"crontab -l\"'"
echo "✏️ Редактировать все | shell=osascript -e 'tell application \"Terminal\" to activate' -e 'delay 0.5' -e 'tell application \"Terminal\" to do script \"crontab -e\"'"
echo "🗑️ Очистить все | shell=crontab -r refresh=true"

echo "---"
echo "🔄 Обновлено: $(date '+%H:%M:%S') | refresh=true"
