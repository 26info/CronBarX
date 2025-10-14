#!/bin/bash
# Universal Disk Health Monitor - CronBarX

# Конфигурация
CONFIG_FILE="/tmp/disk_monitor_selected_disk"

# Функция для сохранения выбранного диска
save_selected_disk() {
    local disk="$1"
    echo "$disk" > "$CONFIG_FILE"
}

# Функция для загрузки выбранного диска
load_selected_disk() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE" 2>/dev/null
    else
        echo ""
    fi
}

# Функция для поиска smartctl
find_smartctl() {
    local paths=(
        "/usr/local/sbin/smartctl"
        "/usr/local/bin/smartctl"
        "/opt/homebrew/sbin/smartctl"
        "/opt/homebrew/bin/smartctl"
        "/usr/sbin/smartctl"
        "/usr/bin/smartctl"
        "/opt/local/sbin/smartctl"
        "/opt/local/bin/smartctl"
    )
    
    for path in "${paths[@]}"; do
        if [ -x "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    local which_path=$(which smartctl 2>/dev/null)
    if [ -n "$which_path" ] && [ -x "$which_path" ]; then
        echo "$which_path"
        return 0
    fi
    
    return 1
}

# Функция для поиска дисков
find_disks() {
    local disks=()
    
    if command -v diskutil >/dev/null 2>&1; then
        while IFS= read -r disk; do
            if [[ "$disk" =~ /dev/disk[0-9]+ ]]; then
                if ! diskutil info "$disk" 2>/dev/null | grep -q "Virtual\|CD-ROM\|DVD"; then
                    disks+=("$disk")
                fi
            fi
        done < <(diskutil list | grep "/dev/disk" | awk '{print $1}')
    fi
    
    if [ ${#disks[@]} -eq 0 ]; then
        for disk in /dev/disk*; do
            if [[ "$disk" =~ /dev/disk[0-9]+$ ]]; then
                disks+=("$disk")
            fi
        done
    fi
    
    [ -e "/dev/sda" ] && disks+=("/dev/sda")
    [ -e "/dev/sdb" ] && disks+=("/dev/sdb")
    
    printf '%s\n' "${disks[@]}"
}

# Функция для проверки поддержки SMART
check_smart_support() {
    local disk="$1"
    local smartctl="$2"
    
    if sudo "$smartctl" -i "$disk" 2>/dev/null | grep -q "SMART support is:.*Available"; then
        return 0
    fi
    
    if sudo "$smartctl" -a "$disk" 2>/dev/null | grep -q "START OF INFORMATION SECTION"; then
        return 0
    fi
    
    if sudo "$smartctl" -H "$disk" 2>/dev/null | grep -q "SMART overall-health"; then
        return 0
    fi
    
    return 1
}

# Функция для определения типа диска
get_disk_type() {
    local smart_info="$1"
    
    if echo "$smart_info" | grep -q "NVMe"; then
        echo "NVMe SSD"
    elif echo "$smart_info" | grep -q "SSD\|Solid State"; then
        echo "SATA SSD"
    elif echo "$smart_info" | grep -q "HDD\|Hard Disk"; then
        echo "HDD"
    elif echo "$smart_info" | grep -q "Rotation Rate:.*Solid State"; then
        echo "SSD"
    elif echo "$smart_info" | grep -q "Rotation Rate:"; then
        echo "HDD"
    else
        echo "Unknown"
    fi
}

# Функция для получения температуры
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

# Функция для получения здоровья диска
get_health_status() {
    local smart_info="$1"
    
    if echo "$smart_info" | grep -q "SMART overall-health.*PASSED"; then
        echo "PASSED"
    elif echo "$smart_info" | grep -q "SMART Health Status.*OK"; then
        echo "PASSED"
    elif echo "$smart_info" | grep -q "SMART overall-health"; then
        echo "FAILED"
    else
        echo "UNKNOWN"
    fi
}

# Функция для извлечения числового значения атрибута по ID
get_attr_value() {
    local smart_info="$1"
    local attr_id="$2"
    
    local value=$(echo "$smart_info" | grep "^ *$attr_id " | awk '{
        if ($NF ~ /^\(/) {
            print $(NF-1)
        } else {
            print $NF
        }
    }')
    
    echo "$value"
}

# Функция для получения времени работы в читаемом формате
get_power_on_hours() {
    local hours="$1"
    if [ -n "$hours" ]; then
        local days=$((hours / 24))
        local months=$((days / 30))
        local years=$((months / 12))
        
        if [ $years -gt 0 ]; then
            echo "$hours часов (~${years} лет ${months} месяцев)"
        elif [ $months -gt 0 ]; then
            echo "$hours часов (~${months} месяцев ${days} дней)"
        elif [ $days -gt 0 ]; then
            echo "$hours часов (~${days} дней)"
        else
            echo "$hours часов"
        fi
    else
        echo "неизвестно"
    fi
}

# Функция для преобразования байт в читаемый формат
format_bytes() {
    local bytes="$1"
    if [ -n "$bytes" ]; then
        if [ "$bytes" -gt 1099511627776 ]; then
            echo "$(echo "scale=2; $bytes / 1099511627776" | bc) TB"
        elif [ "$bytes" -gt 1073741824 ]; then
            echo "$(echo "scale=2; $bytes / 1073741824" | bc) GB"
        elif [ "$bytes" -gt 1048576 ]; then
            echo "$(echo "scale=2; $bytes / 1048576" | bc) MB"
        else
            echo "$bytes bytes"
        fi
    else
        echo "неизвестно"
    fi
}

# Функция для получения описания атрибута по ID
get_attr_description() {
    local attr_id="$1"
    
    case "$attr_id" in
        "1") echo "Частота ошибок чтения" ;;
        "5") echo "Перераспределенные блоки NAND" ;;
        "9") echo "Время работы" ;;
        "12") echo "Циклы включения" ;;
        "171") echo "Ошибки программирования" ;;
        "172") echo "Ошибки стирания" ;;
        "173") echo "Среднее количество стираний блоков" ;;
        "174") echo "Неожиданные отключения питания" ;;
        "180") echo "Резервные блоки NAND" ;;
        "183") echo "Снижение скорости SATA" ;;
        "184") echo "Коррекция ошибок" ;;
        "187") echo "Некорректируемые ошибки" ;;
        "196") echo "События перераспределения" ;;
        "197") echo "Ожидающие ошибки ECC" ;;
        "198") echo "Оффлайн некорректируемые" ;;
        "199") echo "Ошибки CRC интерфейса" ;;
        "202") echo "Оставшийся ресурс" ;;
        "206") echo "Частота ошибок записи" ;;
        "210") echo "Успешные восстановления RAIN" ;;
        "246") echo "Всего записано данных" ;;
        "247") echo "Страниц записано хостом" ;;
        "248") echo "Страниц записано контроллером" ;;
        "194") echo "Температура" ;;
        *) echo "Атрибут $attr_id" ;;
    esac
}

