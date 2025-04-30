dofile(hs.configdir .. "/loadConfig.lua")
dofile(hs.configdir .. "/WindowManager.lua")

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

-- Custom Layouts API Server configuration
-- local apiServerProcess = nil

-- -- Function to start the Custom Layouts API server
-- local function startLayoutAPIServer()
--     -- Kill any existing API server process
--     if apiServerProcess then
--         log:i("Terminating existing API server process")
--         apiServerProcess:terminate()
--         apiServerProcess = nil
--     end

--     local script = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/.hammerspoon/start_layout_api.sh")

--     if not script then
--         log:e("API server script not found at " .. os.getenv("HOME") .. "/.hammerspoon/start_layout_api.sh")
--         return
--     end

--     log:i("Starting Custom Layouts API server")
--     apiServerProcess = hs.task.new(script, nil)
--     apiServerProcess:start()

--     -- Check if the server started correctly after a short delay
--     hs.timer.doAfter(3, function()
--         if apiServerProcess:isRunning() then
--             log:i("Custom Layouts API server started successfully")
--         else
--             log:e("Failed to start Custom Layouts API server")
--         end
--     end)
-- end

-- -- Start the API server when Hammerspoon initializes
-- startLayoutAPIServer()

-- Add shutdown handler to clean up the API server process
-- hs.shutdownCallback = function()
--     if apiServerProcess and apiServerProcess:isRunning() then
--         log:i("Shutting down Custom Layouts API server")
--         apiServerProcess:terminate()
--     end
-- end
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

-- Macro Tree System
local macroTree = {
    Applications = {
        {
            name = "Development",
            icon = "NSApplicationIcon",
            items = {
                {
                    name = "Open VSCode",
                    icon = "NSEditTemplate",
                    fn = function() hs.application.launchOrFocus("Visual Studio Code") end
                },
                {
                    name = "Open PyCharm",
                    icon = "NSAdvanced",
                    fn = function() hs.application.launchOrFocus("PyCharm Community Edition") end
                },
                {
                    name = "Open Cursor",
                    icon = "NSComputer",
                    fn = function() hs.application.launchOrFocus("cursor") end
                }
            }
        },
        {
            name = "Browsers",
            icon = "NSNetwork",
            items = {
                {
                    name = "Open Chrome",
                    icon = "NSGlobe",
                    fn = function() hs.application.launchOrFocus("Google Chrome") end
                },
                {
                    name = "Open Arc",
                    icon = "NSBonjour",
                    fn = function() hs.application.launchOrFocus("Arc") end
                }
            }
        },
        {
            name = "Communication",
            icon = "NSChat",
            items = {
                {
                    name = "Open Slack",
                    icon = "NSShareTemplate",
                    fn = function() hs.application.launchOrFocus("Slack") end
                }
            }
        }
    },
    WindowManagement = {
        {
            name = "Basic Actions",
            icon = "NSPreferencesGeneral",
            items = {
                {
                    name = "Center Window",
                    icon = "NSCenterTextAlignment",
                    fn = function() local win = hs.window.focusedWindow(); if win then win:centerOnScreen() end end
                },
                {
                    name = "Full Screen",
                    icon = "NSEnterFullScreenTemplate",
                    fn = function() local win = hs.window.focusedWindow(); if win then local f = win:screen():frame(); win:setFrame(f) end end
                },
                {
                    name = "Save Position",
                    icon = "NSSaveTemplate",
                    fn = saveWindowPosition
                },
                {
                    name = "Restore Position",
                    icon = "NSRefreshTemplate",
                    fn = restoreWindowPosition
                }
            }
        },
        {
            name = "Screen Positions",
            icon = "NSMultipleWindows",
            items = {
                {
                    name = "Left Half",
                    icon = "NSGoLeftTemplate",
                    fn = function() moveSide("left", false) end
                },
                {
                    name = "Right Half",
                    icon = "NSGoRightTemplate",
                    fn = function() moveSide("right", false) end
                },
                {
                    name = "Top Left",
                    icon = "NSGoBackTemplate",
                    fn = function() moveToCorner("topLeft") end
                },
                {
                    name = "Top Right",
                    icon = "NSGoForwardTemplate",
                    fn = function() moveToCorner("topRight") end
                },
                {
                    name = "Bottom Left",
                    icon = "NSGoDownTemplate",
                    fn = function() moveToCorner("bottomLeft") end
                },
                {
                    name = "Bottom Right",
                    icon = "NSGoUpTemplate",
                    fn = function() moveToCorner("bottomRight") end
                }
            }
        },
        {
            name = "Layouts",
            icon = "NSListViewTemplate",
            items = {
                {
                    name = "Mini Layout",
                    icon = "NSFlowViewTemplate",
                    fn = miniShuffle
                },
                {
                    name = "Horizontal Split",
                    icon = "NSColumnViewTemplate",
                    fn = function() halfShuffle(true, 3) end
                },
                {
                    name = "Vertical Split",
                    icon = "NSTableViewTemplate",
                    fn = function() halfShuffle(false, 4) end
                }
            }
        }
    },
    System = {
        {
            name = "Power",
            icon = "NSStatusAvailable",
            items = {
                {
                    name = "Lock Screen",
                    icon = "NSLockLockedTemplate",
                    fn = function() hs.caffeinate.lockScreen() end
                },
                {
                    name = "Show Desktop",
                    icon = "NSHomeTemplate",
                    fn = function() hs.spaces.toggleMissionControl() end
                }
            }
        },
        {
            name = "Configuration",
            icon = "NSPreferencesGeneral",
            items = {
                {
                    name = "Edit Config",
                    icon = "NSEditTemplate",
                    fn = function()
                        local editor = "cursor"
                        local configFile = hs.configdir .. "/init.lua"
                        if hs.fs.attributes(configFile) then
                            hs.task.new("/usr/bin/open", nil, {"-a", editor, configFile}):start()
                        end
                    end
                },
                {
                    name = "Reload Config",
                    icon = "NSRefreshTemplate",
                    fn = function() hs.reload(); hs.alert.show("Config reloaded") end
                }
            }
        }
    }
}

