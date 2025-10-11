#!/bin/bash
# WiFi Status - CronBarX

WIFINAME=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
WIFIINFO=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)

echo "📶 $WIFINAME"
echo "---"
echo "WiFi: $WIFINAME"
echo "Информация о сети"
echo "$WIFIINFO"
echo "-- Открыть настройки сети | shell=open x-apple.systempreferences:com.apple.preference.network"