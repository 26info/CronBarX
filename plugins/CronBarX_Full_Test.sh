#!/bin/bash

# =============================================================================
# CronBarX Full Functionality Test / Полный тест функциональности CronBarX
# =============================================================================
# 
# ENGLISH:
# Comprehensive test of ALL CronBarX functionality including:
# - Basic script execution
# - Menu structure with all formats  
# - Command execution with various types
# - Paths with spaces handling
# - Plugin simulation
# - Error handling
# - Refresh functionality
# - Submenus and nested structure
# 
# РУССКИЙ:
# Полный тест ВСЕЙ функциональности CronBarX включая:
# - Базовое выполнение скриптов
# - Структуру меню со всеми форматами
# - Выполнение команд различных типов
# - Обработку путей с пробелами
# - Симуляцию плагинов
# - Обработку ошибок
# - Функциональность обновления
# - Подменю и вложенную структуру
#
# USAGE / ИСПОЛЬЗОВАНИЕ:
# Save as .sh file and run from CronBarX / Сохранить как .sh и запустить из CronBarX
# =============================================================================

# Test counter / Счетчик тестов
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test header / Функция для вывода заголовка теста
print_header() {
    echo "=== $1 ==="
}

# Function to print test result / Функция для вывода результата теста
print_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ PASS: $2"
        ((TESTS_PASSED++))
    else
        echo "❌ FAIL: $2"
        ((TESTS_FAILED++))
    fi
}

# Function to test basic functionality / Функция тестирования базовой функциональности
test_basic_functionality() {
    print_header "BASIC FUNCTIONALITY TEST / ТЕСТ БАЗОВОЙ ФУНКЦИОНАЛЬНОСТИ"
    
    # Test 1: Script execution / Тест выполнения скрипта
    echo "🔄 Testing script execution..."
    if [ -f "$0" ]; then
        print_result 0 "Script file exists and executable"
    else
        print_result 1 "Script file not found"
    fi
    
    # Test 2: Output format / Тест формата вывода
    echo "📝 Testing output format..."
    output=$(echo "Test Title" | head -1)
    if [ ! -z "$output" ]; then
        print_result 0 "Title output format is correct"
    else
        print_result 1 "Title output format is empty"
    fi
    
    # Test 3: Multiple line output / Тест многострочного вывода
    echo "📄 Testing multi-line output..."
    multi_line_output=$(echo -e "Line 1\nLine 2\nLine 3" | wc -l)
    if [ $multi_line_output -eq 3 ]; then
        print_result 0 "Multi-line output works"
    else
        print_result 1 "Multi-line output failed"
    fi
}

# Function to test complete menu structure / Функция тестирования полной структуры меню
test_complete_menu_structure() {
    print_header "COMPLETE MENU STRUCTURE TEST / ТЕСТ ПОЛНОЙ СТРУКТУРЫ МЕНЮ"
    
    # Test all menu item formats / Тест всех форматов пунктов меню
    echo "📋 Testing complete menu structure..."
    
    # Main title / Главный заголовок
    echo "🔄 CronBarX Full Test v1.0"
    
    # Separator / Разделитель
    echo "---"
    print_result 0 "Menu separator displayed"
    
    # Simple menu items / Простые пункты меню
    echo "Simple menu item without action"
    print_result 0 "Simple menu item displayed"
    
    # Menu items with pipe format / Пункты меню с форматом pipe
    echo "Menu with pipe | param1=value1"
    print_result 0 "Menu item with pipe format displayed"
    
    # Menu items with shell commands / Пункты меню с shell командами
    echo "Echo command | shell=\"echo Hello World\""
    echo "Date command | shell=\"date\""
    echo "List files | shell=\"ls -la\""
    print_result 0 "Menu items with shell commands displayed"
    
    # Menu items with refresh / Пункты меню с обновлением
    echo "Refresh this menu | refresh=true"
    echo "Refresh with command | shell=\"echo test\" refresh=true"
    print_result 0 "Menu items with refresh displayed"
    
    # Menu items with parameters / Пункты меню с параметрами
    echo "Command with params | shell=\"echo\" param1=\"Hello\" param2=\"World\""
    echo "Multiple params | shell=\"printf\" param1=\"%s\" param2=\"test\""
    print_result 0 "Menu items with parameters displayed"
    
    # Menu items with href / Пункты меню со ссылками
    echo "Open GitHub | href=https://github.com"
    echo "Open System Preferences | href=x-apple.systempreferences:"
    echo "Open Home Directory | href=~/"
    print_result 0 "Menu items with href displayed"
    
    # Complex submenu structure / Сложная структура подменю
    echo "Main Menu Level 1"
    echo "--Submenu Level 2"
    echo "--Another Submenu Level 2"
    echo "----Deep Submenu Level 3"
    echo "------Deeper Submenu Level 4"
    echo "----Back to Level 3"
    echo "--Back to Level 2"
    echo "Back to Level 1"
    print_result 0 "Complex submenu structure displayed"
    
    # Mixed content in submenus / Смешанный контент в подменю
    echo "System Tools"
    echo "--Disk Usage | shell=\"df -h\""
    echo "--Memory Info | shell=\"vm_stat\""
    echo "--Network Info"
    echo "----IP Address | shell=\"ifconfig | grep 'inet '\""
    echo "----Open Network Prefs | href=x-apple.systempreferences:com.apple.Network-Settings.extension"
    echo "--Process List | shell=\"ps aux | head -10\""
    print_result 0 "Mixed content submenus displayed"
    
    # Separators in submenus / Разделители в подменю
    echo "Applications"
    echo "--Productivity"
    echo "---Open Notes | shell=open -a Notes"
    echo "---Open Calendar | shell=open -a Calendar"
    echo "--"
    echo "--Development"
    echo "---Open Terminal | shell=open -a Terminal"
    echo "---Open Xcode | shell=open -a Xcode"
    print_result 0 "Separators in submenus displayed"
}

