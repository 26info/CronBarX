#!/bin/bash
# Network Monitor - CronBarX

get_network_info() {
    local interface=$(route get default | grep interface | awk '{print $2}')
    local ip_address=$(ipconfig getifaddr $interface)
    local network_name=$(networksetup -getairportnetwork $interface | awk -F': ' '{print $2}')
    local upload_speed=$(netstat -bi | grep $interface | awk '{print $7}' | tail -1)
    local download_speed=$(netstat -bi | grep $interface | awk '{print $10}' | tail -1)
    
    echo "$interface:$ip_address:$network_name:$upload_speed:$download_speed"
}

IFS=':' read -r interface ip_address network_name upload download <<< "$(get_network_info)"

echo "🌐 $network_name"
echo "---"
echo "📡 Сеть: $network_name"
echo "🔌 Интерфейс: $interface"
echo "📍 IP-адрес: $ip_address"
echo "📤 Отправлено: $upload bytes"
echo "📥 Получено: $download bytes"
echo "---"
echo "🔄 Обновить | refresh=true"
echo "🔍 Сетевые утилиты | shell=open -a \"Network Utility\""