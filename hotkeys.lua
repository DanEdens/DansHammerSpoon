---@diagnostic disable: lowercase-global, undefined-global
-- Use our custom HyperLogger instead of the standard logger
local HyperLogger = require('HyperLogger')
-- Always use the global application logger from init.lua
local log = _G.AppLogger
local __FILE__ = 'hotkeys.lua'
log:d('Initializing hotkey system', __FILE__, 6)

-- Access modules from the global environment if they've been loaded already
-- This prevents redundant module initialization
local function getModule(name)
    if _G[name] then
        log:d('Using existing module: ' .. name, __FILE__, 12)
        return _G[name]
    else
        log:d('Loading module: ' .. name, __FILE__, 15)
        local module = require(name)
        _G[name] = module
        return module
    end
end

-- Import modules using the getModule helper
local WindowManager = getModule('WindowManager')
local FileManager = getModule('FileManager')
local AppManager = getModule('AppManager')
local DeviceManager = getModule('DeviceManager')
local HotkeyManager = getModule('HotkeyManager')
local WindowToggler = getModule('WindowToggler')
local ProjectManager = getModule('ProjectManager')
local WindowMenu = getModule('WindowMenu')

-- Define modifier key combinations
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
_meta = { "cmd", "shift", "alt" }
-- NEW: Caps Lock as Hyper key (maps to F18)
_caps = {} -- Will be set up below with modal system

-- Add state tracking for toggling right layouts
local rightLayoutState = {
    isSmall = true
}
local leftLayoutState = {
    isSmall = true
}
local FullLayoutState = {
    currentState = 0 -- 0: fullScreen, 1: nearlyFull, 2: trueFull
}

-- ====================================
-- CAPS LOCK AS HYPER KEY SETUP 🔧⚡
-- ====================================
-- Create a modal for Caps Lock (F18) - The Mad Tinker's fourth dimension of hotkeys!
-- local capsModal = hs.hotkey.modal.new({}, 'F17')

-- -- Enter Caps Mode when F18 (remapped Caps Lock) is pressed
-- function enterCapsMode()
--     capsModal.triggered = false
--     capsModal:enter()
--     log:d('Entered Caps Lock Hyper Mode - The fourth dimension awaits!', __FILE__, 50)
-- end

-- -- Exit Caps Mode when F18 is released
-- -- If no other keys were pressed, send ESCAPE (handy for vim users!)
-- function exitCapsMode()
--     capsModal:exit()
--     if not capsModal.triggered then
--         hs.eventtap.keyStroke({}, 'ESCAPE')
--         log:d('Caps Lock released alone - sending ESCAPE', __FILE__, 58)
--     else
--         log:d('Exited Caps Lock Hyper Mode', __FILE__, 60)
--     end
-- end

-- -- Bind F18 (remapped Caps Lock) to enter/exit Caps Mode
-- local f18Hotkey = hs.hotkey.bind({}, 'F18', enterCapsMode, exitCapsMode)

-- -- Helper function to bind Caps Lock hotkeys
-- local function bindCapsKey(key, description, func)
--     capsModal:bind({}, key, description, function()
--         capsModal.triggered = true
--         func()
--     end)
-- end

-- ====================================
-- CAPS LOCK HOTKEY BINDINGS 🚀
-- ====================================
-- The Mad Tinker's Fourth Dimension of Hotkeys!

-- -- Quick App Launchers (Caps + Letter)
-- bindCapsKey("c", "Open Calculator", function()
--     hs.application.launchOrFocus("Calculator")
--     hs.alert.show("📊 Calculator", 1)
-- end)

-- bindCapsKey("v", "Open VS Code", function()
--     hs.application.launchOrFocus("Visual Studio Code")
--     hs.alert.show("💻 VS Code", 1)
-- end)

-- bindCapsKey("n", "Open Notes", function()
--     hs.application.launchOrFocus("Notes")
--     hs.alert.show("📝 Notes", 1)
-- end)

-- bindCapsKey("r", "Open Activity Monitor", function()
--     hs.application.launchOrFocus("Activity Monitor")
--     hs.alert.show("📈 Activity Monitor", 1)
-- end)

-- -- System Controls (Caps + Function Keys)
-- bindCapsKey("F1", "Show Desktop", function()
--     hs.spaces.toggleShowDesktop()
--     hs.alert.show("🖥️ Desktop", 1)
-- end)

