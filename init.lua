dofile(hs.configdir .. "/loadConfig.lua")
dofile(hs.configdir .. "/WindowManager.lua")
hs.loadSpoon('EmmyLua')

-- Load HyperLogger for better debugging with clickable log messages
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('Main', 'info')
log:i('Starting Hammerspoon initialization')

-- Enable AppleScript support
hs.allowAppleScript(true)
log:i('AppleScript support enabled')
-- Load core modules
require("hs.ipc")
log:d('Core IPC module loaded')
require("ProjectManager")
log:d('Project Manager module loaded')
-- dofile(hs.configdir .. "/workspace.lua")
-- dofile(hs.configdir .. "/test_balena_handler.lua")
-- dofile(hs.configdir .. "/temp.lua")

-- Load secrets management
local secrets = require("load_secrets")
log:d('Secrets module loaded')

-- Configure environment variables from secrets
local AWSIP = secrets.get("AWSIP", "localhost")
local AWSIP2 = secrets.get("AWSIP2", "localhost")
local MCP_PORT = secrets.get("MCP_PORT", "8000")
log:d('Environment variables configured: ' .. AWSIP .. ', ' .. AWSIP2 .. ', ' .. MCP_PORT)

-- Load HammerGhost
log:i('Loading HammerGhost spoon')
hs.loadSpoon("HammerGhost")
log:d('HammerGhost hotkeys bound')

-- Configure Console Dark Mode
log:i('Configuring console appearance')
local darkMode = {
    backgroundColor = { white = 0.1 },    -- Dark gray, almost black
    textColor = { white = 0.8 },          -- Light gray
    cursorColor = { white = 0.8 },        -- Light gray cursor
    selectionColor = { red = 0.3, blue = 0.4, green = 0.35 }, -- Subtle blue-green selection
    fontName = "Menlo",                   -- Use Menlo font
    fontSize = 12                         -- 12pt font size
}

-- Apply console styling
hs.console.darkMode(true)                 -- Enable system dark mode for the window frame
hs.console.windowBackgroundColor({
    red = 0.11,                          -- Slightly different than content background
    green = 0.11,                        -- to create a subtle depth effect
    blue = 0.11,
    alpha = 0.95
})
hs.console.outputBackgroundColor(darkMode.backgroundColor)
hs.console.consoleCommandColor(darkMode.textColor)
hs.console.consolePrintColor(darkMode.textColor)
hs.console.consoleResultColor({ white = 0.9 }) -- Slightly dimmer than regular text
hs.console.alpha(0.95)                    -- Slightly transparent
hs.console.titleVisibility("hidden")      -- Hide the title bar for a cleaner look
log:d('Console appearance configured')

-- Wait a bit for the console window to be ready before setting appearance
hs.timer.doAfter(0.1, function()
    log:d('Setting console window appearance')
    local consoleWindow = hs.console.hswindow()
    if consoleWindow and consoleWindow.setAppearance then
        consoleWindow:setAppearance(hs.drawing.windowAppearance.darkAqua)
        log:d('Console appearance set to darkAqua')
    else
        log:d('Failed to set console appearance - window or method not available')
    end
end)

-- Create and configure console toolbar
log:i('Creating console toolbar')
local toolbar = require("hs.webview.toolbar")
local consoleTB = toolbar.new("myConsole", {
    {
        id = "editConfig",
        label = "Edit Config",
            image = hs.image.imageFromName("NSTouchBarListViewTemplate"),
        fn = function()
            local editor = "cursor"  -- Use cursor as the editor
            local configFile = hs.configdir .. "/init.lua"
            if hs.fs.attributes(configFile) then
                    log:d('Opening config file in editor: ' .. configFile)
                hs.task.new("/usr/bin/open", nil, {"-a", editor, configFile}):start()
            else
                    log:e('Config file not found: ' .. configFile)
                hs.alert.show("Could not find config file")
            end
        end
    },
    {
        id = "reloadConfig",
        label = "Reload",
        image = hs.image.imageFromName("NSRefreshTemplate"),
        fn = function()
                log:i('Reloading Hammerspoon configuration')
            hs.reload()
            hs.alert.show("Config reloaded")
        end
    }
})
:canCustomize(true)
:autosaves(true)
log:d('Console toolbar created')

-- Apply the toolbar after a short delay to ensure console is ready
hs.timer.doAfter(0.2, function()
    log:d('Setting console toolbar')
    hs.console.toolbar(consoleTB)
end)




-- Load hotkeys module
log:d('Loading hotkeys module')
dofile(hs.configdir .. "/hotkeys.lua")

-- Load HotkeyManager module for dynamic hotkey lists
log:d('Loading HotkeyManager module')
local HotkeyManager = require('HotkeyManager')
-- Configure HotkeyManager's display window
HotkeyManager.configureDisplay({
    width = 1000, -- Wider window
    height = 700, -- Taller window
    fadeInDuration = 0.3,
    fadeOutDuration = 0.2,
    cornerRadius = 12
})

log:i('HotkeyManager loaded with ' ..
    #HotkeyManager.bindings.hammer .. ' hammer bindings and ' ..
    #HotkeyManager.bindings.hyper .. ' hyper bindings')
log:i('Hammerspoon initialization complete')
hs.alert.show("Config loaded")

-- Initialize modules
-- Load DragonGrid as a Spoon instead of requiring the module

hs.loadSpoon("DragonGrid")

local AppManager = require('AppManager')
local FileManager = require('FileManager')

local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

-- Watch config for changes
local configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
local hotloadhammer = os.getenv("HAMMER_HOTLOAD")
if hotloadhammer then
    configFileWatcher:start()
    log:d("Hotloading hammerspoon")
else
    log:d("Hotload Disabled")
end
