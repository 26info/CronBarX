#!/bin/bash

# Gatekeeper Status Monitor - CronBarX Plugin
# Fixed version with working user feedback

# Get security statuses
GATEKEEPER_STATUS=$(spctl --status 2>/dev/null)
SIP_STATUS=$(csrutil status 2>/dev/null | head -1)
ALLOWED_APPS=$(spctl --list 2>/dev/null | wc -l | tr -d ' ')
ALLOWED_APPS_COUNT=$((ALLOWED_APPS - 1))

# Determine icon and status text
if [ "$GATEKEEPER_STATUS" = "assessments enabled" ]; then
    ICON="🛡️"
    GK_STATUS_TEXT="✅ Включен"
    GK_ACTION="-- Отключить Gatekeeper | shell=sudo spctl --master-disable; osascript -e 'display notification \"Gatekeeper отключен\" with title \"Системная безопасность\"'"
else
    ICON="🔓" 
    GK_STATUS_TEXT="❌ Выключен"
    GK_ACTION="-- Включить Gatekeeper | shell=sudo spctl --master-enable; osascript -e 'display notification \"Gatekeeper включен\" with title \"Системная безопасность\"'"
fi

# Parse SIP status
if echo "$SIP_STATUS" | grep -q "enabled"; then
    SIP_STATUS_TEXT="✅ Включен"
else
    SIP_STATUS_TEXT="❌ Выключен"
fi

# Main display
echo "$ICON"
echo "---"

# Security Status Section
echo "🔒 Статус безопасности"
echo "-- Gatekeeper: $GK_STATUS_TEXT"
echo "-- SIP: $SIP_STATUS_TEXT"
echo "-- Разрешено приложений: $ALLOWED_APPS_COUNT"

echo "---"

# Gatekeeper Management Section
echo "🛠️ Управление Gatekeeper"
echo "$GK_ACTION"
echo "-- Сбросить настройки | shell=sudo spctl --reset-default; osascript -e 'display notification \"Настройки Gatekeeper сброшены\" with title \"Системная безопасность\"'"
echo "-- Разрешить Terminal | shell=sudo spctl developer-mode enable-terminal; osascript -e 'display notification \"Режим разработчика включен\" with title \"Terminal\"'"

echo "---"

# Application Management Section  
echo "📱 Управление приложениями"
echo "-- Показать разрешенные приложения | shell=spctl --list | head -15 > /tmp/gatekeeper_allowed.txt; osascript -e 'display dialog \"Разрешенные приложения:\n\n\" & (do shell script \"cat /tmp/gatekeeper_allowed.txt\") buttons {\"OK\"} default button 1'"
echo "-- Проверить Applications | shell=for app in /Applications/*.app; do spctl --assess \"\$app\" 2>/dev/null && echo \"✅ \$app\" || echo \"❌ \$app\"; done | head -8 > /tmp/gatekeeper_check.txt; osascript -e 'display dialog \"Проверка приложений:\n\n\" & (do shell script \"cat /tmp/gatekeeper_check.txt\") buttons {\"OK\"} default button 1'"
echo "-- Проверить системные приложения | shell=for app in /System/Applications/*.app; do spctl --assess \"\$app\" 2>/dev/null && echo \"✅ \$app\" || echo \"❌ \$app\"; done | head -6 > /tmp/gatekeeper_system.txt; osascript -e 'display dialog \"Проверка системных приложений:\n\n\" & (do shell script \"cat /tmp/gatekeeper_system.txt\") buttons {\"OK\"} default button 1'"

echo "---"

# System Information Section
echo "📊 Системная информация"
echo "-- Показать детальный статус | shell=spctl --status > /tmp/gatekeeper_status.txt; csrutil status >> /tmp/gatekeeper_status.txt; osascript -e 'display dialog \"Детальный статус безопасности:\n\n\" & (do shell script \"cat /tmp/gatekeeper_status.txt\") buttons {\"OK\"} default button 1'"
echo "-- Проверить подпись Safari | shell=pkgutil --check-signature /Applications/Safari.app 2>/dev/null | head -12 > /tmp/safari_signature.txt; osascript -e 'display dialog \"Подпись Safari:\n\n\" & (do shell script \"cat /tmp/safari_signature.txt\") buttons {\"OK\"} default button 1'"
echo "-- Последние логи безопасности | shell=log show --predicate '\"subsystem == \\\"com.apple.security\\\"\"' --last 10m --info 2>/dev/null | tail -4 > /tmp/security_logs.txt; osascript -e 'display dialog \"Последние логи безопасности:\n\n\" & (do shell script \"cat /tmp/security_logs.txt\") buttons {\"OK\"} default button 1'"

