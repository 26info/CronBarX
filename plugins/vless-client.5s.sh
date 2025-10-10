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


# Main xbar output
echo "$(get_status_display)"
echo "---"

if is_running; then
    echo "✅ Connected | color=green"
    echo "Xray is running | color=green"
else
    echo "❌ Disconnected | color=red"
    echo "Xray not running | color=red"
fi

# Handle actions
case "${1}" in
    "test")
        result=$(test_connection)
        if [[ "$result" == *"|"* ]]; then
            IFS='|' read -r ip service_name <<< "$result"
            osascript -e "display notification \"IP: $ip\nService: $service_name\" with title \"VLESS Connection Test\""
        else
            osascript -e "display notification \"$result\" with title \"VLESS Connection Test\""
        fi
        ;;
    "change_url")
        current_url="vless://"
        if [ -f "$VLESS_URL_FILE" ]; then
            current_url=$(head -n1 "$VLESS_URL_FILE")
        fi
        
        new_url=$(osascript -e "text returned of (display dialog \"Enter VLESS URL:\" default answer \"$current_url\" buttons {\"Cancel\", \"OK\"} default button \"OK\")")
        
        if [ -n "$new_url" ] && [[ "$new_url" =~ ^vless:// ]]; then
            echo "$new_url" > "$VLESS_URL_FILE"
            osascript -e "display notification \"URL updated\" with title \"VLESS\""
        fi
        ;;
esac