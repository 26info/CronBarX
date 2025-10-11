#!/bin/bash
# VPN Status Monitor - CronBarX Plugin
# Checks VPN connection status via system proxy settings

# Проверяем включен ли системный прокси
if scutil --proxy | grep -q "Enable : 1"; then
    echo "🛡️ VPN"
    echo "---"
    echo "Подключение через VPN | color=green"
else
    echo "🌐 DIRECT" 
    echo "---"
    echo "Прямое подключение | color=red"
fi