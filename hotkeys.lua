---@diagnostic disable: lowercase-global, undefined-global
local log = hs.logger.new('Hotkeys', 'debug')
log.i('Initializing hotkey system')

-- Import modules
local WindowManager = require('WindowManager')
local FileManager = require('FileManager')
local AppManager = require('AppManager')
local DeviceManager = require('DeviceManager')
local DragonGrid = require('DragonGrid')

-- Define modifier key combinations
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
_meta = { "cmd", "shift", "alt" }

-- Keybindings
-- Window Management

hs.hotkey.bind(hammer, "1", function() WindowManager.moveToCorner("topLeft") end)
hs.hotkey.bind(_hyper, "1", function() WindowManager.moveToCorner("bottomLeft") end)
hs.hotkey.bind(hammer, "2", function() WindowManager.moveToCorner("topRight") end)
hs.hotkey.bind(_hyper, "2", function() WindowManager.moveToCorner("bottomRight") end)
hs.hotkey.bind(_hyper, "r", function() WindowManager.resetShuffleCounters() end)
hs.hotkey.bind(hammer, "3", function() WindowManager.applyLayout('fullScreen') end)
hs.hotkey.bind(_hyper, "3", function() WindowManager.applyLayout('nearlyFull') end)
hs.hotkey.bind(hammer, "4", function() WindowManager.applyLayout('leftWide') end)
hs.hotkey.bind(_hyper, "4", function() WindowManager.miniShuffle() end)
-- hs.hotkey.bind(hammer, "5", function() WindowManager.applyLayout('splitVertical') end)
-- hs.hotkey.bind(_hyper, "5", function() WindowManager.applyLayout('splitHorizontal') end)
hs.hotkey.bind(hammer, "6", function() WindowManager.moveSide("left", true) end)
hs.hotkey.bind(_hyper, "6", function() WindowManager.moveSide("left", false) end)
hs.hotkey.bind(hammer, "7", function() WindowManager.moveSide("right", true) end)
hs.hotkey.bind(_hyper, "7", function() WindowManager.moveSide("right", false) end)
hs.hotkey.bind(hammer, "8", function() FileManager.showLayoutsMenu() end)
hs.hotkey.bind(_hyper, "8", function() AppManager.open_system_preferences() end)
hs.hotkey.bind(hammer, "9", function() WindowManager.moveWindowMouseCenter() end)
hs.hotkey.bind(_hyper, "9", function() FileManager.openSelectedFile() end)
hs.hotkey.bind(hammer, "0", function() WindowManager.halfShuffle(4, 3) end)
hs.hotkey.bind(_hyper, "0", function() WindowManager.halfShuffle(12, 3) end)

-- Window Movement
hs.hotkey.bind(hammer, "left", function() WindowManager.moveWindow("left") end)
hs.hotkey.bind(_hyper, "left", function() WindowManager.moveToScreen("previous", "right") end)
hs.hotkey.bind(hammer, "right", function() WindowManager.moveWindow("right") end)
hs.hotkey.bind(_hyper, "right", function() WindowManager.moveToScreen("next", "right") end)
hs.hotkey.bind(hammer, "up", function() WindowManager.moveWindow("up") end)
hs.hotkey.bind(_hyper, "up", function() WindowManager.applyLayout('centerScreen') end)
hs.hotkey.bind(hammer, "down", function() WindowManager.moveWindow("down") end)
hs.hotkey.bind(_hyper, "down", function() WindowManager.applyLayout('bottomHalf') end)