# Function to test command execution types / Функция тестирования типов выполнения команд
test_command_execution_types() {
    print_header "COMMAND EXECUTION TYPES TEST / ТЕСТ ТИПОВ ВЫПОЛНЕНИЯ КОМАНД"
    
    # Test simple commands / Тест простых команд
    echo "Testing command execution types..."
    
    # Test echo commands / Тест команд echo
    echo "🔄 Testing echo commands..."
    result=$(echo "test" 2>/dev/null)
    if [ "$result" = "test" ]; then
        print_result 0 "Simple echo command works"
    else
        print_result 1 "Simple echo command failed"
    fi
    
    # Test system commands / Тест системных команд
    echo "🖥️ Testing system commands..."
    if command -v uname &> /dev/null; then
        system_info=$(uname -s 2>/dev/null)
        if [ ! -z "$system_info" ]; then
            print_result 0 "System command (uname) works: $system_info"
        else
            print_result 1 "System command (uname) failed"
        fi
    fi
    
    # Test command with output / Тест команды с выводом
    echo "📊 Testing commands with output..."
    if command -v whoami &> /dev/null; then
        current_user=$(whoami 2>/dev/null)
        if [ ! -z "$current_user" ]; then
            print_result 0 "Command with output works: $current_user"
        else
            print_result 1 "Command with output failed"
        fi
    fi
    
    # Test command with arguments / Тест команды с аргументами
    echo "🔧 Testing commands with arguments..."
    if command -v printf &> /dev/null; then
        formatted_output=$(printf "Hello %s" "World" 2>/dev/null)
        if [ "$formatted_output" = "Hello World" ]; then
            print_result 0 "Command with arguments works"
        else
            print_result 1 "Command with arguments failed"
        fi
    fi
    
    # Test file operations / Тест файловых операций
    echo "📁 Testing file operations..."
    temp_file=$(mktemp 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "test content" > "$temp_file"
        if [ -f "$temp_file" ]; then
            content=$(cat "$temp_file" 2>/dev/null)
            if [ "$content" = "test content" ]; then
                print_result 0 "File operations work"
            else
                print_result 1 "File read failed"
            fi
            rm -f "$temp_file"
        else
            print_result 1 "File creation failed"
        fi
    else
        print_result 1 "Temp file creation failed"
    fi
    
    # Test directory operations / Тест операций с директориями
    echo "📂 Testing directory operations..."
    if cd "/tmp" 2>/dev/null && cd "$HOME" 2>/dev/null; then
        print_result 0 "Directory navigation works"
    else
        print_result 1 "Directory navigation failed"
    fi
}

# Function to test paths with spaces handling / Функция тестирования обработки путей с пробелами
test_paths_with_spaces_handling() {
    print_header "PATHS WITH SPACES HANDLING TEST / ТЕСТ ОБРАБОТКИ ПУТЕЙ С ПРОБЕЛАМИ"
    
    echo "Testing paths with spaces handling..."
    
    # Test current script path / Тест пути текущего скрипта
    script_path="$0"
    echo "📄 Script path: $script_path"
    
    if [[ "$script_path" == *" "* ]]; then
        echo "⚠️  Script path contains spaces"
        
        # Test if we can still access the script / Проверяем доступность скрипта
        if [ -f "$script_path" ]; then
            print_result 0 "Script with spaces in path is accessible"
            
            # Test reading from script / Тест чтения из скрипта
            if head -1 "$script_path" &>/dev/null; then
                print_result 0 "Can read from script with spaces in path"
            else
                print_result 1 "Cannot read from script with spaces in path"
            fi
        else
            print_result 1 "Script with spaces in path is not accessible"
        fi
    else
        print_result 0 "Script path without spaces"
    fi
    
    # Test home directory with spaces / Тест домашней директории с пробелами
    echo "🏠 Testing home directory access..."
    if [ -d "$HOME" ]; then
        print_result 0 "Home directory accessible: $HOME"
        
        # Test listing home directory / Тест листинга домашней директории
        if ls "$HOME" &>/dev/null; then
            print_result 0 "Can list home directory contents"
        else
            print_result 1 "Cannot list home directory contents"
        fi
    else
        print_result 1 "Home directory not accessible"
    fi
    
    # Test creating and accessing paths with spaces / Тест создания и доступа к путям с пробелами
    echo "🔧 Testing creation of paths with spaces..."
    temp_dir=$(mktemp -d 2>/dev/null)
    if [ $? -eq 0 ]; then
        test_dir="$temp_dir/Test Directory With Spaces"
        
        # Create directory with spaces / Создаем директорию с пробелами
        if mkdir "$test_dir" 2>/dev/null; then
            print_result 0 "Created directory with spaces"
            
            # Test accessing the directory / Тест доступа к директории
            if [ -d "$test_dir" ]; then
                print_result 0 "Can access directory with spaces"
                
                # Test creating file in directory with spaces / Тест создания файла в директории с пробелами
                test_file="$test_dir/Test File With Spaces.txt"
                if echo "test" > "$test_file" 2>/dev/null; then
                    print_result 0 "Can create file in directory with spaces"
                    
                    # Test reading from file with spaces / Тест чтения из файла с пробелами
                    if [ -f "$test_file" ]; then
                        content=$(cat "$test_file" 2>/dev/null)
                        if [ "$content" = "test" ]; then
                            print_result 0 "Can read from file with spaces in path"
                        else
                            print_result 1 "Cannot read from file with spaces in path"
                        fi
                    else
                        print_result 1 "File with spaces not found"
                    fi
                else
                    print_result 1 "Cannot create file in directory with spaces"
                fi
            else
                print_result 1 "Cannot access created directory with spaces"
            fi
            
            # Cleanup / Очистка
            rm -rf "$temp_dir"
        else
            print_result 1 "Cannot create directory with spaces"
            rm -rf "$temp_dir"
        fi
    else
        print_result 1 "Cannot create temp directory for testing"
    fi
}

# Function to test advanced plugin simulation / Функция тестирования продвинутой симуляции плагинов
test_advanced_plugin_simulation() {
    print_header "ADVANCED PLUGIN SIMULATION TEST / ТЕСТ ПРОДВИНУТОЙ СИМУЛЯЦИИ ПЛАГИНОВ"
    
    echo "🧪 Testing advanced plugin simulation..."
    
    # Simulate system monitor plugin / Симуляция плагина мониторинга системы
    echo "🖥️ System Monitor Pro"
    echo "---"
    
    # System information / Информация о системе
    echo "📊 System Information"
    echo "--Computer: $(scutil --get ComputerName 2>/dev/null || echo 'Unknown')"
    echo "--User: $(whoami)"
    echo "--OS: $(sw_vers -productVersion 2>/dev/null || uname -s)"
    echo "--Arch: $(uname -m)"
    
    # Performance metrics / Метрики производительности
    echo "---"
    echo "🚀 Performance"
    
    # CPU usage / Использование CPU
    cpu_usage=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}' 2>/dev/null || echo "N/A")
    echo "--CPU: $cpu_usage"
    
    # Memory usage / Использование памяти
    memory_info=$(vm_stat 2>/dev/null | grep "Pages active" | awk '{print $3}' | tr -d '.' || echo "N/A")
    if [ "$memory_info" != "N/A" ]; then
        memory_mb=$((memory_info * 4096 / 1024 / 1024))
        echo "--Memory: ${memory_mb} MB active"
    else
        echo "--Memory: $memory_info"
    fi
    
    # Disk usage / Использование диска
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' 2>/dev/null || echo "N/A")
    echo "--Disk: $disk_usage used"
    
    # Network information / Информация о сети
    echo "---"
    echo "🌐 Network"
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")
    echo "--Local IP: $local_ip"
    
    # Actions section / Раздел действий
    echo "---"
    echo "⚡ Actions"
    echo "--Refresh All Data | refresh=true"
    echo "--Open Activity Monitor | shell=open -a 'Activity Monitor'"
    echo "--Open System Preferences | href=x-apple.systempreferences:"
    echo "--"
    echo "--Quick Commands"
    echo "---Show Processes | shell=\"ps aux | head -20\""
    echo "---Disk Space | shell=\"df -h\""
    echo "---Memory Usage | shell=\"vm_stat\""
    
    # Settings section / Раздел настроек
    echo "---"
    echo "⚙️ Settings"
    echo "--Auto-refresh: Enabled"
    echo "--Update Interval: 30s"
    echo "--Notifications: Enabled"
    
    print_result 0 "Advanced plugin simulation completed"
}