-- Create the macro chooser
local breadcrumbs = {}
local macroChooser = hs.chooser.new(function(choice)
    if not choice then
        -- If user cancelled and we're in a subcategory, go back one level
        if #breadcrumbs > 0 then
            table.remove(breadcrumbs)
            showCurrentLevel()
        end
        return
    end

    if choice.fn then
        -- Execute the macro
        choice.fn()
        breadcrumbs = {}
    else
        -- Navigate to subcategory
        table.insert(breadcrumbs, choice.text)
        showCurrentLevel()
    end
end)

-- Function to get current level in the macro tree based on breadcrumbs
function getCurrentLevel()
    local current = macroTree
    for _, crumb in ipairs(breadcrumbs) do
        for _, category in pairs(current) do
            if category.name == crumb then
                current = category.items
                break
            end
        end
    end
    return current
end

-- Function to show current level in the chooser
function showCurrentLevel()
    local current = getCurrentLevel()
    local choices = {}

    -- Add back button if we're in a subcategory
    if #breadcrumbs > 0 then
        table.insert(choices, {
            text = "← Back",
            subText = "Return to previous menu",
            image = hs.image.imageFromName("NSGoLeftTemplate")
        })
    end

    -- Add items from current level
    for name, category in pairs(current) do
        -- Create image from system icon or fallback to text icon
        local img
        if category.icon then
            if category.icon:len() <= 2 then
                -- For emoji/text icons, create an attributed string
                img = hs.styledtext.new(category.icon, {font = {size = 16}})
            else
                -- For system icons, use imageFromName
                img = hs.image.imageFromName(category.icon) or
                      hs.image.imageFromName("NSActionTemplate")
            end
        end

        table.insert(choices, {
            text = category.name,
            subText = category.items and "Open submenu" or "Execute action",
            image = img,
            fn = category.items and nil or category.fn
        })
    end

    -- Update chooser title to show breadcrumbs
    local title = "Macro Tree"
    if #breadcrumbs > 0 then
        title = table.concat(breadcrumbs, " → ")
    end
    macroChooser:placeholderText(title)

    macroChooser:choices(choices)
    macroChooser:show()