-- Window Position Save/Restore
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)
hs.hotkey.bind(_hyper, "F1", function() tempFunction() end)
hs.hotkey.bind(hammer, "F2", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F2", function() tempFunction() end)
hs.hotkey.bind("cmd", "F3", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "F3", function() DeviceManager.toggleUSBLogging() end)
hs.hotkey.bind(_hyper, "F3", function() tempFunction() end)
hs.hotkey.bind(hammer, "F4", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F4", function() tempFunction() end)
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)
hs.hotkey.bind(_hyper, "F5", function() tempFunction() end)
hs.hotkey.bind(hammer, "F6", function() WindowManager.saveWindowPosition() end)
hs.hotkey.bind(_hyper, "F6", function() WindowManager.saveAllWindowPositions() end)
hs.hotkey.bind(hammer, "F7", function() WindowManager.restoreWindowPosition() end)
hs.hotkey.bind(_hyper, "F7", function() WindowManager.restoreAllWindowPositions() end)
hs.hotkey.bind(hammer, "F8", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F8", function() tempFunction() end)
hs.hotkey.bind(hammer, "F9", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F9", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F10", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "F10", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F11", function() tempFunction() end)
-- hs.hotkey.bind(_hyper, "F11", function() tempFunction() end)
-- hs.hotkey.bind(hammer, "F12", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F12", function() tempFunction() end)

-- Application Launching
hs.hotkey.bind(hammer, "p", function() AppManager.open_pycharm() end)
hs.hotkey.bind(_hyper, "p", function() AppManager.open_cursor() end)
hs.hotkey.bind(hammer, "b", function() AppManager.open_arc() end)
hs.hotkey.bind(_hyper, "b", function() AppManager.open_chrome() end)
hs.hotkey.bind(hammer, "d", function() AppManager.open_anythingllm() end)
hs.hotkey.bind(_hyper, "d", function() AppManager.open_mongodb() end)
hs.hotkey.bind(hammer, "l", function() AppManager.open_logi() end)
hs.hotkey.bind(_hyper, "l", function() AppManager.open_system() end)
hs.hotkey.bind(hammer, "s", function() AppManager.open_slack() end)
hs.hotkey.bind(hammer, "g", function() AppManager.open_github() end)
hs.hotkey.bind(hammer, "`", function() AppManager.open_cursor() end)
hs.hotkey.bind(_hyper, "`", function() AppManager.open_vscode() end)
hs.hotkey.bind(hammer, "Tab", function() AppManager.open_mission_control() end)
hs.hotkey.bind(_hyper, "Tab", function() AppManager.open_launchpad() end)
hs.hotkey.bind(hammer, "t", function() AppManager.open_barrier() end)

-- File Management
hs.hotkey.bind(hammer, "i", function() FileManager.openMostRecentImage() end)
hs.hotkey.bind(hammer, "e", function() FileManager.showFileMenu() end)
hs.hotkey.bind(_hyper, "e", function() FileManager.showEditorMenu() end)

-- Device Management

-- Dragon Grid
hs.hotkey.bind(hammer, "x", function() DragonGrid.toggleDragonGrid() end)
hs.hotkey.bind(_hyper, "x", function() DragonGrid.showSettingsMenu() end)

-- Misc
hs.hotkey.bind(hammer, "f", function() hs.execute("open -a '/opt/homebrew/bin/scrcpy -S'") end)
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. FileManager.getEditor() .. "' ~/.zshrc") end)

-- Help/Documentation
hs.hotkey.bind(hammer, "Space", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", function() showHyperList() end)

-- Add additional hotkeys for unused keys
hs.hotkey.bind(hammer, "y", function() AppManager.open_countdown_timer() end)
hs.hotkey.bind(_hyper, "y", function() AppManager.toggle_do_not_disturb() end)

hs.hotkey.bind(hammer, "m", function() AppManager.toggle_media_play_pause() end)
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. FileManager.getEditor() .. "' ~/.zshrc") end)

-- Additional application and system shortcuts
hs.hotkey.bind(hammer, "k", function() AppManager.lock_screen() end)
hs.hotkey.bind(_hyper, "k", function() AppManager.sleep_display() end)

-- Clipboard and productivity tools
hs.hotkey.bind(hammer, "c", function() FileManager.showClipboardManager() end)
hs.hotkey.bind(_hyper, "c", function() FileManager.clearClipboard() end)

-- Screen and display management
hs.hotkey.bind(hammer, "5", function() WindowManager.applyLayout('splitVertical') end)
hs.hotkey.bind(_hyper, "5", function() WindowManager.applyLayout('splitHorizontal') end)

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
function showHammerList()
    hs.alert.show("\
    P     -- PyCharm                                         B     -- Arc Browser  \
    D     -- AnythingLLM                                Y     -- Countdown Timer  \
    L     -- Logi Options+                                F     -- Scrcpy  \
    M     -- Media Play/Pause                        S     -- Slack  \
    G     -- GitHub Desktop                           E     -- Edit File Menu  \
    T     -- Barrier                                              F1    -- Toggle HS Console  \
    F2    -- Post S22                                        F3    -- Toggle USB Logging  \
    F4    -- Toggle Key Logging                   F5    -- Reload HS  \
    F6    -- Save Window Position              F7    -- Restore Window Position  \
    F8    -- Set Target Window                    0     -- Horizontal Shuffle  \
    1     -- Move Top-Left Corner                2     -- Move Top-Right Corner  \
    3     -- Full Screen                                     4     -- Move Window 95/72 Left Side  \
    6     -- Small Left Side                             7     -- Small Right Side  \
    8     -- Layouts Menu                              9     -- Move Window to Mouse Center  \
    Left  -- Move Window Left                   Right -- Move Window Right  \
    Up    -- Move Window Up                     Down  -- Move Window Down  \
    -     -- Show This List                               `     -- Cursor  \
    Tab   -- Mission Control  \
    ")
end

function showHyperList()
    hs.alert.show("\
    W     -- Aclock Show  \
    P     -- Open Cursor  \
    B     -- Chrome  \
    D     -- MongoDB Compass  \
    F3    -- Shuffle Layouts  \
    F6    -- Save All Window Positions  \
    F7    -- Restore All Window Positions  \
    F11   -- Move Window One Space Left  \
    F12   -- Move Window One Space Right  \
    0     -- Vertical Shuffle (4 sections)  \
    1     -- Move Window Bottom-Left Corner  \
    2     -- Move Window Bottom-Right Corner  \
    3     -- 80% Full Screen Centered  \
    4     -- Mini Shuffle  \
    6     -- Full Left Half  \
    7     -- Full Right Half  \
    9     -- Open Selected File  \
    Left  -- Move to Previous Screen  \
    Right -- Move to Next Screen  \
    -     -- Show This List  \
    `     -- Visual Studio Code  \
    Tab   -- Launchpad  \
    R     -- Reset Window Shuffle Counters  \
    ")
end

-- Add a definition for tempFunction at the end of the file, before the help text functions
function tempFunction()
    log.i('Temporary function called')
    hs.alert.show("Temporary Function Placeholder")
end