-- bindCapsKey("F2", "Mission Control", function()
--     hs.spaces.toggleMissionControl()
--     hs.alert.show("🚀 Mission Control", 1)
-- end)

-- bindCapsKey("F3", "Launchpad", function()
--     hs.application.launchOrFocus("Launchpad")
--     hs.alert.show("🎯 Launchpad", 1)
-- end)

-- -- Window Management (Caps + Arrow Keys)
-- bindCapsKey("left", "Move Window Left Quarter", function()
--     WindowManager.applyLayout("leftQuarter")
--     hs.alert.show("⬅️ Left Quarter", 1)
-- end)

-- bindCapsKey("right", "Move Window Right Quarter", function()
--     WindowManager.applyLayout("rightQuarter")
--     hs.alert.show("➡️ Right Quarter", 1)
-- end)

-- bindCapsKey("up", "Move Window Top Half", function()
--     WindowManager.applyLayout("topHalf")
--     hs.alert.show("⬆️ Top Half", 1)
-- end)

-- bindCapsKey("down", "Move Window Bottom Third", function()
--     WindowManager.applyLayout("bottomThird")
--     hs.alert.show("⬇️ Bottom Third", 1)
-- end)

-- -- Utility Functions (Caps + Numbers)
-- bindCapsKey("1", "Toggle WiFi", function()
--     -- This would need a WiFi toggle function
--     hs.alert.show("📶 WiFi Toggle", 1)
--     log:i('WiFi toggle requested via Caps Lock', __FILE__, 125)
-- end)

-- bindCapsKey("2", "Toggle Bluetooth", function()
--     -- This would need a Bluetooth toggle function
--     hs.alert.show("🔵 Bluetooth Toggle", 1)
--     log:i('Bluetooth toggle requested via Caps Lock', __FILE__, 130)
-- end)

-- bindCapsKey("3", "Toggle Do Not Disturb", function()
--     AppManager.toggle_do_not_disturb()
--     hs.alert.show("🔕 Do Not Disturb", 1)
-- end)

-- -- Mad Tinker Special Functions (Caps + Special Keys)
-- bindCapsKey("space", "Show All Hotkeys", function()
--     -- Show a comprehensive hotkey list including Caps Lock hotkeys
--     HotkeyManager.showAllHotkeys()
--     hs.alert.show("🔧 All Hotkeys", 2)
-- end)

-- bindCapsKey("tab", "Cycle Through Apps", function()
--     hs.application.launchOrFocus("Mission Control")
--     hs.alert.show("🔄 App Cycle", 1)
-- end)

-- bindCapsKey("escape", "Lock Screen", function()
--     hs.caffeinate.lockScreen()
--     hs.alert.show("🔒 Screen Locked", 1)
-- end)

-- -- Fun Mad Tinker Features
-- bindCapsKey("m", "Toggle Madness Mode", function()
--     -- This could toggle some special visual effects or modes
--     hs.alert.show("🎪 MADNESS MODE ENGAGED! 🔧⚡", 3)
--     log:i('MADNESS MODE TOGGLED!', __FILE__, 155)
-- end)

