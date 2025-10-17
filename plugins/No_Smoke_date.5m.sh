#!/bin/bash
# =============================================================================
# No Smoke - CronBarX Plugin / Не курю - Плагин для CronBarX
# =============================================================================
#
# ENGLISH:
# No Smoke is a motivational tracker that shows how long you've been smoke-free.
# It displays the time elapsed since your quit date in the status bar and provides
# detailed statistics, achievements, health benefits, and money saved.
#
# РУССКИЙ:
# "Не курю" - это мотивационный трекер, который показывает сколько времени вы 
# не курите. Отображает время с момента отказа от курения в строке статуса и 
# предоставляет детальную статистику, достижения, пользу для здоровья и 
# сэкономленные деньги.
#
# FEATURES / ФУНКЦИОНАЛ:
# - Smart time display in status bar / Умное отображение времени в статус баре
# - Detailed statistics (years, months, days, hours, minutes) / Детальная статистика
# - Motivational achievements / Мотивационные достижения
# - Health benefits timeline / Этапы восстановления здоровья
# - Money savings calculation / Расчет сэкономленных денег
# - Easy date setup via dialog / Простая установка даты через диалог
# - Persistent date storage / Сохранение даты между запусками
#
# USAGE / ИСПОЛЬЗОВАНИЕ:
# 1. On first run, enter your quit date via dialog / При первом запуске введите дату отказа
# 2. Watch your progress in status bar / Следите за прогрессом в строке статуса
# 3. Click for detailed statistics / Нажмите для детальной статистики
#
# AUTHOR: CronBarX User
# VERSION: 1.1
# =============================================================================

# Файлы для хранения данных
DATE_FILE="$HOME/.nosmoke_date"
SETTINGS_FILE="$HOME/.nosmoke_settings"

# Функция для загрузки настроек
load_settings() {
    if [ -f "$SETTINGS_FILE" ]; then
        source "$SETTINGS_FILE"
    else
        # Значения по умолчанию
        CIGARETTES_PER_DAY=10
        PRICE_PER_CIGARETTE=5
        # Сохраняем настройки по умолчанию
        echo "CIGARETTES_PER_DAY=10" > "$SETTINGS_FILE"
        echo "PRICE_PER_CIGARETTE=5" >> "$SETTINGS_FILE"
    fi
}

# Функция для сохранения настроек
save_settings() {
    echo "CIGARETTES_PER_DAY=$CIGARETTES_PER_DAY" > "$SETTINGS_FILE"
    echo "PRICE_PER_CIGARETTE=$PRICE_PER_CIGARETTE" >> "$SETTINGS_FILE"
}

# Функция для настройки параметров
configure_settings() {
    load_settings
    
    local cigs_dialog=$(osascript <<EOF
    display dialog "Сколько сигарет выкуривали в день?" default answer "$CIGARETTES_PER_DAY" buttons {"Отмена", "Далее"} default button "Далее"
    set result to text returned of result
    result
EOF
    )
    
    if [ -z "$cigs_dialog" ] || [ "$cigs_dialog" = "0" ]; then
        echo "❌ Отменено"
        return
    fi
    
    local price_dialog=$(osascript <<EOF
    display dialog "Стоимость одной сигареты (руб)?" default answer "$PRICE_PER_CIGARETTE" buttons {"Отмена", "Сохранить"} default button "Сохранить"
    set result to text returned of result
    result
EOF
    )
    
    if [ -n "$price_dialog" ] && [ "$price_dialog" != "0" ]; then
        CIGARETTES_PER_DAY=$cigs_dialog
        PRICE_PER_CIGARETTE=$price_dialog
        save_settings
        osascript -e "display notification \"✅ Настройки сохранены: $CIGARETTES_PER_DAY сигарет/день, $PRICE_PER_CIGARETTE руб/сигарета\" with title \"Не курю\"" &>/dev/null
        echo "✅ Настройки сохранены"
    else
        echo "❌ Отменено"
    fi
}

