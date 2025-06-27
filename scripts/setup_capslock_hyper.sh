#!/bin/bash

# Mad Tinker's Caps Lock to Hyper Key Setup Script 🔧⚡
# This script remaps Caps Lock to F18 for use as a Hyper modifier in Hammerspoon

echo "🔧 Mad Tinker's Caps Lock Hyper Key Setup"
echo "========================================"

# Create the LaunchAgent plist for automatic loading
PLIST_PATH="$HOME/Library/LaunchAgents/com.madness.interactive.RemapCapsLockToF18.plist"

echo "📝 Creating LaunchAgent plist at: $PLIST_PATH"

cat > "$PLIST_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.madness.interactive.RemapCapsLockToF18</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

echo "✅ LaunchAgent plist created successfully!"

# Load the plist immediately
echo "🚀 Loading the LaunchAgent..."
launchctl load "$PLIST_PATH"

# Apply the remapping immediately
echo "⌨️  Applying Caps Lock to F18 remapping..."
/usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}'

echo ""
echo "🎉 SUCCESS! Caps Lock is now remapped to F18!"
echo ""
echo "📋 What this means:"
echo "   • Caps Lock alone = ESC (great for vim!)"
echo "   • Caps Lock + any key = Hyper hotkey"
echo "   • This will persist across reboots"
echo ""
echo "🔧 Try these new hotkeys:"
echo "   • Caps Lock + C = Calculator"
echo "   • Caps Lock + V = VS Code"
echo "   • Caps Lock + N = Notes"
echo "   • Caps Lock + Space = Show all hotkeys"
echo "   • Caps Lock + M = MADNESS MODE! 🎪"
echo ""
echo "⚠️  Note: Restart Hammerspoon for the changes to take effect!"
echo ""
echo "🔄 To undo this remapping later, run:"
echo "   launchctl unload \"$PLIST_PATH\""
echo "   rm \"$PLIST_PATH\""
echo "   /usr/bin/hidutil property --set '{\"UserKeyMapping\":[]}'"
echo ""
echo "The Mad Tinker's fourth dimension of hotkeys is ready! 🔧⚡"