log:d('Caps Lock Hyper Mode initialized - Fourth dimension ready!', __FILE__, 158)
-- Keybindings
hs.hotkey.bind(hammer, "Space", "Show Hammer Hotkeys", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", "Show Hyper Hotkeys", function() showHyperList() end)
hs.hotkey.bind(hammer, "1", "Move Top-Left Corner", function() WindowManager.applyLayout("topLeft") end)
hs.hotkey.bind(_hyper, "1", "Move Bottom-Left Corner", function() WindowManager.applyLayout("bottomLeft") end)
hs.hotkey.bind(hammer, "2", "Move Top-Right Corner", function() WindowManager.applyLayout("topRight") end)
hs.hotkey.bind(_hyper, "2", "Move Bottom-Right Corner", function() WindowManager.applyLayout("bottomRight") end)
hs.hotkey.bind(hammer, "r", "Show Window Management Menu", function() WindowMenu.toggleMenu() end)
hs.hotkey.bind(_hyper, "r", "Reset Shuffle Counters", function() WindowManager.resetShuffleCounters() end)
hs.hotkey.bind(hammer, "3", "Full Screen", function() WindowManager.toggleFullLayout() end)
hs.hotkey.bind(_hyper, "3", "Nearly Full Screen", function() WindowManager.applyLayout('sevenByFive') end)
hs.hotkey.bind(hammer, "4", "Left Wide Layout", function() WindowManager.applyLayout('leftWide') end)
hs.hotkey.bind(_hyper, "4", "Mini Shuffle", function() WindowManager.miniShuffle() end)
hs.hotkey.bind(hammer, "5", "Split Vertical", function() WindowManager.applyLayout('splitVertical') end)
hs.hotkey.bind(_hyper, "5", "Split Horizontal", function() WindowManager.applyLayout('splitHorizontal') end)
hs.hotkey.bind(hammer, "6", "Left Small Layout", function() WindowManager.toggleLeftLayout() end)
hs.hotkey.bind(_hyper, "6", "Left Half Layout", function() WindowManager.applyLayout('leftHalf') end)
hs.hotkey.bind(hammer, "7", "Toggle Right Layout", function() WindowManager.toggleRightLayout() end)
hs.hotkey.bind(_hyper, "7", "Right Half Layout", function() WindowManager.applyLayout('rightHalf') end)
hs.hotkey.bind(hammer, "8", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "8", "Open System Preferences", function() AppManager.open_system() end)
hs.hotkey.bind(hammer, "9", "Move Window to Mouse", function() WindowManager.moveWindowMouseCenter() end)
hs.hotkey.bind(_hyper, "9", "Open Selected File", function() FileManager.openSelectedFile() end)
hs.hotkey.bind(hammer, "0", "Horizontal Shuffle", function() WindowManager.halfShuffle(12, 8) end)
hs.hotkey.bind(_hyper, "0", "Vertical Shuffle", function() WindowManager.halfShuffle(12, 3) end)
hs.hotkey.bind(hammer, "left", "Move Window Left", function() WindowManager.moveWindow("left") end)
hs.hotkey.bind(_hyper, "left", "Move to Previous Screen", function() WindowManager.moveToScreen("previous", "right") end)
hs.hotkey.bind(hammer, "right", "Move Window Right", function() WindowManager.moveWindow("right") end)
hs.hotkey.bind(_hyper, "right", "Move to Next Screen", function() WindowManager.moveToScreen("next", "right") end)
hs.hotkey.bind(hammer, "up", "Move Window Up", function() WindowManager.moveWindow("up") end)
hs.hotkey.bind(_hyper, "up", "Center Screen Layout", function() WindowManager.applyLayout('centerScreen') end)
hs.hotkey.bind(hammer, "down", "Move Window Down", function() WindowManager.moveWindow("down") end)
hs.hotkey.bind(_hyper, "down", "Bottom Half Layout", function() WindowManager.applyLayout('bottomHalf') end)
hs.hotkey.bind(hammer, "F1", "Toggle Console", function() hs.toggleConsole() end)
hs.hotkey.bind(_hyper, "F1", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F2", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F2", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind("cmd", "F3", "Open GitHub", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "F3", "Toggle USB Logging", function() DeviceManager.toggleUSBLogging() end)
hs.hotkey.bind(_hyper, "F3", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F4", "Show Layouts Menu", function() spoon.Layouts:chooseLayout() end)
hs.hotkey.bind(_hyper, "F4", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F5", "Reload Hammerspoon", function() hs.reload() end)
hs.hotkey.bind(_hyper, "F5", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F6", "Save Window Position", function() WindowManager.saveWindowPosition() end)
hs.hotkey.bind(_hyper, "F6", "Save All Window Positions", function() WindowManager.saveAllWindowPositions() end)
hs.hotkey.bind(hammer, "F7", "Restore Window Position", function() WindowManager.restoreWindowPosition() end)
hs.hotkey.bind(_hyper, "F7", "Restore All Window Positions", function() WindowManager.restoreAllWindowPositions() end)
hs.hotkey.bind(hammer, "F8", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F8", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F9", "Show Window Config Info", function() WindowToggler.showConfigurationInfo() end)
hs.hotkey.bind(_hyper, "F9", "Refresh Window Config", function() WindowToggler.refreshConfiguration() end)
-- hs.hotkey.bind(hammer, "F10", "Save Window to Location 1", function() WindowToggler.saveToLocation1() end)
-- hs.hotkey.bind(_hyper, "F10", "Restore Window to Location 1", function() WindowToggler.restoreToLocation1() end)
-- hs.hotkey.bind(hammer, "F11", "Save Window to Location 2", function() WindowToggler.saveToLocation2() end)
-- hs.hotkey.bind(_hyper, "F11", "Restore Window to Location 2", function() WindowToggler.restoreToLocation2() end)
-- hs.hotkey.bind(hammer, "F12", Cant use this key
hs.hotkey.bind(_hyper, "F12", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "p", "Open PyCharm", function() AppManager.open_pycharm() end)
hs.hotkey.bind(_hyper, "p", "Open Cursor", function() AppManager.open_cursor() end)
hs.hotkey.bind(hammer, "b", "Open Arc Browser", function() AppManager.open_arc() end)
hs.hotkey.bind(_hyper, "b", "Open Chrome", function() AppManager.open_chrome() end)
hs.hotkey.bind(hammer, "d", "Open AnythingLLM", function() AppManager.open_anythingllm() end)
hs.hotkey.bind(_hyper, "d", "Open MongoDB Compass", function() AppManager.open_mongodb() end)
hs.hotkey.bind(hammer, "l", "Open Logi Options+", function() AppManager.open_logi() end)
hs.hotkey.bind(_hyper, "l", "Open System Settings", function() AppManager.open_system() end)
hs.hotkey.bind(hammer, "s", "Open Slack", function() AppManager.open_slack() end)
hs.hotkey.bind(hammer, "g", "Open GitHub Desktop", function() AppManager.launchGitHubWithProjectSelection() end)
hs.hotkey.bind(_hyper, "g", "Open just GitHub Desktop", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "`", "Open Cursor with GitHub", function() AppManager.open_cursor_with_github() end)
hs.hotkey.bind(_hyper, "`", "Open Cursor", function() AppManager.open_medis() end)
hs.hotkey.bind(hammer, "Tab", "Open Mission Control", function() AppManager.open_mission_control() end)
hs.hotkey.bind(_hyper, "Tab", "Open Launchpad", function() AppManager.open_launchpad() end)
hs.hotkey.bind(hammer, "t", "Open Barrier", function() AppManager.open_barrier() end)
hs.hotkey.bind(hammer, "i", "Copy Most Recent Image", function() FileManager.copyMostRecentImage() end)
hs.hotkey.bind(_hyper, "i", "Open Most Recent Image", function() FileManager.openMostRecentImage() end)
hs.hotkey.bind(hammer, "e", "Show File Menu", function() FileManager.showFileMenu() end)
hs.hotkey.bind(_hyper, "e", "Show Editor Menu", function() FileManager.showEditorMenuSafe() end)
hs.hotkey.bind(hammer, "x", "Toggle Dragon Grid", function() spoon.DragonGrid:toggleGridDisplay() end)
hs.hotkey.bind(_hyper, "x", "Dragon Grid Settings", function() spoon.DragonGrid:showSettingsMenu() end)
hs.hotkey.bind(hammer, "f", "Open Scrcpy", function() AppManager.open_scrcpy() end)
-- hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. FileManager.getEditor() .. "' ~/.zshrc") end)

-- Help/Documentation

-- Add additional hotkeys for unused keys
-- hs.hotkey.bind(hammer, "y", "Open Countdown Timer", function() AppManager.open_countdown_timer() end)
-- hs.hotkey.bind(_hyper, "y", "Toggle Do Not Disturb", function() AppManager.toggle_do_not_disturb() end)

-- HammerGhost Hotkeys
hs.hotkey.bind(hammer, "m", "Toggle HammerGhost", function() spoon.HammerGhost:toggle() end)
hs.hotkey.bind(_hyper, "m", "HammerGhost Editor", function() spoon.HammerGhost:showActionEditor() end)

-- Additional application and system shortcuts
-- hs.hotkey.bind(hammer, "k", function() AppManager.lock_screen() end)
-- hs.hotkey.bind(_hyper, "esc", function() AppManager.sleep_display() end)

-- Project Management
hs.hotkey.bind(hammer, "j", "Toggle Project Manager", function() ProjectManager.toggleProjectManager() end)
hs.hotkey.bind(_hyper, "j", "Show Active Project Info", function() ProjectManager.showActiveProjectInfo() end)
hs.hotkey.bind(hammer, "k", "Reset Project Manager UI", function() ProjectManager.resetUI() end)
hs.hotkey.bind(_hyper, "k", "Hide Project Manager UI", function() ProjectManager.hideUI() end)

-- Clipboard and productivity tools
-- hs.hotkey.bind(hammer, "c", function() FileManager.showClipboardManager() end)
-- hs.hotkey.bind(_hyper, "c", function() FileManager.clearClipboard() end)

-- Window Location Management (using available letter keys)
hs.hotkey.bind(hammer, "o", "Restore Window to Location 1", function() WindowToggler.restoreToLocation1() end)
hs.hotkey.bind(_hyper, "o", "Save Window to Location 1", function() WindowToggler.saveToLocation1() end)
hs.hotkey.bind(hammer, "n", "Restore Window to Location 2", function() WindowToggler.restoreToLocation2() end)
hs.hotkey.bind(_hyper, "n", "Save Window to Location 2", function() WindowToggler.saveToLocation2() end)

-- Add window toggle hotkeys
hs.hotkey.bind(hammer, "w", "Toggle Between Location 1 and 2", function() WindowToggler.toggleWindowPosition() end)
hs.hotkey.bind(_hyper, "w", "Window Locations Menu", function() WindowToggler.showLocationsMenu() end)
hs.hotkey.bind(hammer, "q", "Clear Saved Window Positions", function() WindowToggler.clearSavedPositions() end)
hs.hotkey.bind(_hyper, "q", "Clear All Saved Locations", function() WindowToggler.clearSavedLocations(true) end)

-- KineticLatch: The Mad Tinker's Window Manipulation Contraption! 🔧⚡
hs.hotkey.bind(hammer, "a", "Toggle KineticLatch", function() spoon.KineticLatch:toggle() end)
hs.hotkey.bind(_hyper, "a", "KineticLatch Status", function() spoon.KineticLatch:showStatus() end)
hs.hotkey.bind(_meta, "a", "KineticLatch Diagnostics", function() spoon.KineticLatch:diagnose() end)

-- Application-specific hotkeys

-- Add a definition for tempFunction at the end of the file
function tempFunction()
    log:i('Temporary function called')
    hs.alert.show("Temporary Function Placeholder")
end



-- Window layout management hotkeys
-- hs.hotkey.bind(hammer, "u", "Save Current Layout", function() saveLayoutWithDialog() end)

-- hs.hotkey.bind(hammer, "i", "Restore Layout", function() restoreLayoutChooser() end)
-- hs.hotkey.bind(_hyper, "y", "Delete Layout", function() deleteLayoutChooser() end)

-- Delete layout keybinding

-- Function to save current window layout with user input
function saveLayoutWithDialog()
    if not hs.dialog then
        hs.alert.show("hs.dialog module not available. Update Hammerspoon.")
        return
    end

    local name = hs.dialog.textPrompt("Save Layout", "Enter a name for this layout:", "", "Save", "Cancel")
    if name and name ~= "" then
        WindowManager.saveCurrentLayout(name)
    end
end

-- Function to restore a saved layout via chooser
function restoreLayoutChooser()
    local layouts = WindowManager.listSavedLayouts()
    if #layouts == 0 then
        hs.alert.show("No saved layouts available")
        return
    end

    local choices = {}
    for _, layout in ipairs(layouts) do
        table.insert(choices, {
            text = layout.name,
            subText = layout.description .. " (" .. layout.windowCount .. " windows)"
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            WindowManager.restoreLayout(choice.text)
        end
    end)

    chooser:placeholderText("Select a layout to restore")
    chooser:choices(choices)
    chooser:show()
end

-- Function to delete a saved layout via chooser
function deleteLayoutChooser()
    local layouts = WindowManager.listSavedLayouts()
    if #layouts == 0 then
        hs.alert.show("No saved layouts available")
        return
    end

    local choices = {}
    for _, layout in ipairs(layouts) do
        table.insert(choices, {
            text = layout.name,
            subText = "Delete: " .. layout.description .. " (" .. layout.windowCount .. " windows)"
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            WindowManager.deleteLayout(choice.text)
        end
    end)

    chooser:placeholderText("Select a layout to DELETE")
    chooser:choices(choices)
    chooser:show()
end
