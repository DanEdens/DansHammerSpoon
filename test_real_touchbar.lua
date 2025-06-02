-- Test script for real TouchBar Spoon
-- 
-- To run this test:
-- 1. Ensure you have a MacBook with physical TouchBar
-- 2. Install hs._asm.undocumented.touchbar extension first
-- 3. Open Hammerspoon Console (click Hammerspoon icon in menu bar -> Console...)
-- 4. Run: require("test_real_touchbar")
--
-- This script tests the real TouchBar functionality and sets up example profiles

print("Loading TouchBar test...")

-- Check if TouchBar extension is available
local success, touchbar_ext = pcall(require, "hs._asm.undocumented.touchbar")
if not success then
    print("❌ TouchBar extension not found!")
    print("Install with: cd ~/.hammerspoon && curl -L https://github.com/asmagill/hs._asm.undocumented.touchbar/raw/master/touchbar-v0.8.3.2alpha-universal.tar.gz | tar -xz")
    return false
end

-- Check TouchBar support
if not touchbar_ext.supported() then
    print("❌ TouchBar not supported on this machine")
    return false
end

if not touchbar_ext.physical() then
    print("❌ No physical TouchBar detected")
    print("💡 Consider using CustomControlBar.spoon instead for virtual TouchBar")
    return false
end

print("✅ Physical TouchBar detected!")

-- Ensure we reload the spoon if it's already loaded
if spoon and spoon.TouchBar then
    print("Stopping existing TouchBar instance")
    spoon.TouchBar:stop()
end

-- Load the TouchBar spoon
print("Loading TouchBar spoon")
hs.loadSpoon("TouchBar")

if not spoon.TouchBar then
    error("Failed to load TouchBar spoon")
end

-- Set up custom default items
print("Configuring default TouchBar items")
spoon.TouchBar:setDefaultItems({
    {id = "time", title = os.date("%H:%M"), color = "white"},
    {id = "volume", title = "🔊", callback = function() 
        local device = hs.audiodevice.defaultOutputDevice()
        if device then
            device:setMuted(not device:muted())
            hs.alert.show(device:muted() and "Muted" or "Unmuted")
        end
    end},
    {id = "brightness", title = "☀️", callback = function()
        local current = hs.brightness.get()
        local new = current > 50 and 25 or 75
        hs.brightness.set(new)
        hs.alert.show("Brightness: " .. new .. "%")
    end},
    {id = "reload", title = "⟳", callback = function() 
        hs.alert.show("Reloading Hammerspoon...")
        hs.reload() 
    end}
})

-- Add Safari profile
print("Adding Safari TouchBar profile")
spoon.TouchBar:addAppProfile("com.apple.Safari", {
    items = {
        {id = "back", title = "←", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "[") 
        end},
        {id = "forward", title = "→", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "]") 
        end},
        {id = "reload", title = "⟳", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "r") 
        end},
        {id = "bookmark", title = "🔖", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "d") 
        end},
        {id = "home", title = "🏠", callback = function() 
            hs.eventtap.keyStroke({"cmd", "shift"}, "h") 
        end}
    }
})

-- Add Terminal profile
print("Adding Terminal TouchBar profile")
spoon.TouchBar:addAppProfile("com.apple.Terminal", {
    items = {
        {id = "new_tab", title = "⊞", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "t") 
        end},
        {id = "close_tab", title = "✕", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "w") 
        end},
        {id = "clear", title = "🧹", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "k") 
        end},
        {id = "interrupt", title = "⏹", callback = function() 
            hs.eventtap.keyStroke({"ctrl"}, "c") 
        end},
        {id = "find", title = "🔍", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "f") 
        end}
    }
})

-- Add VS Code profile
print("Adding VS Code TouchBar profile")
spoon.TouchBar:addAppProfile("com.microsoft.VSCode", {
    items = {
        {id = "save", title = "💾", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "s") 
        end},
        {id = "find", title = "🔍", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "f") 
        end},
        {id = "run", title = "▶️", callback = function() 
            hs.eventtap.keyStroke({}, "F5") 
        end},
        {id = "debug", title = "🐛", callback = function() 
            hs.eventtap.keyStroke({}, "F9") 
        end},
        {id = "terminal", title = "⌨️", callback = function() 
            hs.eventtap.keyStroke({"ctrl"}, "`") 
        end}
    }
})

-- Add Finder profile
print("Adding Finder TouchBar profile")
spoon.TouchBar:addAppProfile("com.apple.finder", {
    items = {
        {id = "up", title = "⬆", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "up") 
        end},
        {id = "new_folder", title = "📁", callback = function() 
            hs.eventtap.keyStroke({"cmd", "shift"}, "n") 
        end},
        {id = "delete", title = "🗑", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "delete") 
        end},
        {id = "list_view", title = "📋", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "2") 
        end},
        {id = "icon_view", title = "⬜", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "1") 
        end}
    }
})

-- Add a test profile for Hammerspoon Console itself
print("Adding Hammerspoon Console TouchBar profile")
spoon.TouchBar:addAppProfile("org.hammerspoon.Hammerspoon", {
    items = {
        {id = "reload", title = "⟳", callback = function() 
            hs.reload() 
        end},
        {id = "clear", title = "🧹", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "k") 
        end},
        {id = "test", title = "🎯", callback = function() 
            hs.alert.show("TouchBar test button pressed!")
        end},
        {id = "docs", title = "📚", callback = function() 
            hs.urlevent.openURL("https://www.hammerspoon.org/docs/")
        end}
    }
})

-- Start the TouchBar
print("Starting TouchBar")
spoon.TouchBar:start()

-- Show success message
hs.alert.show("Real TouchBar loaded! Check your TouchBar", 3)
print("✅ Real TouchBar test loaded successfully!")
print("")
print("Usage Instructions:")
print("- Your physical TouchBar should now show custom controls")
print("- Switch between Safari, Terminal, VS Code, Finder, or Hammerspoon to see context switching")
print("- Press buttons on your TouchBar to test functionality")
print("")

-- Get current app info
local currentApp = hs.application.frontmostApplication()
if currentApp then
    print("Current frontmost app:", currentApp:name())
    print("Bundle ID:", currentApp:bundleID())
else
    print("No frontmost application detected")
end

-- Test TouchBar hardware info
print("")
print("TouchBar Hardware Info:")
print("- Supported:", touchbar_ext.supported())
print("- Physical:", touchbar_ext.physical())
print("- Exists:", touchbar_ext.exists())

local size = touchbar_ext.size()
if size then
    print("- Size:", size.w .. "x" .. size.h)
end

print("")
print("Test script execution complete. Your TouchBar should now be active!")

-- Return success for require() usage
return true 