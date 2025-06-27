#!/bin/bash

# Mad Tinker's Caps Lock Debug Script 🔍⚡
# Helps debug Caps Lock to Hyper key issues

echo "🔍 Mad Tinker's Caps Lock Hyper Key Debugger"
echo "============================================="

echo ""
echo "1️⃣ Checking current key remapping status..."
echo "Current hidutil mappings:"
/usr/bin/hidutil property --get "UserKeyMapping"

echo ""
echo "2️⃣ Checking if LaunchAgent is loaded..."
PLIST_PATH="$HOME/Library/LaunchAgents/com.madness.interactive.RemapCapsLockToF18.plist"
if launchctl list | grep -q "com.madness.interactive.RemapCapsLockToF18"; then
    echo "✅ LaunchAgent is loaded"
else
    echo "❌ LaunchAgent is NOT loaded"
fi

echo ""
echo "3️⃣ Checking if plist file exists..."
if [ -f "$PLIST_PATH" ]; then
    echo "✅ Plist file exists at: $PLIST_PATH"
else
    echo "❌ Plist file does NOT exist"
fi

echo ""
echo "4️⃣ Checking macOS shortcuts that might conflict..."
echo "Checking System Preferences shortcuts..."

# Check if Notification Center is mapped to F18
defaults read com.apple.symbolichotkeys.plist AppleSymbolicHotKeys | grep -A5 -B5 "65" 2>/dev/null || echo "No symbolic hotkey 65 found"

echo ""
echo "5️⃣ Testing alternative function keys..."
echo "Let's try a different function key that's less likely to be used..."

echo ""
echo "🔧 SUGGESTED FIXES:"
echo "==================="
echo ""
echo "Option 1: Try F19 instead of F18"
echo "  F19 is less likely to be mapped by macOS"
echo ""
echo "Option 2: Try F20 (very unlikely to be used)"
echo "  F20 is almost never used by system"
echo ""
echo "Option 3: Check if F18 is mapped to Notification Center"
echo "  System Preferences > Keyboard > Shortcuts > Mission Control"
echo "  Look for Notification Center shortcut"
echo ""
echo "🎯 Quick test: Press Caps Lock + different letters"
echo "  If they all trigger system functions, F18 is mapped"
echo ""
echo "Would you like me to create a version with F19 or F20?" 
