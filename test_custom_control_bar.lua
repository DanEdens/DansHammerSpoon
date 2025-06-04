-- Test script for CustomControlBar Spoon
-- 
-- To run this test:
-- 1. Open Hammerspoon Console (click Hammerspoon icon in menu bar -> Console...)
-- 2. Either:
--    a) Copy and paste this entire script into the console, OR
--    b) Add `require("test_custom_control_bar")` to your init.lua temporarily
--
-- This script tests basic functionality and sets up example profiles

print("Loading CustomControlBar test...")

-- Ensure we reload the spoon if it's already loaded
if spoon and spoon.CustomControlBar then
    print("Stopping existing CustomControlBar instance")
    spoon.CustomControlBar:stop()
end

-- Load the CustomControlBar spoon
print("Loading CustomControlBar spoon")
hs.loadSpoon("CustomControlBar")

if not spoon.CustomControlBar then
    error("Failed to load CustomControlBar spoon")
end

-- Configure basic settings
print("Configuring CustomControlBar")
spoon.CustomControlBar.position = "bottom"
spoon.CustomControlBar.size = {w = 900, h = 60}

-- Customize theme for better visibility during testing
spoon.CustomControlBar.theme.background = {red = 0.2, green = 0.2, blue = 0.2, alpha = 0.95}

-- Add Safari profile
print("Adding Safari profile")
spoon.CustomControlBar:addAppProfile("com.apple.Safari", {
    buttons = {
        {icon = "⬅", action = "cmd+[", tooltip = "Back"},
        {icon = "➡", action = "cmd+]", tooltip = "Forward"}, 
        {icon = "🔄", action = "cmd+r", tooltip = "Reload"},
        {icon = "🔖", action = "cmd+d", tooltip = "Bookmark"},
        {icon = "🏠", action = "cmd+shift+h", tooltip = "Home"}
    }
})

-- Add Finder profile
print("Adding Finder profile")
spoon.CustomControlBar:addAppProfile("com.apple.finder", {
    buttons = {
        {icon = "⬆", action = "cmd+up", tooltip = "Up Directory"},
        {icon = "📁", action = "cmd+shift+n", tooltip = "New Folder"},
        {icon = "🗑", action = "cmd+delete", tooltip = "Move to Trash"},
        {icon = "👁", action = "cmd+1", tooltip = "Icon View"},
        {icon = "📋", action = "cmd+2", tooltip = "List View"}
    }
})

-- Add Terminal profile  
print("Adding Terminal profile")
spoon.CustomControlBar:addAppProfile("com.apple.Terminal", {
    buttons = {
        {icon = "📋", action = "cmd+c", tooltip = "Copy"},
        {icon = "📄", action = "cmd+v", tooltip = "Paste"},
        {icon = "🆕", action = "cmd+t", tooltip = "New Tab"},
        {icon = "❌", action = "cmd+w", tooltip = "Close Tab"},
        {icon = "🔍", action = "cmd+f", tooltip = "Find"}
    }
})

-- Add VS Code profile
print("Adding VS Code profile")
spoon.CustomControlBar:addAppProfile("com.microsoft.VSCode", {
    buttons = {
        {icon = "💾", action = "cmd+s", tooltip = "Save"},
        {icon = "🔍", action = "cmd+f", tooltip = "Find"},
        {icon = "🔄", action = "cmd+shift+f", tooltip = "Find in Files"},
        {icon = "🚀", action = "f5", tooltip = "Run/Debug"},
        {icon = "📁", action = "cmd+shift+e", tooltip = "Explorer"}
    }
})

-- Add a test profile for Hammerspoon Console itself
print("Adding Hammerspoon Console profile")
spoon.CustomControlBar:addAppProfile("org.hammerspoon.Hammerspoon", {
    buttons = {
        {icon = "🔄", action = "cmd+r", tooltip = "Reload Config"},
        {icon = "🧹", action = "cmd+k", tooltip = "Clear Console"},
        {icon = "📄", action = "cmd+v", tooltip = "Paste"},
        {icon = "💾", action = "cmd+s", tooltip = "Save"},
        {icon = "🎯", action = function() 
            hs.alert.show("Test button clicked!")
        end, tooltip = "Test Function"}
    }
})

-- Start the control bar
print("Starting CustomControlBar")
spoon.CustomControlBar:start()

-- Log success
hs.alert.show("CustomControlBar loaded! Press Cmd+Ctrl+T to toggle", 3)
print("✅ CustomControlBar test loaded successfully!")
print("")
print("Usage Instructions:")
print("- Press Cmd+Ctrl+T to toggle visibility")
print("- Switch between Safari, Finder, Terminal, VS Code, or Hammerspoon to see context switching")
print("- Check the control bar at the bottom of your screen")
print("- Click buttons to test functionality")
print("")
print("Current frontmost app:", hs.application.frontmostApplication():name())
print("Bundle ID:", hs.application.frontmostApplication():bundleID())

-- Test visibility controls
print("Testing visibility controls in 5 seconds...")
hs.timer.doAfter(5, function()
    print("Hiding control bar...")
    spoon.CustomControlBar:hide()
    hs.alert.show("Control bar hidden - it will reappear in 3 seconds")
    
    hs.timer.doAfter(3, function()
        print("Showing control bar...")
        spoon.CustomControlBar:show()
        hs.alert.show("Control bar visible again!")
    end)
end)

print("Test script execution complete. Check the bottom of your screen for the control bar.")

-- Return success for require() usage
return true 