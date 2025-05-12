-- Hammerspoon init.lua
-- Primary configuration file for Hammerspoon

-- Enable AppleScript support
hs.allowAppleScript(true)
require("hs.ipc")
-- Load HyperLogger for better debugging with clickable log messages
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()
log:d('Logger initialized')

-- Load secrets management first so environment variables are available
local secrets = require("load_secrets")
log:d('Secrets module loaded')

-- Configure environment variables from secrets
local AWSIP = secrets.get("AWSIP", "localhost")
local AWSIP2 = secrets.get("AWSIP2", "localhost")
local MCP_PORT = secrets.get("MCP_PORT", "8000")
log:d('Environment variables configured')

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

-- Apply the toolbar immediately
hs.console.toolbar(consoleTB)
log:d('Console toolbar created')

-- Apply window appearance after a short delay to ensure console is ready
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

-- Helper function to load modules and expose them globally
function loadModuleGlobally(name)
    if not _G[name] then
        log:d('Loading module: ' .. name)
        local status, module = pcall(require, name)
        if status then
            _G[name] = module
            log:d('Successfully loaded module: ' .. name)
        else
            log:e('Failed to load module: ' .. name .. ' - ' .. tostring(module))
            return nil
        end
    else
        log:d('Module already loaded: ' .. name)
    end
    return _G[name]
end
-- Load core modules in dependency order
dofile(hs.configdir .. "/loadConfig.lua") -- Load Spoons first
log:d('Spoons loaded')

-- Load core system modules in proper order and expose them globally
loadModuleGlobally('WindowManager')
loadModuleGlobally('FileManager')
loadModuleGlobally('AppManager')
loadModuleGlobally('ProjectManager')
loadModuleGlobally('DeviceManager')
loadModuleGlobally('WindowToggler')
log:d('Core system modules loaded')

-- Load hotkeys after all systems are ready
dofile(hs.configdir .. "/hotkeys.lua")
log:d('Hotkeys configured')

-- Load HotkeyManager module for dynamic hotkey lists
log:d('Loading HotkeyManager module')
local HotkeyManager = loadModuleGlobally('HotkeyManager')
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

-- Configure hot reloading
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
    log:d("Hotload enabled")
else
    log:d("Hotload disabled")
end