# Функция для получения даты через osascript
get_quit_date() {
    # Пробуем прочитать сохраненную дату
    if [ -f "$DATE_FILE" ]; then
        local saved_date=$(cat "$DATE_FILE")
        echo "$saved_date"
        return 0
    fi
    
    # Если даты нет, запрашиваем через диалог
    local date_input=$(osascript <<EOF
    set defaultDate to do shell script "date -v-7d '+%Y-%m-%d 00:00:00'"
    display dialog "Введите дату когда бросили курить:\n\nФормат: ГГГГ-ММ-ДД ЧЧ:ММ:СС\nПример: 2024-01-15 14:30:00" default answer defaultDate buttons {"Отмена", "Сохранить"} default button "Сохранить"
    set result to text returned of result
    result
EOF
    )
    
    if [ -n "$date_input" ]; then
        # Проверяем валидность даты
        if date -j -f "%Y-%m-%d %H:%M:%S" "$date_input" "+%s" &>/dev/null; then
            echo "$date_input" > "$DATE_FILE"
            echo "$date_input"
            return 0
        else
            osascript -e 'display dialog "❌ Неверный формат даты!\n\nИспользуйте: ГГГГ-ММ-ДД ЧЧ:ММ:СС\nПример: 2024-01-15 14:30:00" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
            return 1
        fi
    fi
    
    return 1
}

# Функция для изменения даты
change_quit_date() {
    local current_date=""
    if [ -f "$DATE_FILE" ]; then
        current_date=$(cat "$DATE_FILE")
    else
        current_date=$(date -v-7d "+%Y-%m-%d 00:00:00")
    fi
    
    local new_date=$(osascript <<EOF
    display dialog "Введите новую дату когда бросили курить:\n\nФормат: ГГГГ-ММ-ДД ЧЧ:ММ:СС" default answer "$current_date" buttons {"Отмена", "Сохранить"} default button "Сохранить"
    set result to text returned of result
    result
EOF
    )
    
    if [ -n "$new_date" ]; then
        if date -j -f "%Y-%m-%d %H:%M:%S" "$new_date" "+%s" &>/dev/null; then
            echo "$new_date" > "$DATE_FILE"
            osascript -e "display notification \"✅ Дата обновлена: $new_date\" with title \"Не курю\"" &>/dev/null
            echo "✅ Дата обновлена: $new_date"
        else
            osascript -e 'display dialog "❌ Неверный формат даты!\n\nИспользуйте: ГГГГ-ММ-ДД ЧЧ:ММ:СС" buttons {"OK"} default button "OK" with icon stop' &>/dev/null
            echo "❌ Неверный формат даты"
        fi
    else
        echo "❌ Отменено"
    fi
}

