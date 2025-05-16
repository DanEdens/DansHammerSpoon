-- Hammerspoon init.lua
-- Primary configuration file for Hammerspoon
local __FILE__ = 'init.lua'
-- Enable AppleScript support
hs.allowAppleScript(true)
require("hs.ipc")
-- Load HyperLogger for better debugging with clickable log messages
local HyperLogger = require('HyperLogger')
-- Create a main application logger and expose it globally
local log = HyperLogger.new('HammerspoonApp')
-- Make the logger available globally for other modules
_G.AppLogger = log
log:d('Logger initialized', __FILE__, 10)

-- Load secrets management first so environment variables are available
local secrets = require("load_secrets")
log:d('Secrets module loaded', __FILE__, 14)

-- Configure environment variables from secrets
local AWSIP = secrets.get("AWSIP", "localhost")
local AWSIP2 = secrets.get("AWSIP2", "localhost")
local MCP_PORT = secrets.get("MCP_PORT", "8000")
log:d('Environment variables configured', __FILE__, 20)

-- Configure Console Dark Mode
log:d('Configuring console appearance', __FILE__, 23)
local darkMode = {
    backgroundColor = { white = 0.1 },    -- Dark gray, almost black
    textColor = { red = 0.3, green = 0.7, blue = 1.0 },       -- Light gray
    cursorColor = { white = 0.8 },        -- Light gray cursor
    selectionColor = { red = 0.3, blue = 0.4, green = 0.35 }, -- Subtle blue-green selection
    fontName = "Menlo",                   -- Use Menlo font
    fontSize = 18                                             -- 12pt font size
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
hs.console.consoleFont({ name = darkMode.fontName, size = darkMode.fontSize })
hs.console.consoleResultColor(darkMode.textColor) -- Slightly dimmer than regular text
hs.console.alpha(0.95)                    -- Slightly transparent
hs.console.titleVisibility("hidden")      -- Hide the title bar for a cleaner look
log:d('Console appearance configured', __FILE__, 47)

-- Create and configure console toolbar
log:i('Creating console toolbar', __FILE__, 50)
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
                    log:d('Opening config file in editor: ' .. configFile, __FILE__, 62)
                hs.task.new("/usr/bin/open", nil, {"-a", editor, configFile}):start()
            else
                    log:e('Config file not found: ' .. configFile, __FILE__, 65)
                hs.alert.show("Could not find config file")
            end
        end
    },
    {
        id = "reloadConfig",
        label = "Reload",
        image = hs.image.imageFromName("NSRefreshTemplate"),
        fn = function()
                log:i('Reloading Hammerspoon configuration', __FILE__, 74)
                hs.console.clearConsole()
                hs.reload()
            hs.alert.show("Config reloaded")
        end
    }
})
:canCustomize(true)
:autosaves(true)

-- Apply the toolbar immediately
hs.console.toolbar(consoleTB)
log:d('Console toolbar created', __FILE__, 85)

-- Apply window appearance after a short delay to ensure console is ready
hs.timer.doAfter(0.2, function()
    log:d('Setting console window appearance')
    local consoleWindow = hs.console.hswindow()
    if consoleWindow and consoleWindow.setAppearance then
        consoleWindow:setAppearance(hs.drawing.windowAppearance.darkAqua)
        log:i('Console appearance set to darkAqua')
    else
        log:d('Failed to set console appearance - window or method not available')
    end
end)

-- Helper function to load modules and expose them globally
function loadModuleGlobally(name)
    if not _G[name] then
        log:d('Loading module: ' .. name, __FILE__, 103)
        local status, module = pcall(require, name)
        if status then
            _G[name] = module
            log:d('Successfully loaded module: ' .. name, __FILE__, 107)
        else
            log:e('Failed to load module: ' .. name .. ' - ' .. tostring(module), __FILE__, 109)
            return nil
        end
    else
        log:d('Module already loaded: ' .. name, __FILE__, 113)
    end
    return _G[name]
end
-- Load core modules in dependency order
spoon_data = loadModuleGlobally('loadConfig') -- Load Spoons first
log:i('Spoons loaded: ' .. table.concat(spoon_data.loaded, ", "), __FILE__, 123)
log:d('Spoons started: ' .. table.concat(spoon_data.started, ", "), __FILE__, 124)

-- Load core system modules in proper order and expose them globally
loadModuleGlobally('WindowManager')
loadModuleGlobally('FileManager')
loadModuleGlobally('AppManager')
loadModuleGlobally('ProjectManager')
loadModuleGlobally('DeviceManager')
loadModuleGlobally('WindowToggler')
log:d('Core system modules loaded', __FILE__, 128)

-- Load hotkeys after all systems are ready
dofile(hs.configdir .. "/hotkeys.lua")
log:d('Hotkeys configured', __FILE__, 132)

-- Load HotkeyManager module for dynamic hotkey lists
log:d('Loading HotkeyManager module', __FILE__, 135)
local HotkeyManager = loadModuleGlobally('HotkeyManager')
-- Configure HotkeyManager's display window
HotkeyManager.configureDisplay({
    width = 1000, -- Wider window
    height = 700, -- Taller window
    fadeInDuration = 0.0,
    fadeOutDuration = 0.0,
    cornerRadius = 12
})

log:i('HotkeyManager loaded with ' ..
    #HotkeyManager.bindings.hammer .. ' hammer bindings and ' ..
    #HotkeyManager.bindings.hyper .. ' hyper bindings', __FILE__, 148)
log:i('Hammerspoon initialization complete', __FILE__, 149)

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
    log:d("Hotload enabled", __FILE__, 169)
else
    log:d("Hotload disabled", __FILE__, 171)
end
