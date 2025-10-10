#!/bin/bash

# VLESS Client Status Monitor - CronBarX Plugin
# Monitors connection status for VLESS Client macOS application
# Provides real-time status, connection testing, and configuration management
# Main application: https://github.com/26info/VLESS-Client-macOS
# Save as CronBarX plugin with .5s.sh extension for 5-second updates

# Configuration
PID_FILE="/tmp/xray-embedded.pid"
LOG_FILE="/tmp/xray-embedded.log"
CONFIG_DIR="$HOME/.vless-client"
VLESS_URL_FILE="$CONFIG_DIR/vless-url.txt"

# Check if xray is running
is_running() {
    [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null
}

# Get status icon and text
get_status_display() {
    if is_running; then
        echo "✅ VLESS"
    else
        echo "🔴 VLESS"
    fi
}

# Test connection (simplified)
test_connection() {
    if ! is_running; then
        osascript -e 'display notification "Xray не запущен" with title "VLESS Test"'
        return
    fi
    
    # Простой тест через ifconfig.me
    local ip=$(curl --socks5 127.0.0.1:1080 -s --max-time 5 http://ifconfig.me 2>/dev/null)
    
    if [ -n "$ip" ]; then
        osascript -e "display notification \"Внешний IP: $ip\" with title \"VLESS Connection Test\""
    else
        osascript -e 'display notification "Не удалось получить IP" with title "VLESS Test"'
    fi
}

# Change URL
change_url() {
    current_url="vless://"
    if [ -f "$VLESS_URL_FILE" ]; then
        current_url=$(head -n1 "$VLESS_URL_FILE")
    fi
    
    new_url=$(osascript -e "text returned of (display dialog \"Введите VLESS URL:\" default answer \"$current_url\" buttons {\"Cancel\", \"OK\"} default button \"OK\")")
    
    if [ -n "$new_url" ] && [[ "$new_url" =~ ^vless:// ]]; then
        mkdir -p "$CONFIG_DIR"
        echo "$new_url" > "$VLESS_URL_FILE"
        osascript -e 'display notification "URL обновлен" with title "VLESS"'
    fi
}

# Show current config info
get_config_info() {
    if [ -f "$VLESS_URL_FILE" ]; then
        local url=$(head -n1 "$VLESS_URL_FILE" 2>/dev/null | cut -c1-30)
        if [ -n "$url" ]; then
            echo "Config: ${url}..."
        else
            echo "Config: No URL"
        fi
    else
        echo "Config: Not set"
    fi
}

# Main CronBarX output
echo "$(get_status_display)"
echo "---"

if is_running; then
    echo "✅ Connected"
    echo "Xray is running"
else
    echo "❌ Disconnected" 
    echo "Xray not running"
fi

echo "---"

# Connection test - встроенная функция
echo "Тест подключения | shell=/bin/bash -c 'source \"$0\"; test_connection'"

echo "---"

# Configuration info
echo "⚙️ $(get_config_info)"

if [ -f "$VLESS_URL_FILE" ]; then
    echo "-- Изменить URL | shell=/bin/bash -c 'source \"$0\"; change_url'"
fi

echo "-- Открыть папку конфигурации | shell=open \"$CONFIG_DIR\""

echo "---"

# Logs and info
echo "📊 Системная информация"
echo "-- Просмотр логов | shell=open \"$LOG_FILE\""
echo "-- PID: $(cat \"$PID_FILE\" 2>/dev/null || echo N/A)"

echo "---"

echo "ℹ️ О VLESS Client macOS | shell=open https://github.com/26info/VLESS-Client-macOS"

echo "---"

echo "🔄 Обновить | refresh=true"
