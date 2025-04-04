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
hs.hotkey.bind(hammer, "0", function() WindowManager.halfShuffle(4, 3) end)
hs.hotkey.bind(_hyper, "0", function() WindowManager.halfShuffle(12, 3) end)
hs.hotkey.bind(_hyper, "r", function() WindowManager.resetShuffleCounters() end)
hs.hotkey.bind(hammer, "3", function() WindowManager.applyLayout('fullScreen') end)
hs.hotkey.bind(_hyper, "3", function() WindowManager.applyLayout('nearlyFull') end)
hs.hotkey.bind(hammer, "4", function() WindowManager.applyLayout('leftWide') end)
hs.hotkey.bind(_hyper, "4", function() WindowManager.miniShuffle() end)
hs.hotkey.bind(hammer, "6", function() WindowManager.moveSide("left", true) end)
hs.hotkey.bind(_hyper, "6", function() WindowManager.moveSide("left", false) end)
hs.hotkey.bind(hammer, "7", function() WindowManager.moveSide("right", true) end)
hs.hotkey.bind(_hyper, "7", function() WindowManager.moveSide("right", false) end)

hs.hotkey.bind(hammer, "9", function() WindowManager.moveWindowMouseCenter() end)
hs.hotkey.bind(_hyper, "9", function() FileManager.openSelectedFile() end)

-- Window Movement
hs.hotkey.bind(hammer, "left", function() WindowManager.moveWindow("left") end)
hs.hotkey.bind(_hyper, "left", function() WindowManager.moveToScreen("previous", "right") end)
hs.hotkey.bind(hammer, "right", function() WindowManager.moveWindow("right") end)
hs.hotkey.bind(_hyper, "right", function() WindowManager.moveToScreen("next", "right") end)
hs.hotkey.bind(hammer, "up", function() WindowManager.moveWindow("up") end)
hs.hotkey.bind(_hyper, "up", function() tempFunction() end)
hs.hotkey.bind(hammer, "down", function() WindowManager.moveWindow("down") end)
hs.hotkey.bind(_hyper, "down", function() tempFunction() end)


-- Window Position Save/Restore
hs.hotkey.bind(hammer, "F6", function() WindowManager.saveWindowPosition() end)
hs.hotkey.bind(_hyper, "F6", function() WindowManager.saveAllWindowPositions() end)
hs.hotkey.bind(hammer, "F7", function() WindowManager.restoreWindowPosition() end)
hs.hotkey.bind(_hyper, "F7", function() WindowManager.restoreAllWindowPositions() end)

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
hs.hotkey.bind("cmd", "F3", function() AppManager.open_github() end)
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
hs.hotkey.bind(hammer, "F3", function() DeviceManager.toggleUSBLogging() end)

-- Dragon Grid
hs.hotkey.bind(hammer, "d", function() DragonGrid.toggleDragonGrid() end)

-- Misc
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)
hs.hotkey.bind(hammer, "f", function() hs.execute("open -a '/opt/homebrew/bin/scrcpy -S'") end)
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. FileManager.getEditor() .. "' ~/.zshrc") end)

-- Help/Documentation
hs.hotkey.bind(hammer, "Space", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", function() showHyperList() end)

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
