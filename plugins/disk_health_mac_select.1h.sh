#!/bin/bash
# Монитор дисков для CronBarX (без sudo)

# Прямой путь к smartctl
SMARTCTL="/opt/homebrew/bin/smartctl"
# Основной диск
DISK="/dev/disk0"
# Основной контейнер
DPART="/dev/disk3s1"

# Функция для получения информации о использовании диска
get_disk_usage() {
    local disk_info=$(df -h | grep -E "(Volumes/Data)" | grep "${DPART}")
    
    if [ -n "$disk_info" ]; then
        usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
        used=$(echo "$disk_info" | awk '{print $3}')
        total=$(echo "$disk_info" | awk '{print $2}')
        echo "$usage_percent|$used|$total"
    else
        echo "?||"
    fi
}

# Получаем информацию о использовании диска
IFS='|' read -r usage_percent used total <<< "$(get_disk_usage)"

# Проверяем доступность smartctl
if [ ! -x "$SMARTCTL" ]; then
    echo "💽 ?  ${usage_percent}%"
    echo "---"
    echo "smartctl не найден"
    echo "Путь: $SMARTCTL"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Получаем информацию о диске (без sudo)
SMART_INFO=$("$SMARTCTL" -a "$DISK" 2>/dev/null)

# Проверяем, получили ли мы данные
if [ -z "$SMART_INFO" ]; then
    echo "💽 ?  ${usage_percent}%"
    echo "---"
    echo "Нет доступа к SMART"
    echo "Диск: $DISK"
    echo "Команда: $SMARTCTL -a $DISK"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Универсальная функция для получения температуры
get_temperature() {
    local smart_info="$1"
    
    # Пробуем разные способы найти температуру
    
    # 1. Ищем в атрибутах SMART (поле RAW_VALUE)
    temp_attr=$(echo "$smart_info" | grep -E "^[[:space:]]*(190|194|197|198|199)" | grep -v "0[[:space:]]*\-" | awk '{print $10}' | grep -E "^[0-9]+$" | head -1)
    
    if [ -n "$temp_attr" ] && [ "$temp_attr" -gt 0 ] && [ "$temp_attr" -lt 150 ]; then
        echo "$temp_attr"
        return 0
    fi
    
    # 2. Ищем в строке с Temperature (NVMe диски)
    temp_line=$(echo "$smart_info" | grep -i "temperature" | grep -E "[0-9]+" | head -1)
    if [ -n "$temp_line" ]; then
        temp_value=$(echo "$temp_line" | grep -oE "[0-9]{1,3}" | head -1)
        if [ -n "$temp_value" ] && [ "$temp_value" -gt 0 ] && [ "$temp_value" -lt 150 ]; then
            echo "$temp_value"
            return 0
        fi
    fi
    
    # 3. Ищем в Current Drive Temperature
    temp_current=$(echo "$smart_info" | grep -i "current drive temperature" | grep -oE "[0-9]{1,3}" | head -1)
    if [ -n "$temp_current" ] && [ "$temp_current" -gt 0 ] && [ "$temp_current" -lt 150 ]; then
        echo "$temp_current"
        return 0
    fi
    
    # 4. Ищем в Airflow Temperature
    temp_airflow=$(echo "$smart_info" | grep -i "airflow temperature" | grep -oE "[0-9]{1,3}" | head -1)
    if [ -n "$temp_airflow" ] && [ "$temp_airflow" -gt 0 ] && [ "$temp_airflow" -lt 150 ]; then
        echo "$temp_airflow"
        return 0
    fi
    
    return 1
}

# Пробуем найти статус здоровья
if echo "$SMART_INFO" | grep -q "PASSED\|OK"; then
    STATUS="✅"
else
    STATUS="⚠️"
fi

# Пробуем найти модель диска
MODEL=$(echo "$SMART_INFO" | grep -E "Model|Product" | head -1 | cut -d: -f2- | sed 's/^ *//')

# Определяем тип диска
if echo "$SMART_INFO" | grep -q "SSD\|Solid State"; then
    DISK_TYPE="SSD"
    ICON="💾"
elif echo "$SMART_INFO" | grep -q "HDD\|Hard Disk"; then
    DISK_TYPE="HDD"
    ICON="💿"
else
    DISK_TYPE="Unknown"
    ICON="💽"
fi

# Получаем температуру
TEMPERATURE=$(get_temperature "$SMART_INFO")

# Вывод в строку меню
if [ -n "$TEMPERATURE" ]; then
    echo "${ICON}${STATUS} ${TEMPERATURE}°C ${usage_percent}%"
else
    echo "${ICON}${STATUS} ${usage_percent}%"
fi

echo "---"

# Основная информация
echo "📊 Состояние диска"
echo "---"
echo "Устройство: $DISK"

if [ -n "$MODEL" ]; then
    echo "Модель: $MODEL"
fi

echo "Тип: $DISK_TYPE"
echo "Статус: $STATUS"

if [ -n "$TEMPERATURE" ]; then
    echo "Температура: ${TEMPERATURE}°C"
    
    # Оценка температуры
    if [ "$TEMPERATURE" -gt 60 ]; then
        echo "→ ⚠️ Высокая температура!"
    elif [ "$TEMPERATURE" -lt 10 ]; then
        echo "→ ⚠️ Низкая температура"
    else
        echo "→ ✅ Нормальная температура"
    fi
else
    echo "Температура: не доступна"
fi

# Информация о использовании диска
echo "---"
echo "💾 Использование диска"

if [ -n "$usage_percent" ] && [ "$usage_percent" != "?" ]; then
    echo "Использовано: ${usage_percent}%"
    if [ -n "$used" ] && [ -n "$total" ]; then
        echo "Объем: $used из $total"
    fi
    
    # Цветовая индикация заполненности
    if [ "$usage_percent" -gt 90 ]; then
        echo "→ 🔴 Критическое заполнение!"
    elif [ "$usage_percent" -gt 80 ]; then
        echo "→ 🟡 Высокое заполнение"
    else
        echo "→ 🟢 Нормальное заполнение"
    fi
else
    echo "Данные о использовании: не доступны"
fi

## Ключевые атрибуты SMART

# Время работы
power_on_hours=$(echo "$SMART_INFO" | grep "^ *9 " | awk '{print $10}')
if [ -n "$power_on_hours" ]; then
    echo "---"
    echo "🔍 Ключевые параметры SMART:"
    echo "• Время работы: $power_on_hours часов"
fi

# Циклы включения
power_cycles=$(echo "$SMART_INFO" | grep "^ *12 " | awk '{print $10}')
if [ -n "$power_cycles" ]; then
    echo "• Циклы включения: $power_cycles"
fi

# Перераспределенные сектора
reallocated=$(echo "$SMART_INFO" | grep "^ *5 " | awk '{print $10}')
if [ -n "$reallocated" ]; then
    if [ "$reallocated" -eq 0 ]; then
        echo "• Перераспределенные сектора: $reallocated (отлично)"
    else
        echo "• Перераспределенные сектора: $reallocated"
    fi
fi

# Для SSD: оставшийся ресурс
ssd_life_left=$(echo "$SMART_INFO" | grep "^ *202 " | awk '{print $10}')
if [ -n "$ssd_life_left" ]; then
    echo "• Оставшийся ресурс: ${ssd_life_left}%"
fi

#echo "---"
#echo "🔄 Обновить | refresh=true"