end

-- Function to show macro tree
function showMacroTree()
    breadcrumbs = {}
    showCurrentLevel()
end


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
-- configFileWatcher:start()




-- -- Hammerspoon initialization
-- -- ===================================================================

-- local logger = hs.logger.new("Init", "debug")
-- logger.i("Starting Hammerspoon initialization")

-- -- Customize menu bar icon
-- hs.menuIcon(true)

-- -- Disable animation for window resizing
-- hs.window.animationDuration = 0

-- -- Experimental: API Server Process
-- local apiServerProcess = nil

-- -- Function to start the Custom Layouts API server
-- local function startLayoutAPIServer()
--     -- Kill any existing API server process
--     if apiServerProcess then
--         logger.i("Terminating existing API server process")
--         apiServerProcess:terminate()
--         apiServerProcess = nil
--     end

--     local script = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/.hammerspoon/start_layout_api.sh")

--     if not script then
--         logger.e("API server script not found at " .. os.getenv("HOME") .. "/.hammerspoon/start_layout_api.sh")
--         return
--     end

--     logger.i("Starting Custom Layouts API server")
--     apiServerProcess = hs.task.new(script, nil)
--     apiServerProcess:start()

--     -- Check if the server started correctly after a short delay
--     hs.timer.doAfter(3, function()
--         if apiServerProcess:isRunning() then
--             logger.i("Custom Layouts API server started successfully")
--         else
--             logger.e("Failed to start Custom Layouts API server")
--         end
--     end)
-- end

-- -- Start the API server when Hammerspoon initializes
-- startLayoutAPIServer()

-- -- Add shutdown handler to clean up the API server process
-- hs.shutdownCallback = function()
--     if apiServerProcess and apiServerProcess:isRunning() then
--         logger.i("Shutting down Custom Layouts API server")
--         apiServerProcess:terminate()
--     end
-- end

-- -- ... existing initialization code ...

-- -- Load SpoonInstall manager
-- hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall.use_syncinstall = true

-- -- Ensure all required spoons are installed
-- local spoons = { "DragonGrid", "HammerGhost" }
-- for _, spoonName in ipairs(spoons) do
--     if not hs.spoons.use(spoonName) then
--         logger.e("Failed to load " .. spoonName .. " spoon")
--     end
-- end

-- -- Define variables
-- hammer = { "cmd", "ctrl", "alt" }
-- _hyper = { "cmd", "shift", "ctrl", "alt" }

-- -- Load modules
-- local WindowManager = require('WindowManager')
-- local HotkeyManager = require('HotkeyManager')
-- local loadConfig = require('loadConfig')
-- local hotkeys = require('hotkeys')

-- -- Load secrets if available
-- local loadSecrets = loadfile('load_secrets.lua')
-- if loadSecrets then
--     logger.i("Loading secrets")
--     loadSecrets()
-- else
--     logger.w("No secrets file found")
-- end

-- -- Reload configuration on file change
-- -- function reloadConfig(files)
-- --     local doReload = false
-- --     for _, file in pairs(files) do
-- --         if file:sub(-4) == ".lua" then
-- --             doReload = true
-- --         end
-- --     end
-- --     if doReload then
-- --         hs.reload()
-- --     end
-- -- end

-- -- Load configuration
-- loadConfig()

-- -- Set up HammerGhost spoon
-- if spoon.HammerGhost then
--     spoon.HammerGhost:setup()
--     logger.i("HammerGhost spoon set up")
-- else
--     logger.w("HammerGhost spoon not available")
-- end

-- -- Set up DragonGrid spoon
-- if spoon.DragonGrid then
--     spoon.DragonGrid:setup()
--     logger.i("DragonGrid spoon set up")
-- else
--     logger.w("DragonGrid spoon not available")
-- end

-- -- Add the config.lua path watcher
-- -- configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
-- -- configWatcher:start()

-- -- Success message
-- logger.i("Hammerspoon configuration loaded")
-- hs.alert.show("Hammerspoon config loaded")

-- -- Bind a key to reload config
-- hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
--     hs.reload()
--     -- startLayoutAPIServer() -- Restart the API server
-- end)

-- return logger