# Функция для получения ключевых атрибутов с расшифровкой
get_key_attributes() {
    local smart_info="$1"
    local disk_type="$2"
    
    # Определяем ключевые атрибуты в зависимости от типа диска
    case "$disk_type" in
        "NVMe SSD"|"SATA SSD")
            key_attrs="9 12 5 173 180 174 199 246 194"
            ;;
        "HDD")
            key_attrs="9 12 5 1 7 199 194"
            ;;
        *)
            key_attrs="9 12 5 194"
            ;;
    esac
    
    local result=""
    
    for attr_id in $key_attrs; do
        local raw_value=$(get_attr_value "$smart_info" "$attr_id")
        local description=$(get_attr_description "$attr_id")
        
        if [ -n "$raw_value" ] && [ -n "$description" ]; then
            case "$attr_id" in
                "9")
                    local readable_hours=$(get_power_on_hours "$raw_value")
                    result+="• ${description}: ${readable_hours}\n"
                    ;;
                "194")
                    result+="• ${description}: ${raw_value}°C\n"
                    ;;
                "246")
                    local bytes_written=$((raw_value * 512))
                    local readable_written=$(format_bytes "$bytes_written")
                    result+="• ${description}: ${readable_written}\n"
                    ;;
                "5"|"171"|"172"|"174"|"180"|"183"|"184"|"187"|"196"|"197"|"198"|"199"|"206"|"210")
                    if [ "$raw_value" -eq 0 ]; then
                        result+="• ${description}: ${raw_value} (отлично)\n"
                    else
                        result+="• ${description}: ${raw_value}\n"
                    fi
                    ;;
                "173")
                    if [ "$raw_value" -lt 10 ]; then
                        result+="• ${description}: ${raw_value} (очень низкий износ)\n"
                    elif [ "$raw_value" -lt 50 ]; then
                        result+="• ${description}: ${raw_value} (низкий износ)\n"
                    else
                        result+="• ${description}: ${raw_value} (высокий износ)\n"
                    fi
                    ;;
                *)
                    result+="• ${description}: ${raw_value}\n"
                    ;;
            esac
        fi
    done
    
    echo -e "$result"
}

