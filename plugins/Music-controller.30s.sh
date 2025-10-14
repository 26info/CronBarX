#!/bin/bash
# Universal Media Keys Controller

send_media_key() {
    local key="$1"
    
    # Используем AppleScript для отправки медиа-клавиш
    osascript << EOF
tell application "System Events"
    key code $key
end tell
EOF
}

echo "🎵"
echo "---"
echo "Универсальные медиа-клавиши"
echo "---"
echo "⏮ Предыдущий трек | shell=\"$0\" prev refresh=true"
echo "⏯ Пауза/Воспр. | shell=\"$0\" playpause refresh=true"
echo "⏭ Следующий трек | shell=\"$0\" next refresh=true"
echo "---"
echo "🔊 Громкость + | shell=\"$0\" volup refresh=true" 
echo "🔈 Громкость - | shell=\"$0\" voldown refresh=true"
echo "---"
echo "ℹ️ Работает с любым плеером"

case "$1" in
    "prev") send_media_key "rewind" ;; # F7
    "playpause") send_media_key "play" ;; # F8  
    "next") send_media_key "fastforward" ;; # F9
    "volup") osascript -e "set volume output volume (output volume of (get volume settings) + 10)" ;;
    "voldown") osascript -e "set volume output volume (output volume of (get volume settings) - 10)" ;;
esac