echo "---"

# Quick Actions Section
echo "⚡ Быстрые действия"
echo "-- Открыть Настройки безопасности | shell=open x-apple.systempreferences:com.apple.preference.security"
echo "-- Открыть Файрволл | shell=open x-apple.systempreferences:com.apple.preference.security?Firewall"
echo "-- Открыть Конфиденциальность | shell=open x-apple.systempreferences:com.apple.preference.security?Privacy"

echo "---"

# Diagnostics Section
echo "🔧 Диагностика"
echo "-- Статус файрволла | shell=socketfilterfw --getglobalstate > /tmp/firewall_status.txt; osascript -e 'display dialog \"Статус файрволла:\n\n\" & (do shell script \"cat /tmp/firewall_status.txt\") buttons {\"OK\"} default button 1'"
echo "-- Приложения в Загрузках | shell=find ~/Downloads -name '*.app' -maxdepth 1 2>/dev/null > /tmp/downloads_list.txt; if [ ! -s /tmp/downloads_list.txt ]; then echo 'Приложений не найдено' > /tmp/downloads_list.txt; fi; osascript -e 'display dialog \"Приложения в папке Загрузки:\n\n\" & (do shell script \"cat /tmp/downloads_list.txt\") buttons {\"OK\"} default button 1'"
echo "-- Quarantine события | shell=sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 'SELECT datetime(LSQuarantineTimeStamp + 978307200, \"unixepoch\") as date, LSQuarantineAgentName FROM LSQuarantineEvent ORDER BY LSQuarantineTimeStamp DESC LIMIT 5;' 2>/dev/null > /tmp/quarantine_events.txt || echo 'База quarantine не найдена' > /tmp/quarantine_events.txt; osascript -e 'display dialog \"Последние quarantine события:\n\n\" & (do shell script \"cat /tmp/quarantine_events.txt\") buttons {\"OK\"} default button 1'"

echo "---"

# Quick Tests Section
echo "🧪 Быстрые тесты"
echo "-- Тест Gatekeeper | shell=spctl --assess /Applications/Calculator.app 2>/dev/null && osascript -e 'display notification \"Calculator.app: проверка пройдена ✅\" with title \"Gatekeeper Test\"' || osascript -e 'display notification \"Calculator.app: ошибка проверки ❌\" with title \"Gatekeeper Test\"'"
echo "-- Тест подписи | shell=codesign -dv /Applications/Calculator.app 2>&1 | head -6 > /tmp/calc_signature.txt; osascript -e 'display dialog \"Подпись Calculator.app:\n\n\" & (do shell script \"cat /tmp/calc_signature.txt\") buttons {\"OK\"} default button 1'"
echo "-- Системная информация | shell=sw_vers > /tmp/system_info.txt; system_profiler SPSoftwareDataType | grep 'System Version' | head -1 >> /tmp/system_info.txt; osascript -e 'display dialog \"Системная информация:\n\n\" & (do shell script \"cat /tmp/system_info.txt\") buttons {\"OK\"} default button 1'"

echo "---"

# Cleanup Section
echo "🧹 Очистка"
echo "-- Очистить временные файлы | shell=rm -f /tmp/gatekeeper_*.txt /tmp/security_*.txt /tmp/*_status.txt /tmp/*_signature.txt /tmp/*_logs.txt /tmp/*_info.txt /tmp/*_list.txt /tmp/*_events.txt /tmp/*_check.txt; osascript -e 'display notification \"Временные файлы очищены\" with title \"Очистка\"'"

echo "---"

echo "🔄 Обновить | refresh=true"