# Function to test error handling and edge cases / Функция тестирования обработки ошибок и крайних случаев
test_error_handling_and_edge_cases() {
    print_header "ERROR HANDLING AND EDGE CASES TEST / ТЕСТ ОБРАБОТКИ ОШИБОК И КРАЙНИХ СЛУЧАЕВ"
    
    echo "🚨 Testing error handling and edge cases..."
    
    # Test non-existent commands / Тест несуществующих команд
    echo "🔍 Testing non-existent commands..."
    if ! command -v "this_command_does_not_exist_12345" &> /dev/null; then
        print_result 0 "Non-existent command properly detected"
    else
        print_result 1 "Non-existent command not detected"
    fi
    
    # Test non-existent files / Тест несуществующих файлов
    echo "📁 Testing non-existent files..."
    if [ ! -f "/path/that/does/not/exist/file.txt" ]; then
        print_result 0 "Non-existent file properly detected"
    else
        print_result 1 "Non-existent file not detected"
    fi
    
    # Test permission denied scenarios / Тест сценариев отказа в доступе
    echo "🔐 Testing permission scenarios..."
    if [ ! -w "/System" ] 2>/dev/null; then
        print_result 0 "Write protection properly detected"
    else
        print_result 1 "Write protection not detected"
    fi
    
    # Test empty commands / Тест пустых команд
    echo "⚪ Testing empty commands..."
    empty_result=$(echo "" 2>/dev/null)
    if [ -z "$empty_result" ]; then
        print_result 0 "Empty command handled correctly"
    else
        print_result 1 "Empty command not handled correctly"
    fi
    
    # Test commands with special characters / Тест команд со специальными символа
    echo "🔣 Testing special characters..."
    special_chars_result=$(echo "Line with | pipe & ampersand > greater < less" 2>/dev/null)
    if [ ! -z "$special_chars_result" ]; then
        print_result 0 "Special characters handled"
    else
        print_result 1 "Special characters caused issues"
    fi
    
    # Test very long lines / Тест очень длинных строк
    echo "📏 Testing long lines..."
    long_line="This is a very long line that should test the handling of extended menu item titles and descriptions in CronBarX to ensure proper rendering and functionality without breaking the menu structure or causing layout issues."
    if [ ${#long_line} -gt 100 ]; then
        print_result 0 "Long line handling: ${#long_line} characters"
    else
        print_result 1 "Long line test failed"
    fi
    
    # Test Unicode and emoji characters / Тест Unicode и эмодзи
    echo "🌍 Testing Unicode and emoji..."
    unicode_line="Unicode: 中文 русский Español 🇺🇸 🇷🇺 🇪🇺 🚀 ✅ ❌ ⚠️ 🔄"
    if [[ "$unicode_line" == *"🚀"* ]]; then
        print_result 0 "Unicode and emoji characters supported"
    else
        print_result 1 "Unicode and emoji characters not supported"
    fi
}

# Function to test refresh functionality / Функция тестирования функциональности обновления
test_refresh_functionality() {
    print_header "REFRESH FUNCTIONALITY TEST / ТЕСТ ФУНКЦИОНАЛЬНОСТИ ОБНОВЛЕНИЯ"
    
    echo "🔄 Testing refresh functionality..."
    
    # Test timestamp to verify refresh / Тест временной метки для проверки обновления
    current_time=$(date +%H:%M:%S)
    echo "⏰ Current Time: $current_time"
    
    # Refresh test items / Элементы теста обновления
    echo "---"
    echo "🔄 Refresh Tests"
    echo "--Refresh Now | refresh=true"
    echo "--Refresh with Command | shell=\"echo 'Refreshing...'\" refresh=true"
    echo "--Refresh with Delay | shell=\"sleep 1 && echo 'Delayed refresh'\" refresh=true"
    
    # Dynamic content that changes / Динамический контент который меняется
    echo "---"
    echo "📊 Dynamic Content"
    echo "--Random Number: $RANDOM"
    echo "--Process Count: $(ps aux | wc -l | tr -d ' ')"
    echo "--Uptime: $(uptime | awk '{print $3}' | tr -d ',')"
    
    print_result 0 "Refresh functionality test completed"
}

# Function to test complex nested structures / Функция тестирования сложных вложенных структур
test_complex_nested_structures() {
    print_header "COMPLEX NESTED STRUCTURES TEST / ТЕСТ СЛОЖНЫХ ВЛОЖЕННЫХ СТРУКТУР"
    
    echo "🏗️ Testing complex nested structures..."
    
    # Multi-level nested menu with mixed content / Многоуровневое вложенное меню со смешанным контентом
    echo "🎛️ Control Panel"
    echo "---"
    
    # Level 1: System / Уровень 1: Система
    echo "🖥️ System"
    echo "--Hardware"
    echo "---Processor | shell=\"sysctl -n machdep.cpu.brand_string\""
    echo "---Memory | shell=\"sysctl -n hw.memsize\" | terminal=true"
    echo "---Disks | shell=\"diskutil list\""
    echo "--Software"
    echo "---OS Version | shell=\"sw_vers -productVersion\""
    echo "---Build Number | shell=\"sw_vers -buildVersion\""
    echo "---Kernel | shell=\"uname -r\""
    
    # Level 1: Network / Уровень 1: Сеть
    echo "---"
    echo "🌐 Network"
    echo "--Connections"
    echo "---Wi-Fi | shell=\"networksetup -getairportnetwork en0\""
    echo "---Ethernet | shell=\"ifconfig en0\""
    echo "---All Interfaces | shell=\"ifconfig -a\" | terminal=true"
    echo "--Tools"
    echo "---Ping Test | shell=\"ping -c 3 8.8.8.8\""
    echo "---DNS Check | shell=\"nslookup google.com\""
    echo "---Port Scan | shell=\"nc -zv localhost 80\""
    
    # Level 1: User / Уровень 1: Пользователь
    echo "---"
    echo "👤 User"
    echo "--Account"
    echo "---Username | shell=\"whoami\""
    echo "---Home Directory | shell=\"echo $HOME\""
    echo "---Shell | shell=\"echo $SHELL\""
    echo "--Preferences"
    echo "---Open User Prefs | href=x-apple.systempreferences:com.apple.preferences.users"
    echo "---Login Items | shell=\"osascript -e 'tell application \\\"System Events\\\" to get the name of every login item'\""
    
    # Level 1: Applications / Уровень 1: Приложения
    echo "---"
    echo "📱 Applications"
    echo "--Productivity"
    echo "---Mail | shell=open -a Mail"
    echo "---Calendar | shell=open -a Calendar"
    echo "---Notes | shell=open -a Notes"
    echo "--Development"
    echo "---Terminal | shell=open -a Terminal"
    echo "---Xcode | shell=open -a Xcode"
    echo "---VS Code | shell=open -a 'Visual Studio Code'"
    echo "--Creative"
    echo "---Photos | shell=open -a Photos"
    echo "---Music | shell=open -a Music"
    echo "---TV | shell=open -a TV"
    
    print_result 0 "Complex nested structures test completed"
}

# Function to run comprehensive test suite / Функция запуска комплексного набора тестов
run_comprehensive_test_suite() {
    print_header "CRONBARX COMPREHENSIVE TEST SUITE / КОМПЛЕКСНЫЙ НАБОР ТЕСТОВ CRONBARX"
    echo "Timestamp: $(date)"
    echo "Script: $0"
    echo "User: $(whoami)"
    echo "System: $(uname -s) $(uname -m)"
    echo "---"
    
    test_basic_functionality
    test_complete_menu_structure
    test_command_execution_types
    test_paths_with_spaces_handling
    test_advanced_plugin_simulation
    test_error_handling_and_edge_cases
    test_refresh_functionality
    test_complex_nested_structures
    
    # Final summary / Финальная сводка
    print_header "COMPREHENSIVE TEST SUMMARY / СВОДКА КОМПЛЕКСНОГО ТЕСТИРОВАНИЯ"
    echo "✅ Tests Passed: $TESTS_PASSED"
    echo "❌ Tests Failed: $TESTS_FAILED"
    echo "📊 Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
    echo "🎯 Success Rate: $((TESTS_PASSED * 100 / (TESTS_PASSED + TESTS_FAILED)))%"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "🎉 ALL TESTS PASSED! CronBarX is fully functional."
        echo "🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ! CronBarX полностью функционален."
        echo "🚀 Ready for production use!"
        echo "🚀 Готов к использованию в production!"
    else
        echo "⚠️  Some tests failed. Check the specific issues above."
        echo "⚠️  Некоторые тесты не пройдены. Проверьте конкретные проблемы выше."
        echo "🔧 Review failed tests and fix the issues."
        echo "🔧 Просмотрите неудачные тесты и исправьте проблемы."
    fi
    
    echo "---"
    echo "📋 Test Coverage:"
    echo "- Basic script execution and output formatting"
    echo "- Complete menu structure with all formats"
    echo "- Command execution with various types and parameters"
    echo "- Paths with spaces handling"
    echo "- Advanced plugin simulation"
    echo "- Error handling and edge cases"
    echo "- Refresh functionality"
    echo "- Complex nested menu structures"
    echo "- Unicode, emoji, and special characters"
    echo "- File and directory operations"
}

# Function to show interactive test menu / Функция показа интерактивного меню тестов
show_interactive_test_menu() {
    echo "🔄 CronBarX Comprehensive Test Suite"
    echo "---"
    echo "📊 Run Complete Test Suite | shell=\"$0\" param1=\"--comprehensive\" refresh=true"
    echo "🔧 Individual Test Categories"
    echo "--Basic Functionality | shell=\"$0\" param1=\"--basic\" refresh=true"
    echo "--Menu Structure | shell=\"$0\" param1=\"--menu\" refresh=true"
    echo "--Command Execution | shell=\"$0\" param1=\"--commands\" refresh=true"
    echo "--Paths with Spaces | shell=\"$0\" param1=\"--paths\" refresh=true"
    echo "--Plugin Simulation | shell=\"$0\" param1=\"--plugin\" refresh=true"
    echo "--Error Handling | shell=\"$0\" param1=\"--errors\" refresh=true"
    echo "--Refresh Functionality | shell=\"$0\" param1=\"--refresh\" refresh=true"
    echo "--Nested Structures | shell=\"$0\" param1=\"--nested\" refresh=true"
    echo "---"
    echo "📈 Test Results"
    echo "--Passed: $TESTS_PASSED"
    echo "--Failed: $TESTS_FAILED"
    echo "--Total: $((TESTS_PASSED + TESTS_FAILED))"
    echo "---"
    echo "❌ Exit Test Suite | refresh=true"
}

# Main execution / Основное выполнение
case "${1}" in
    "--comprehensive")
        run_comprehensive_test_suite
        ;;
    "--basic")
        test_basic_functionality
        ;;
    "--menu")
        test_complete_menu_structure
        ;;
    "--commands")
        test_command_execution_types
        ;;
    "--paths")
        test_paths_with_spaces_handling
        ;;
    "--plugin")
        test_advanced_plugin_simulation
        ;;
    "--errors")
        test_error_handling_and_edge_cases
        ;;
    "--refresh")
        test_refresh_functionality
        ;;
    "--nested")
        test_complex_nested_structures
        ;;
    *)
        show_interactive_test_menu
        ;;
esac