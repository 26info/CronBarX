#!/bin/bash

# =============================================================================
# Repository Version Checker for CronBarX / Проверка версий репозиториев для CronBarX
# =============================================================================
#
# ENGLISH:
# Monitors latest versions of software from GitHub repositories with smart caching.
# Displays current versions and provides quick access to release pages.
#
# РУССКИЙ:
# Отслеживает последние версии программ из GitHub репозиториев с умным кэшированием.
# Показывает текущие версии и предоставляет быстрый доступ к страницам релизов.
#
# FEATURES / ОСОБЕННОСТИ:
# - 🚀 Fast version checking with caching / Быстрая проверка версий с кэшированием
# - ⚡ Smart cache (1 hour TTL) / Умный кэш (время жизни 1 час)
# - 📝 Easy URL management via config file / Простое управление URL через файл конфигурации
# - 🔄 One-click refresh / Обновление в один клик
# - 🌐 Direct links to releases / Прямые ссылки на релизы
# - 🛡️ Error handling for failed checks / Обработка ошибок при сбоях проверки
#
# CONFIGURATION / КОНФИГУРАЦИЯ:
# - Config file: ~/.cronbarx_repos.txt
# - Cache directory: ~/.cronbarx_cache/
# - Default URLs included: CronBarX, Homebrew, Xray-core
#
# USAGE / ИСПОЛЬЗОВАНИЕ:
# Add to CronBarX and click to view latest versions / Добавить в CronBarX и кликать для просмотра версий
# =============================================================================

CONFIG_FILE="$HOME/.cronbarx_repos.txt"
CACHE_DIR="$HOME/.cronbarx_cache"
CACHE_FILE="$CACHE_DIR/repo_versions.cache"
CACHE_TTL=3600  # 1 hour in seconds

# Create cache directory
init_cache() {
    mkdir -p "$CACHE_DIR"
}

# Default URLs if config doesn't exist
init_default_urls() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
https://github.com/26info/CronBarX/releases
https://github.com/Homebrew/brew/releases
https://github.com/XTLS/Xray-core/releases
EOF
    fi
}

# Check if cache is valid
is_cache_valid() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 1
    fi
    
    local cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    [ "$cache_age" -lt "$CACHE_TTL" ]
}

# Read from cache or fetch fresh data
get_cached_data() {
    if is_cache_valid; then
        cat "$CACHE_FILE"
    else
        fetch_fresh_data
    fi
}

# Fetch fresh data and cache it
fetch_fresh_data() {
    local temp_file=$(mktemp)
    
    while read -r url; do
        # Skip empty lines and comments
        if [[ -n "$url" && "$url" != \#* ]]; then
            local repo_name=$(get_repo_name "$url")
            local version=$(get_latest_version "$url")
            echo "$repo_name|$version|$url"
        fi
    done < "$CONFIG_FILE" > "$temp_file"
    
    mv "$temp_file" "$CACHE_FILE"
    cat "$CACHE_FILE"
}

# Extract repo name from URL
get_repo_name() {
    local url="$1"
    echo "$url" | sed -E 's|https://github.com/([^/]+)/([^/]+)/releases|\1/\2|'
}

# Get latest version from release URL
get_latest_version() {
    local url="$1"
    
    # Extract version from GitHub releases page
    local version=$(curl -s --connect-timeout 5 "$url" | grep -oE 'releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f3)
    
    if [ -n "$version" ]; then
        echo "$version"
    else
        echo "unknown"
    fi
}

# Main menu
main_menu() {
    init_cache
    init_default_urls
    
    echo "📦 Versions"
    echo "---"
    
    # Show cached data immediately
    while IFS='|' read -r repo_name version url; do
        if [ "$version" != "unknown" ]; then
            echo "$repo_name: $version | href=$url"
        else
            echo "$repo_name: failed | color=red href=$url"
        fi
    done < <(get_cached_data)
    
    echo "---"
    echo "✏️ Edit URLs | shell=open -t $CONFIG_FILE refresh=true"
    echo "🗑️ Clear Cache | shell=rm -f $CACHE_FILE refresh=true"
}

# Force refresh
force_refresh() {
    rm -f "$CACHE_FILE"
    echo "✅ Cache cleared"
}

case "$1" in
    "_refresh")
        force_refresh
        ;;
    *)
        main_menu
        ;;
esac