#!/bin/bash

# LostFilm TV RSS Reader for CronBarX
# Читатель RSS LostFilm TV для CronBarX

RSS_URL="https://lostfilm.top/rss.xml"
CACHE_FILE="/tmp/lostfilm_rss_cache.txt"
MAX_ITEMS=8

# Функция загрузки RSS
fetch_rss() {
    # Обновляем кэш если старше 10 минут или не существует
    if [ ! -f "$CACHE_FILE" ] || find "$CACHE_FILE" -mmin +10 > /dev/null 2>&1; then
        curl -s --max-time 10 "$RSS_URL" > "$CACHE_FILE"
    fi
}

# Функция парсинга и отображения
display_rss() {
    echo "🎬 LF"
    echo "---"
    echo "LostFilm TV - Новые релизы | href=https://www.lostfilm.tv/"
    echo "Обновлено: $(date '+%H:%M')"
    echo "---"
    
    local count=0
    local current_title=""
    local current_link=""
    
    # Читаем файл построчно
    while IFS= read -r line; do
        # Ищем заголовок
        if [[ "$line" =~ "<title>" ]] && [[ ! "$line" =~ "LostFilm.TV" ]]; then
            current_title=$(echo "$line" | sed -e 's/.*<title>//' -e 's/<\/title>.*//' -e 's/^[ \t]*//' -e 's/[ \t]*$//')
        
        # Ищем ссылку
        elif [[ "$line" =~ "<link>" ]] && [[ ! "$line" =~ "rss.xml" ]] && [[ ! "$line" =~ "lostfilm.tv/" ]]; then
            current_link=$(echo "$line" | sed -e 's/.*<link>//' -e 's/<\/link>.*//' -e 's/^[ \t]*//' -e 's/[ \t]*$//')
            
            # Когда есть и заголовок и ссылка - выводим
            if [ ! -z "$current_title" ] && [ ! -z "$current_link" ] && [ ${#current_title} -gt 5 ]; then
                ((count++))
                
                # Обрезаем длинные названия
                local display_title="$current_title"
                if [ ${#display_title} -gt 55 ]; then
                    display_title="${display_title:0:52}..."
                fi
                
                # Выводим основной элемент
                echo "🎬 $display_title | href=$current_link"
                
                # Сбрасываем переменные
                current_title=""
                current_link=""
                
                # Ограничиваем количество элементов
                if [ $count -ge $MAX_ITEMS ]; then
                    break
                fi
            fi
        fi
    done < "$CACHE_FILE"
    
    # Если ничего не найдено
    if [ $count -eq 0 ]; then
        echo "📭 Нет новых релизов"
        echo "Попробуйте обновить позже"
    else
        echo "---"
        echo "📊 Показано: $count из $MAX_ITEMS релизов"
    fi
}

# Основная функция
main() {
    fetch_rss
    
    if [ ! -f "$CACHE_FILE" ] || [ ! -s "$CACHE_FILE" ]; then
        # Ошибка загрузки
        echo "🎬 LF"
        echo "---"
        echo "❌ Ошибка загрузки"
        echo "---"
        echo "🔄 Повторить попытку | refresh=true"
        echo "🌐 Открыть сайт | href=https://www.lostfilm.tv/"
        return 1
    fi
    
    display_rss
    
    echo "---"
    echo "⚡ Действия"
    echo "🗑️ Очистить кэш | shell=\"rm -f \\\"$CACHE_FILE\\\"\" refresh=true"
    echo "---"
    echo "🌐 Ссылки"
    echo "Открыть сайт LostFilm | href=https://www.lostfilm.tv/"
    echo "Открыть RSS | href=$RSS_URL"
    echo "---"
    echo "ℹ️ О скрипте"
    echo "Автообновление: каждые 10 мин"
    echo "RSS источник: lostfilm.top"
}

# Специальные команды
case "${1}" in
    "--clear-cache")
        rm -f "$CACHE_FILE"
        echo "✅ Кэш очищен | refresh=true"
        ;;
    "--force-refresh")
        rm -f "$CACHE_FILE"
        main
        ;;
    "--test")
        echo "🎬 LF - Тест"
        echo "---"
        echo "✅ RSS доступен: $RSS_URL"
        echo "📁 Кэш: $CACHE_FILE"
        if [ -f "$CACHE_FILE" ]; then
            echo "📊 Размер: $(wc -l < "$CACHE_FILE") строк"
            echo "⏰ Возраст: $(find "$CACHE_FILE" -exec stat -f%c {} \; 2>/dev/null | xargs -I {} date -r {} +%H:%M 2>/dev/null || echo "unknown")"
        fi
        echo "---"
        echo "🔄 Запустить основной скрипт | refresh=true"
        ;;
    *)
        main
        ;;
esac