# Основная функция
main() {
    # Загружаем настройки
    load_settings
    
    # Получаем дату когда бросили курить
    local QUIT_DATE=$(get_quit_date)
    
    if [ -z "$QUIT_DATE" ]; then
        echo "🚭 Установите дату"
        echo "---"
        echo "📅 Установить дату | shell=\"$0\" param1=\"_set_date\" refresh=true"
        return
    fi
    
    # Получаем текущее время и время когда бросили
    local quit_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$QUIT_DATE" "+%s" 2>/dev/null)
    local current_timestamp=$(date "+%s")
    
    if [ -z "$quit_timestamp" ]; then
        echo "🚭 Ошибка даты"
        echo "---"
        echo "📅 Исправить дату | shell=\"$0\" param1=\"_set_date\" refresh=true"
        return
    fi
    
    # Вычисляем разницу в секундах
    local seconds_diff=$((current_timestamp - quit_timestamp))
    
    # Проверяем что дата в прошлом
    if [ $seconds_diff -lt 0 ]; then
        echo "🚭 Будущее?"
        echo "---"
        echo "📅 Исправить дату | shell=\"$0\" param1=\"_set_date\" refresh=true"
        return
    fi
    
    # Вычисляем составляющие времени
    local years=$((seconds_diff / 31536000))
    local months=$(( (seconds_diff % 31536000) / 2592000 ))
    local days=$(( (seconds_diff % 2592000) / 86400 ))
    local hours=$(( (seconds_diff % 86400) / 3600 ))
    local minutes=$(( (seconds_diff % 3600) / 60 ))
    
    # Отображаем в статус баре
    if [ $years -gt 0 ]; then
        echo "🚭 ${years}г ${months}м ${days}д"
    elif [ $months -gt 0 ]; then
        echo "🚭 ${months}м ${days}д ${hours}ч"
    elif [ $days -gt 0 ]; then
        echo "🚭 ${days}д ${hours}ч"
    else
        echo "🚭 ${hours}ч ${minutes}м"
    fi
    
    echo "---"
    
    # Подробная статистика
    echo "📊 Статистика без курения:"
    echo "🎯 Начало: $QUIT_DATE | refresh=true"
    echo "📅 Всего дней: $((seconds_diff / 86400)) | refresh=true"
    echo "⏰ Всего часов: $((seconds_diff / 3600)) | refresh=true"
    
    if [ $years -gt 0 ]; then
        echo "📅 Лет: $years | refresh=true"
    fi
    if [ $months -gt 0 ]; then
        echo "📅 Месяцев: $months | refresh=true"
    fi
    if [ $days -gt 0 ]; then
        echo "📅 Дней: $days | refresh=true"
    fi
    echo "⏰ Часов: $hours | refresh=true"
    echo "⏰ Минут: $minutes | refresh=true"
    
    echo "---"
    
    # Расчет сэкономленных денег
    local total_days=$((seconds_diff / 86400))
    local cigarettes_saved=$((total_days * CIGARETTES_PER_DAY))
    local money_saved=$((cigarettes_saved * PRICE_PER_CIGARETTE))
    
    echo "💰 Сэкономлено:"
    echo "🚬 Сигарет не выкурено: $cigarettes_saved | refresh=true"
    echo "💵 Денег сэкономлено: $money_saved руб | refresh=true"
    echo "📈 В день: $((CIGARETTES_PER_DAY * PRICE_PER_CIGARETTE)) руб | refresh=true"
    
    echo "---"
    
    # Достижения
    echo "💪 Достижения:"
    
    if [ $total_days -ge 365 ]; then
        echo "🏆 Более года без курения! | refresh=true"
    elif [ $total_days -ge 180 ]; then
        echo "⭐ Полгода без сигарет! | refresh=true"
    elif [ $total_days -ge 90 ]; then
        echo "👍 3 месяца - отлично! | refresh=true"
    elif [ $total_days -ge 30 ]; then
        echo "👏 Первый месяц пройден! | refresh=true"
    elif [ $total_days -ge 7 ]; then
        echo "💪 Первая неделя - сложный этап! | refresh=true"
    else
        echo "🔥 Вы только начали - так держать! | refresh=true"
    fi
    
    echo "---"
    
    # Польза для здоровья
    echo "❤️ Здоровье:"
    
    if [ $total_days -ge 30 ]; then
        echo "❤️ Давление нормализовалось | refresh=true"
        echo "🌬️ Легкие восстанавливаются | refresh=true"
        echo "🏃 Исчезла одышка | refresh=true"
    elif [ $total_days -ge 7 ]; then
        echo "💓 Улучшилось кровообращение | refresh=true"
        echo "👃 Восстановилось обоняние | refresh=true"
        echo "💤 Сон стал лучше | refresh=true"
    else
        echo "💊 Кислород в крови растет | refresh=true"
        echo "✨ Организм очищается | refresh=true"
        echo "🌪️ Дышать становится легче | refresh=true"
    fi
    
    echo "---"
    
    # Настройки
    echo "⚙️ Настройки:"
    echo "--🚬 Сигарет в день: $CIGARETTES_PER_DAY"
    echo "--💵 Цена за сигарету: $PRICE_PER_CIGARETTE руб"
    
    echo "---"
    
    # Управление
    echo "⚙️ Управление:"
    echo "--📅 Изменить дату | shell=\"$0\" param1=\"_set_date\" refresh=true"
    echo "--⚙️ Настройки сигарет | shell=\"$0\" param1=\"_configure\" refresh=true"
    echo "--🗑️ Сбросить настройки | shell=\"$0\" param1=\"_reset_all\" refresh=true"
}

# Сброс всех данных
reset_all() {
    if [ -f "$DATE_FILE" ]; then
        rm "$DATE_FILE"
    fi
    if [ -f "$SETTINGS_FILE" ]; then
        rm "$SETTINGS_FILE"
    fi
    osascript -e 'display notification "🗑️ Все данные сброшены" with title "Не курю"' &>/dev/null
    echo "🗑️ Все данные сброшены"
}

# Обработка команд
case "${1}" in
    "_set_date") change_quit_date ;;
    "_configure") configure_settings ;;
    "_reset_all") reset_all ;;
    *) main ;;
esac