# Функция для получения заполненности диска в %
get_disk_usage() {
    local disk_device="$1"
    
    local mount_point=$(mount | grep "$(basename "$disk_device")" | awk '{print $3}' | head -1)
    
    if [ -z "$mount_point" ]; then
        mount_point=$(diskutil info "$disk_device" 2>/dev/null | grep "Mount Point" | cut -d: -f2 | sed 's/^ *//')
    fi
    
    if [ -n "$mount_point" ] && [ "$mount_point" != "Not applicable" ]; then
        local usage=$(df -h "$mount_point" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//')
        echo "$usage"
    else
        echo ""
    fi
}

# Функция для получения имени диска для отображения
get_disk_display_name() {
    local disk="$1"
    local smartctl="$2"
    
    local model=$(sudo "$smartctl" -i "$disk" 2>/dev/null | grep -E "(Device Model|Model Number|Product:)" | head -1 | cut -d: -f2- | sed 's/^ *//')
    
    local mount_point=$(diskutil info "$disk" 2>/dev/null | grep "Mount Point" | cut -d: -f2 | sed 's/^ *//')
    
    local display_name=""
    
    if [ -n "$model" ]; then
        display_name="$model"
    else
        display_name="$(basename "$disk")"
    fi
    
    if [ -n "$mount_point" ] && [ "$mount_point" != "Not applicable" ]; then
        display_name="$display_name ($mount_point)"
    fi
    
    echo "$display_name"
}

# Функция для получения списка дисков с поддержкой SMART
get_smart_disks() {
    local smartctl="$1"
    local disks=()
    
    for disk in "${DISKS[@]}"; do
        if check_smart_support "$disk" "$smartctl"; then
            disks+=("$disk")
        fi
    done
    
    printf '%s\n' "${disks[@]}"
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

# Ищем smartctl
SMARTCTL=$(find_smartctl)

if [ -z "$SMARTCTL" ]; then
    echo "💽 ?"
    echo "---"
    echo "smartctl не найден"
    echo "---"
    echo "Установите smartmontools:"
    echo "• Homebrew: brew install smartmontools"
    echo "• MacPorts: sudo port install smartmontools"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Ищем диски
DISKS=()
while IFS= read -r disk; do
    DISKS+=("$disk")
done < <(find_disks)

if [ ${#DISKS[@]} -eq 0 ]; then
    echo "💽 ?"
    echo "---"
    echo "Диски не найдены"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Получаем все диски с поддержкой SMART
SMART_DISKS=()
while IFS= read -r disk; do
    SMART_DISKS+=("$disk")
done < <(get_smart_disks "$SMARTCTL")

if [ ${#SMART_DISKS[@]} -eq 0 ]; then
    echo "💽 ?"
    echo "---"
    echo "Диски со SMART не найдены"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Выбираем диск (из сохраненного или первый доступный)
SAVED_DISK=$(load_selected_disk)
SELECTED_DISK="${SMART_DISKS[0]}"

# Проверяем сохраненный диск на доступность
if [ -n "$SAVED_DISK" ] && [ -e "$SAVED_DISK" ]; then
    for disk in "${SMART_DISKS[@]}"; do
        if [ "$disk" = "$SAVED_DISK" ]; then
            SELECTED_DISK="$SAVED_DISK"
            break
        fi
    done
fi

# Обработка выбора диска через меню
case "$1" in
    "_select_disk")
        if [ -n "$2" ] && [ -e "$2" ]; then
            save_selected_disk "$2"
            SELECTED_DISK="$2"
        fi
        ;;
esac

# Проверяем доступность выбранного диска
if [ ! -e "$SELECTED_DISK" ]; then
    echo "💽 ?"
    echo "---"
    echo "Диск $SELECTED_DISK недоступен"
    echo "---"
    echo "Выберите другой диск:"
    for disk in "${SMART_DISKS[@]}"; do
        disk_name=$(get_disk_display_name "$disk" "$SMARTCTL")
        echo "○ $disk_name | shell=\"$0\" _select_disk $disk"
    done
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Получаем информацию о диске
SMART_INFO=$(sudo "$SMARTCTL" -a "$SELECTED_DISK" 2>/dev/null)

if ! echo "$SMART_INFO" | grep -q "START OF INFORMATION SECTION"; then
    echo "💽 ?"
    echo "---"
    echo "SMART данные недоступны"
    echo "Диск: $SELECTED_DISK"
    echo "---"
    echo "🔄 Обновить | refresh=true"
    exit 0
fi

# Анализируем данные
DISK_TYPE=$(get_disk_type "$SMART_INFO")
HEALTH_STATUS=$(get_health_status "$SMART_INFO")
TEMPERATURE=$(get_temperature "$SMART_INFO")

# Определяем иконку и статус
case "$DISK_TYPE" in
    "NVMe SSD") ICON="💾" ;;
    "SATA SSD") ICON="🔶" ;;
    "HDD") ICON="💿" ;;
    *) ICON="💽" ;;
esac

case "$HEALTH_STATUS" in
    "PASSED") STATUS_ICON="✅" ;;
    "FAILED") STATUS_ICON="❌" ;;
    *) STATUS_ICON="⚠️" ;;
