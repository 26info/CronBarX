#!/bin/bash
# Погода - CronBarX

# Функция для показа диалога
show_dialog() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button 1"
}

# Функция для показа уведомления
show_notification() {
    osascript -e "display notification \"$1\" with title \"$2\""
}

# Получение локации
get_location() {
    if [ -f /tmp/weather_location.txt ]; then
        cat /tmp/weather_location.txt
    else
        echo "Moscow"
    fi
}

# Сохранение локации
save_location() {
    echo "$1" > /tmp/weather_location.txt
}

# Функции для команд погоды
show_current_weather() {
    location=$(get_location)
    weather=$(curl -s "wttr.in/$location?format=%l:+%C+%t+%h+%w" 2>/dev/null)
    if [ -n "$weather" ]; then
        show_notification "$weather" "Текущая погода"
    else
        show_notification "Нет соединения" "Погода"
    fi
}

show_compact_weather() {
    location=$(get_location)
    # Компактный прогноз на сегодня
    weather=$(curl -s "wttr.in/$location?format=%l:\n%c+%t\nВетер:+%w\nВлажность:+%h\nОсадки:+%p" 2>/dev/null)
    if [ -n "$weather" ]; then
        show_dialog "Погода в $location:\n\n$weather"
    else
        show_notification "Нет соединения" "Погода"
    fi
}

change_location() {
    current_location=$(get_location)
    new_location=$(osascript -e "text returned of (display dialog \"Введите город:\" default answer \"$current_location\" buttons {\"Cancel\", \"OK\"} default button \"OK\")")
    
    if [ -n "$new_location" ]; then
        save_location "$new_location"
        show_notification "Локация изменена на: $new_location" "Погода"
    fi
}

show_weather_map() {
    location=$(get_location)
    open "https://wttr.in/$location.png"
}

show_moon_phase() {
    moon=$(curl -s "wttr.in/Moon?format=%m" 2>/dev/null)
    if [ -n "$moon" ]; then
        show_notification "Фаза луны: $moon" "Луна"
    else
        show_notification "Нет данных о луне" "Луна"
    fi
}

# Получение иконки погоды для статус-бара
get_weather_icon() {
    location=$(get_location)
    condition=$(curl -s "wttr.in/$location?format=%C" 2>/dev/null)
    
    # Простая логика для иконок
    if echo "$condition" | grep -qi "rain"; then
        echo "🌧️"
    elif echo "$condition" | grep -qi "snow"; then
        echo "❄️"
    elif echo "$condition" | grep -qi "cloud"; then
        echo "☁️"
    elif echo "$condition" | grep -qi "sun"; then
        echo "☀️"
    elif echo "$condition" | grep -qi "clear"; then
        echo "☀️"
    else
        echo "🌤️"
    fi
}

# Получение текущей погоды для отображения в меню
get_current_weather_display() {
    location=$(get_location)
    weather=$(curl -s "wttr.in/$location?format=%C+%t" 2>/dev/null)
    if [ -n "$weather" ]; then
        echo "$weather"
    else
        echo "Нет данных"
    fi
}

# Основное меню
location=$(get_location)
weather_icon=$(get_weather_icon)
current_weather=$(get_current_weather_display)

echo "${weather_icon} Погода"
echo "---"

# Текущая погода в меню
echo "📍 $location: $current_weather"
echo "-- 📊 Обновить данные | refresh=true"

echo "---"

echo "🌡️ Прогноз погоды"
echo "-- Текущая погода | shell=\"$0\" _show_current_weather"
echo "-- Краткий прогноз | shell=\"$0\" _show_compact_weather"
echo "-- Фаза луны | shell=\"$0\" _show_moon_phase"

echo "---"

echo "⚙️ Настройки"
echo "-- Сменить город | shell=\"$0\" _change_location"
echo "-- Открыть карту | shell=\"$0\" _show_weather_map"
echo "-- Текущий город: $location"

echo "---"

echo "🏙️ Популярные города"
echo "-- Москва | shell=\"$0\" _set_location Moscow"
echo "-- СПб | shell=\"$0\" _set_location 'Saint Petersburg'"
echo "-- Лондон | shell=\"$0\" _set_location London"
echo "-- Нью-Йорк | shell=\"$0\" _set_location 'New York'"
echo "-- Токио | shell=\"$0\" _set_location Tokyo"

echo "---"

echo "🌐 Быстрые действия"
echo "-- Открыть wttr.in | shell=open https://wttr.in/$location"
echo "-- Сбросить город | shell=\"$0\" _reset_location"

echo "---"
echo "🔄 Обновить | refresh=true"

# Обработка команд
case "$1" in
    "_show_current_weather")
        show_current_weather
        ;;
    "_show_compact_weather")
        show_compact_weather
        ;;
    "_change_location")
        change_location
        ;;
    "_show_weather_map")
        show_weather_map
        ;;
    "_show_moon_phase")
        show_moon_phase
        ;;
    "_set_location")
        save_location "$2"
        show_notification "Локация изменена на: $2" "Погода"
        ;;
    "_reset_location")
        rm -f /tmp/weather_location.txt
        show_notification "Локация сброшена на Москву" "Погода"
        ;;
esac