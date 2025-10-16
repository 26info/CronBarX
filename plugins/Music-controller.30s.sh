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
echo "⏮ Предыдущий трек | shell=\"$0\" param1=\"prev\" refresh=true"
echo "⏯ Пауза/Воспр. | shell=\"$0\" param1=\"playpause\" refresh=true"
echo "⏭ Следующий трек | shell=\"$0\" param1=\"next\" refresh=true"
echo "---"
echo "🔊 Громкость + | shell=\"$0\" param1=\"volup\" refresh=true"
echo "🔈 Громкость - | shell=\"$0\" param1=\"voldown\" refresh=true"
echo "🔇 Выкл. звук | shell=\"$0\" param1=\"mute\" refresh=true"
echo "---"
echo "ℹ️ Работает с любым плеером"
echo "🔄 Обновить | refresh=true"

case "${1}" in
    "prev") send_media_key "113" ;; # F7 - предыдущий трек
    "playpause") send_media_key "107" ;; # F8 - пауза/воспроизведение
    "next") send_media_key "114" ;; # F9 - следующий трек
    "volup") osascript -e "set volume output volume (output volume of (get volume settings) + 10)" ;;
    "voldown") osascript -e "set volume output volume (output volume of (get volume settings) - 10)" ;;
    "mute") osascript -e "set volume output volume 0" ;;
esac