esac

# Вывод в строку меню
DISK_USAGE=$(get_disk_usage "$SELECTED_DISK")
if [ -n "$DISK_USAGE" ]; then
    DISK_USAGE_PERCENT="${DISK_USAGE}% "
fi
DISPLAY_NAME=$(get_disk_display_name "$SELECTED_DISK" "$SMARTCTL")
if [ -n "$TEMPERATURE" ]; then
    echo "💽${STATUS_ICON} ${DISK_USAGE_PERCENT}${TEMPERATURE}°C"
else
    echo "💽 $(basename "$SELECTED_DISK") ${STATUS_ICON}"
fi

echo "---"

# Меню выбора диска
echo "💽 Диски ($(basename "$SELECTED_DISK"))"
echo "---"
echo "🎯 Выбор диска для анализа:"

for disk in "${SMART_DISKS[@]}"; do
    disk_name=$(get_disk_display_name "$disk" "$SMARTCTL")
    if [ "$disk" = "$SELECTED_DISK" ]; then
        echo "✓ $disk_name"
    else
        echo "○ $disk_name | shell=\"$0\" _select_disk $disk"
    fi
done

echo "---"

# Основная информация
echo "💽 Состояние диска: $(basename "$SELECTED_DISK")"
echo "---"
echo "Устройство: $SELECTED_DISK"
echo "Тип: $DISK_TYPE"
echo "Здоровье: $HEALTH_STATUS $STATUS_ICON"

if [ -n "$TEMPERATURE" ]; then
    echo "Температура: ${TEMPERATURE}°C"
    
    if [ "$TEMPERATURE" -gt 60 ]; then
        echo "→ ⚠️ Высокая температура!"
    elif [ "$TEMPERATURE" -lt 10 ]; then
        echo "→ ⚠️ Низкая температура"
    else
        echo "→ ✅ Нормальная температура"
    fi
fi

# Заполненность диска
if [ -n "$DISK_USAGE" ]; then
    if [ "$DISK_USAGE" -lt 70 ]; then
        echo "Заполненность: ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -lt 85 ]; then
        echo "Заполненность: ${DISK_USAGE}%"
    else
        echo "Заполненность: ${DISK_USAGE}%"
    fi
fi

# Ключевые атрибуты
echo "---"
echo "📊 Ключевые параметры:"

KEY_ATTRS=$(get_key_attributes "$SMART_INFO" "$DISK_TYPE")
if [ -n "$KEY_ATTRS" ]; then
    echo -e "$KEY_ATTRS"
else
    echo "• Нет данных"
fi

# Действия
echo "---"
echo "📊 Действия:"
echo "Полный отчет (терминал) | shell=\"$0\" _show_full_report_terminal"
echo "Базовая информация | shell=\"$0\" _show_basic_info"

echo "---"
echo "🔄 Обновить | refresh=true"

# Обработка команд
case "$1" in
    "_select_disk")
        # Уже обработано выше
        ;;
    "_show_full_report_terminal")
        osascript -e 'tell application "Terminal" to activate' -e 'delay 0.5'
        osascript -e "tell application \"Terminal\" to do script \"sudo $SMARTCTL -a $SELECTED_DISK\""
        ;;
    "_show_basic_info")
        BASIC_INFO=$(sudo "$SMARTCTL" -i "$SELECTED_DISK")
        osascript -e "display dialog \"Базовая информация:\n\n$BASIC_INFO\" buttons {\"OK\"}"
        ;;
esac
