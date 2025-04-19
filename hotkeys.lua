---@diagnostic disable: lowercase-global, undefined-global
-- Use our custom HyperLogger instead of the standard logger
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('Hotkeys', 'debug')
log:i('Initializing hotkey system')

-- Import modules
local WindowManager = require('WindowManager')
local FileManager = require('FileManager')
local AppManager = require('AppManager')
local DeviceManager = require('DeviceManager')
local HotkeyManager = require('HotkeyManager')
local WindowToggler = require('WindowToggler')

-- Define modifier key combinations
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
_meta = { "cmd", "shift", "alt" }

-- Add state tracking for toggling right layouts
local rightLayoutState = {
    isSmall = true
}

function toggleRightLayout()
    rightLayoutState.isSmall = not rightLayoutState.isSmall
    if rightLayoutState.isSmall then
        WindowManager.applyLayout('rightSmall')
        hs.alert.show("Right Small Layout")
    else
        WindowManager.applyLayout('rightHalf')
        hs.alert.show("Right Half Layout")
    end
end
-- Keybindings
-- Window Management

hs.hotkey.bind(hammer, "1", "Move Top-Left Corner", function() WindowManager.applyLayout("topLeft") end)
hs.hotkey.bind(_hyper, "1", "Move Bottom-Left Corner", function() WindowManager.applyLayout("bottomLeft") end)
hs.hotkey.bind(hammer, "2", "Move Top-Right Corner", function() WindowManager.applyLayout("topRight") end)
hs.hotkey.bind(_hyper, "2", "Move Bottom-Right Corner", function() WindowManager.applyLayout("bottomRight") end)
hs.hotkey.bind(_hyper, "r", "Reset Shuffle Counters", function() WindowManager.resetShuffleCounters() end)
hs.hotkey.bind(hammer, "3", "Full Screen", function() WindowManager.applyLayout('fullScreen') end)
hs.hotkey.bind(_hyper, "3", "Nearly Full Screen", function() WindowManager.applyLayout('nearlyFull') end)
hs.hotkey.bind(hammer, "4", "Left Wide Layout", function() WindowManager.applyLayout('leftWide') end)
hs.hotkey.bind(_hyper, "4", "Mini Shuffle", function() WindowManager.miniShuffle() end)

-- Screen and display management
hs.hotkey.bind(hammer, "5", "Split Vertical", function() WindowManager.applyLayout('splitVertical') end)
hs.hotkey.bind(_hyper, "5", "Split Horizontal", function() WindowManager.applyLayout('splitHorizontal') end)
hs.hotkey.bind(hammer, "6", "Left Small Layout", function() WindowManager.applyLayout('leftSmall') end)
hs.hotkey.bind(_hyper, "6", "Left Half Layout", function() WindowManager.applyLayout('leftHalf') end)
hs.hotkey.bind(hammer, "7", "Toggle Right Layout", function() toggleRightLayout() end)
hs.hotkey.bind(_hyper, "7", "Right Half Layout", function() WindowManager.applyLayout('rightHalf') end)
hs.hotkey.bind(hammer, "8", "Show Layouts Menu", function() FileManager.showLayoutsMenu() end)
hs.hotkey.bind(_hyper, "8", "Open System Preferences", function() AppManager.open_system_preferences() end)
hs.hotkey.bind(hammer, "9", "Move Window to Mouse", function() WindowManager.moveWindowMouseCenter() end)
hs.hotkey.bind(_hyper, "9", "Open Selected File", function() FileManager.openSelectedFile() end)
hs.hotkey.bind(hammer, "0", "Horizontal Shuffle", function() WindowManager.halfShuffle(4, 3) end)
hs.hotkey.bind(_hyper, "0", "Vertical Shuffle", function() WindowManager.halfShuffle(12, 3) end)

-- Window Movement
hs.hotkey.bind(hammer, "left", "Move Window Left", function() WindowManager.moveWindow("left") end)
hs.hotkey.bind(_hyper, "left", "Move to Previous Screen", function() WindowManager.moveToScreen("previous", "right") end)
hs.hotkey.bind(hammer, "right", "Move Window Right", function() WindowManager.moveWindow("right") end)
hs.hotkey.bind(_hyper, "right", "Move to Next Screen", function() WindowManager.moveToScreen("next", "right") end)
hs.hotkey.bind(hammer, "up", "Move Window Up", function() WindowManager.moveWindow("up") end)
hs.hotkey.bind(_hyper, "up", "Center Screen Layout", function() WindowManager.applyLayout('centerScreen') end)
hs.hotkey.bind(hammer, "down", "Move Window Down", function() WindowManager.moveWindow("down") end)
hs.hotkey.bind(_hyper, "down", "Bottom Half Layout", function() WindowManager.applyLayout('bottomHalf') end)


