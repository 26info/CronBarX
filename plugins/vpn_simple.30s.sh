#!/bin/bash
# VPN Status Monitor Lite - CronBarX Plugin  
# Minimal VPN connection status checker

scutil --proxy | grep -q "Enable : 1" && echo "🛡️ VPN" || echo "🌐 DIRECT"