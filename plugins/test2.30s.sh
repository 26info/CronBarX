#!/bin/bash
if [ "$1" = "view" ]; then
    echo "📁 Просмотр: $2"
    echo "---"
    echo "◀️ Назад | shell=\"$0\" terminal=false"
elif [ "$1" = "settings" ]; then
    echo "⚙️ Настройки"
    echo "---"
    echo "◀️ Назад | shell=\"$0\" terminal=false"
else
    echo "🏠 Главная"
    echo "---"
    echo "📁 Просмотр | shell=\"$0\" param1=view param2=documents terminal=false"
    echo "⚙️ Настройки | shell=\"$0\" param1=settings terminal=false"
    echo "---"
    echo "🔄 Обновить | refresh=true"
fi