-- Window Position Save/Restore
hs.hotkey.bind(hammer, "F1", "Toggle Console", function() hs.toggleConsole() end)
hs.hotkey.bind(_hyper, "F1", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F2", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F2", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind("cmd", "F3", "Open GitHub", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "F3", "Toggle USB Logging", function() DeviceManager.toggleUSBLogging() end)
hs.hotkey.bind(_hyper, "F3", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F4", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F4", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F5", "Reload Hammerspoon", function() hs.reload() end)
hs.hotkey.bind(_hyper, "F5", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F6", "Save Window Position", function() WindowManager.saveWindowPosition() end)
hs.hotkey.bind(_hyper, "F6", "Save All Window Positions", function() WindowManager.saveAllWindowPositions() end)
hs.hotkey.bind(hammer, "F7", "Restore Window Position", function() WindowManager.restoreWindowPosition() end)
hs.hotkey.bind(_hyper, "F7", "Restore All Window Positions", function() WindowManager.restoreAllWindowPositions() end)
hs.hotkey.bind(hammer, "F8", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F8", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(hammer, "F9", "Temporary Function", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F9", "Temporary Function", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F10", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "F10", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F11", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "F11", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F12", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F12", "Temporary Function", function() tempFunction() end)

-- Application Launching
hs.hotkey.bind(hammer, "p", "Open PyCharm", function() AppManager.open_pycharm() end)
hs.hotkey.bind(_hyper, "p", "Open Cursor", function() AppManager.open_cursor() end)
hs.hotkey.bind(hammer, "b", "Open Arc Browser", function() AppManager.open_arc() end)
hs.hotkey.bind(_hyper, "b", "Open Chrome", function() AppManager.open_chrome() end)
hs.hotkey.bind(hammer, "d", "Open AnythingLLM", function() AppManager.open_anythingllm() end)
hs.hotkey.bind(_hyper, "d", "Open MongoDB Compass", function() AppManager.open_mongodb() end)
hs.hotkey.bind(hammer, "l", "Open Logi Options+", function() AppManager.open_logi() end)
hs.hotkey.bind(_hyper, "l", "Open System Settings", function() AppManager.open_system() end)
hs.hotkey.bind(hammer, "s", "Open Slack", function() AppManager.open_slack() end)
hs.hotkey.bind(hammer, "g", "Open GitHub Desktop", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "`", "Open Cursor", function() AppManager.open_cursor() end)
hs.hotkey.bind(_hyper, "`", "Open VS Code", function() AppManager.open_vscode() end)
hs.hotkey.bind(hammer, "Tab", "Open Mission Control", function() AppManager.open_mission_control() end)
hs.hotkey.bind(_hyper, "Tab", "Open Launchpad", function() AppManager.open_launchpad() end)
hs.hotkey.bind(hammer, "t", "Open Barrier", function() AppManager.open_barrier() end)

-- File Management
hs.hotkey.bind(hammer, "i", "Open Most Recent Image", function() FileManager.openMostRecentImage() end)
hs.hotkey.bind(hammer, "e", "Show File Menu", function() FileManager.showFileMenu() end)
hs.hotkey.bind(_hyper, "e", "Show Editor Menu", function() FileManager.showEditorMenu() end)

-- Device Management

-- Dragon Grid (now using the Spoon)
hs.hotkey.bind(hammer, "x", "Toggle Dragon Grid", function() spoon.DragonGrid:toggleGridDisplay() end)
hs.hotkey.bind(_hyper, "x", "Dragon Grid Settings", function() spoon.DragonGrid:showSettingsMenu() end)

-- Misc
hs.hotkey.bind(hammer, "f", "Open Scrcpy", function() hs.execute("open -a '/opt/homebrew/bin/scrcpy'") end)
-- hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. FileManager.getEditor() .. "' ~/.zshrc") end)

-- Help/Documentation
hs.hotkey.bind(hammer, "Space", "Show Hammer Hotkeys", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", "Show Hyper Hotkeys", function() showHyperList() end)

-- Add additional hotkeys for unused keys
hs.hotkey.bind(hammer, "y", "Open Countdown Timer", function() AppManager.open_countdown_timer() end)
hs.hotkey.bind(_hyper, "y", "Toggle Do Not Disturb", function() AppManager.toggle_do_not_disturb() end)

-- HammerGhost Hotkeys
hs.hotkey.bind(hammer, "m", "Toggle HammerGhost", function() spoon.HammerGhost:toggle() end)
hs.hotkey.bind(_hyper, "m", "HammerGhost Editor", function() spoon.HammerGhost:showActionEditor() end)

-- Additional application and system shortcuts
-- hs.hotkey.bind(hammer, "k", function() AppManager.lock_screen() end)
-- hs.hotkey.bind(_hyper, "k", function() AppManager.sleep_display() end)

-- Clipboard and productivity tools
-- hs.hotkey.bind(hammer, "c", function() FileManager.showClipboardManager() end)
-- hs.hotkey.bind(_hyper, "c", function() FileManager.clearClipboard() end)

-- -- Add tempFunction for remaining letters
-- hs.hotkey.bind(hammer, "a", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "a", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "g", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "h", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "h", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "i", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "j", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "j", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "n", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "n", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "o", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "o", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "q", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "q", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "r", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "s", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "t", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "u", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "u", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "v", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "v", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "w", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "w", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "x", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "x", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "z", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "z", function() tempFunction() end)

-- -- Add tempFunction for remaining function keys


-- -- Add tempFunction for remaining special keys
-- hs.hotkey.bind(hammer, "-", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "-", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "=", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "=", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "[", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "[", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "]", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "]", function() tempFunction() end)
-- hs.hotkey.bind(hammer, ";", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, ";", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "'", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "'", function() tempFunction() end)
-- hs.hotkey.bind(hammer, ",", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, ",", function() tempFunction() end)
-- hs.hotkey.bind(hammer, ".", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, ".", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "/", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "/", function() tempFunction() end)
-- Help text functions

-- Add a definition for tempFunction at the end of the file
function tempFunction()
    log:i('Temporary function called')
    hs.alert.show("Temporary Function Placeholder")
end

-- Add window toggle hotkeys
hs.hotkey.bind(hammer, "w", "Toggle Window Position", function() WindowToggler.toggleWindowPosition() end)
hs.hotkey.bind(_hyper, "w", "List Saved Windows", function() WindowToggler.listSavedWindows() end)
hs.hotkey.bind(hammer, "q", "Clear Saved Window Positions", function() WindowToggler.clearSavedPositions() end)
