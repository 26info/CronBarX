#!/bin/bash
# CronBarX Latest Version - CronBarX Plugin
# Shows the latest version available on GitHub

GITHUB_REPO="https://github.com/26info/CronBarX/releases"

get_latest_version() {
    # Get the latest release version from GitHub
    local latest_version=$(curl -s https://api.github.com/repos/26info/CronBarX/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -n "$latest_version" ]; then
        echo "$latest_version"
    else
        # Fallback: check the releases page
        latest_version=$(curl -s "https://github.com/26info/CronBarX/releases" | grep -oE 'releases/tag/v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f3)
        echo "$latest_version"
    fi
}

main() {
    local latest_version=$(get_latest_version)
    
    if [ -n "$latest_version" ] && [ "$latest_version" != "unknown" ]; then
        echo "🔄 CronBarX $latest_version"
        echo "---"
        echo "Последняя версия CronBarX $latest_version | color=green"
        echo "---"
        echo "📦 Скачать | shell=open $GITHUB_REPO"
        echo "🐛 Репозиторий | shell=open https://github.com/26info/CronBarX"
    else
        echo "🔄 CronBarX"
        echo "---"
        echo "Не удалось проверить версию"
        echo "---"
        echo "📦 Проверить вручную | shell=open $GITHUB_REPO"
    fi
}

main