#!/bin/bash

# Notification test using temporary scripts

create_test_script() {
    local test_num="$1"
    local message="$2"
    local title="$3"
    
    cat > "/tmp/notification_test_$test_num.sh" << EOF
#!/bin/bash
/usr/bin/osascript -e 'display notification "$message" with title "$title"'
EOF
    chmod +x "/tmp/notification_test_$test_num.sh"
}

# Create test scripts
create_test_script 1 "Test notification 1" "CronBarX"
create_test_script 2 "Test notification 2" "Test Title" 
create_test_script 3 "Test notification 3" "Success"

echo "🔔 Test Notifications"
echo "---"
echo "Test 1 | shell=/tmp/notification_test_1.sh"
echo "Test 2 | shell=/tmp/notification_test_2.sh"
echo "Test 3 | shell=/tmp/notification_test_3.sh"
echo "---"
echo "🔄 Refresh | refresh=true"
