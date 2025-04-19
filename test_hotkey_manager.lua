-- Test script for HotkeyManager
-- Run this with `hs -c "dofile('test_hotkey_manager.lua')"`

local HotkeyManager = require('HotkeyManager')
print("HotkeyManager loaded successfully")

-- Test the hotkey registration
local hammer = { "cmd", "ctrl", "alt" }
local hyper = { "cmd", "shift", "ctrl", "alt" }

-- Register some test bindings
HotkeyManager.registerBinding(hammer, "z", function() print("Test hammer Z") end, "Test Hammer Z")
HotkeyManager.registerBinding(hyper, "z", function() print("Test hyper Z") end, "Test Hyper Z")
HotkeyManager.registerBinding(hammer, "q", function() tempFunction() end, "Temporary Function")

-- Print registered bindings
print("\nHammer bindings:")
for i, binding in ipairs(HotkeyManager.bindings[HotkeyManager.MODIFIERS.HAMMER]) do
    print(string.format("Key: %s, Description: %s, IsTemp: %s",
        binding.key, binding.description, tostring(binding.isTemp)))
end

print("\nHyper bindings:")
for i, binding in ipairs(HotkeyManager.bindings[HotkeyManager.MODIFIERS.HYPER]) do
    print(string.format("Key: %s, Description: %s, IsTemp: %s",
        binding.key, binding.description, tostring(binding.isTemp)))
end

-- Test displaying the hotkey lists
print("\nDisplaying Hammer hotkey list")
HotkeyManager.showHammerList()

print("\nDisplaying Hyper hotkey list")
HotkeyManager.showHyperList()

print("\nTest completed")
