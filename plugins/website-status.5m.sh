#!/bin/bash
# <xbar.title>Site Status</xbar.title>
# <xbar.author>Serg Cuc</xbar.author>
# <xbar.desc>Check if websites are up</xbar.desc>

sites=(
  "https://www.mxgraphics.ru|Наклейки"
  "https://www.oberegi-runi.ru|Обереги"
  "http://www.mx-print.ru|Интерьерная"
)

has_errors=false

# Сначала проверяем все сайты
for site_info in "${sites[@]}"; do
  url="${site_info%|*}"
  keyword="${site_info#*|}"
  
  # Проверяем HTTP статус
  code=$(curl -s -k -o /dev/null -w "%{http_code}" --max-time 5 "$url")
  
  # Если статус 200, проверяем наличие ключевого слова в первых 5КБ
  if [ "$code" = "200" ]; then
    if ! curl -s -k --max-time 5 "$url" | head -c 5120 | grep -q -i "$keyword"; then
      has_errors=true
    fi
  else
    has_errors=true
  fi
  
  sleep 1
done

# Потом показываем статус в баре
if [ "$has_errors" = true ]; then
  echo "🌐 ERROR"
else
  echo "🌐 OK"
fi

echo "---"

# Детальная информация в выпадающем меню
for site_info in "${sites[@]}"; do
  url="${site_info%|*}"
  keyword="${site_info#*|}"
  
  code=$(curl -s -k -o /dev/null -w "%{http_code}" --max-time 5 "$url")
  
  if [ "$code" = "200" ]; then
    if curl -s -k --max-time 5 "$url" | head -c 5120 | grep -q -i "$keyword"; then
      echo "✅ $url"
    else
      echo "⚠️  $url (no keyword: $keyword)"
    fi
  else
    echo "❌ $url (code: $code)"
  fi
done