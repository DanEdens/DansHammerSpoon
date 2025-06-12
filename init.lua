-- Hammerspoon init.lua
local __FILE__ = 'init.lua' -- Primary configuration file for Hammerspoon
hs.allowAppleScript(true) -- Enable AppleScript support
require("hs.ipc")
-- Load HyperLogger for better debugging with clickable log messages
local HyperLogger = require('HyperLogger')
-- Create a main application logger and expose it globally
local log = HyperLogger.new('HammerspoonApp')
-- Make the logger available globally for other modules
_G.AppLogger = log
log:d('Logger initialized', __FILE__, 10)

-- Load additional modules as needed
require('loadConfig')
dofile(hs.configdir .. "/hotkeys.lua")

-- Load the HammerGhost spoon
-- hs.loadSpoon("HammerGhost")

-- Bind hotkey for HammerGhost (only initialize when hotkey is pressed)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    local hammerghost = spoon.HammerGhost:init()
    if hammerghost then
        hs.logger.new("init.lua"):i("HammerGhost spoon opened successfully via hotkey.")
    else
        hs.logger.new("init.lua"):e("Failed to open HammerGhost spoon via hotkey.")
    end
end)

local secrets = require("load_secrets")
log:d('Secrets module loaded', __FILE__, 14)

-- Configure environment variables from secrets
local AWSIP = secrets.get("AWSIP", "localhost")
local AWSIP2 = secrets.get("AWSIP2", "localhost")
local MCP_PORT = secrets.get("MCP_PORT", "8000")

-- MCP Client Configuration - Toggle between HTTP and SSE modes
-- Set MCP_CLIENT_MODE in secrets file: "sse" (default) or "http"
local MCP_CLIENT_MODE = secrets.get("MCP_CLIENT_MODE", "sse")
log:i('MCP client mode configured: ' .. MCP_CLIENT_MODE, __FILE__, 18)

-- Load appropriate MCP client based on configuration
log:d('Loading MCP client for centralized project management (mode: ' .. MCP_CLIENT_MODE .. ')', __FILE__, 20)
local mcpClientLoaded = false
local mcpClientType = MCP_CLIENT_MODE

if MCP_CLIENT_MODE == "sse" then
    -- Load SSE-based MCP client
    local success, MCPClientSSE = pcall(function()
        return require('MCPClientSSE')
    end)

    if success then
        -- Configure MCP SSE client with server URL from secrets
        local mcpServerUrl = secrets.get("MCP_SERVER_URL", "http://" .. AWSIP .. ":" .. MCP_PORT)
        local mcpTimeout = tonumber(secrets.get("MCP_TIMEOUT", "30"))

        local initSuccess = MCPClientSSE.init({
            serverUrl = mcpServerUrl,
            timeout = mcpTimeout,
            onConnectionStatus = function(connected, message)
                log:i('MCP SSE connection status: ' .. (connected and "connected" or "disconnected") .. " - " .. message)
            end
        })

        if initSuccess then
            mcpClientLoaded = true
            log:i('MCP SSE client initialized successfully with server: ' .. mcpServerUrl, __FILE__, 25)

            -- Start SSE connection for real-time updates
            MCPClientSSE.startSSEConnection()

            -- Test connectivity in background
            hs.timer.doAfter(3.0, function()
                local connected = MCPClientSSE.testConnection()
                if connected then
                    log:i('MCP SSE server connectivity confirmed', __FILE__, 28)
                else
                    log:w('MCP SSE server connectivity test failed - using fallback mode', __FILE__, 29)
                end
            end)
        else
            log:w('Failed to initialize MCP SSE client - using fallback mode', __FILE__, 31)
        end
    else
        log:w('Failed to load MCP SSE client module - using fallback mode: ' .. (MCPClientSSE or "unknown error"),
            __FILE__, 33)
    end
else
    -- Load HTTP-based MCP client (legacy mode)
    local success, MCPClient = pcall(function()
        return require('MCPClient')
    end)

    if success then
        -- Configure MCP client with server URL from secrets
        local mcpServerUrl = secrets.get("MCP_SERVER_URL", "http://localhost:" .. MCP_PORT)
        local mcpTimeout = tonumber(secrets.get("MCP_TIMEOUT", "10"))

        local initSuccess = MCPClient.init({
            serverUrl = mcpServerUrl,
            timeout = mcpTimeout
        })

        if initSuccess then
            mcpClientLoaded = true
            log:i('MCP HTTP client initialized successfully with server: ' .. mcpServerUrl, __FILE__, 25)

            -- Test connectivity in background
            hs.timer.doAfter(2.0, function()
                local connected = MCPClient.testConnection()
                if connected then
                    log:i('MCP HTTP server connectivity confirmed', __FILE__, 28)
                else
                    log:w('MCP HTTP server connectivity test failed - using fallback mode', __FILE__, 29)
                end
            end)
        else
            log:w('Failed to initialize MCP HTTP client - using fallback mode', __FILE__, 31)
        end
    else
        log:w('Failed to load MCP HTTP client module - using fallback mode: ' .. (MCPClient or "unknown error"), __FILE__,
            33)
    end
end

-- Make MCP client status and type available globally
_G.MCPClientLoaded = mcpClientLoaded
_G.MCPClientType = mcpClientType

-- Configure Console Dark Mode
log:d('Configuring console appearance', __FILE__, 23)
local darkMode = {
    backgroundColor = { white = 0.1 },
    textColor = { white = 0.8 },
    cursorColor = { white = 0.8 },
    selectionColor = { red = 0.3, blue = 0.4, green = 0.35 },
    fontName = "Menlo",
    fontSize = 12
}

-- Apply console styling
hs.console.darkMode(true)
hs.console.windowBackgroundColor({
    red = 0.11,
    green = 0.11,
    blue = 0.11,
    alpha = 0.95
})
hs.console.outputBackgroundColor(darkMode.backgroundColor)
hs.console.consoleCommandColor(darkMode.textColor)
hs.console.consolePrintColor(darkMode.textColor)
hs.console.consoleResultColor({ white = 0.7 })
hs.console.alpha(0.95)
hs.console.titleVisibility("hidden")

-- Apply appearance after a short delay
hs.timer.doAfter(0.1, function()
    local consoleWindow = hs.console.hswindow()
    if consoleWindow and consoleWindow.setAppearance then
        consoleWindow:setAppearance(hs.drawing.windowAppearance.darkAqua)
    end
end)

-- Create and configure console toolbar
log:i('Creating console toolbar', __FILE__, 50)
local toolbar = require("hs.webview.toolbar")
local consoleTB = toolbar.new("myConsole", {
        {
            id = "editConfig",
            label = "Edit Config",
            image = hs.image.imageFromName("NSEditTemplate"),
            fn = function()
                local editor = "cursor" -- Use cursor as the editor
                local configFile = hs.configdir .. "/init.lua"
                if hs.fs.attributes(configFile) then
                    hs.task.new("/usr/bin/open", nil, { "-a", editor, configFile }):start()
                else
                    hs.alert.show("Could not find config file")
                end
            end
        },
        {
            id = "reloadConfig",
            label = "Reload",
            image = hs.image.imageFromName("NSRefreshTemplate"),
            fn = function()
                hs.reload()
                hs.alert.show("Config reloaded")
            end
        }
    })
    :canCustomize(true)
    :autosaves(true)

-- Apply the toolbar after a short delay
hs.timer.doAfter(0.2, function()
    hs.console.toolbar(consoleTB)
end)

-- Alert to indicate that the config has been loaded
hs.alert.show("Config loaded")

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
                    fn = function()
                        local win = hs.window.focusedWindow(); if win then win:centerOnScreen() end
                    end
                },
                {
                    name = "Full Screen",
                    icon = "NSEnterFullScreenTemplate",
                    fn = function()
                        local win = hs.window.focusedWindow(); if win then
                            local f = win:screen():frame(); win:setFrame(f)
                        end
                    end
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
                            hs.task.new("/usr/bin/open", nil, { "-a", editor, configFile }):start()
                        end
                    end
                },
                {
                    name = "Reload Config",
                    icon = "NSRefreshTemplate",
                    fn = function()
                        hs.reload(); hs.alert.show("Config reloaded")
                    end
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
                img = hs.styledtext.new(category.icon, { font = { size = 16 } })
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

-- Bind hotkey to show macro tree (Cmd+Alt+Ctrl+M)
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", showMacroTree)

-- myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- hs.eventtap.new(hs.eventtap.event.types.middleMouseUp, function(event)

--     button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

--     current_app = hs.application.frontmostApplication()
--     google_chrome = hs.application.find("Google Chrome")

--     if (current_app == google_chrome) then
--         if (button == 3) then
--             hs.eventtap.keyStroke({"cmd"}, "[")
--         end

--         if (button == 4) then
--             hs.eventtap.keyStroke({"cmd"}, "]")
--         end
--     end
-- end):start()



--everyday at 9:45 am
hs.timer.doAt("4:30", "1d", function()
    hs.alert.show("Time to update Holly!")
end)




-- hs.loadSpoon('ExtendedClipboard')

-- Disable window animations for instant, reliable window positioning
hs.window.animationDuration = 0

white = hs.drawing.color.white
black = hs.drawing.color.black
blue = hs.drawing.color.blue
osx_red = hs.drawing.color.osx_red
osx_green = hs.drawing.color.osx_green
osx_yellow = hs.drawing.color.osx_yellow
tomato = hs.drawing.color.x11.tomato
dodgerblue = hs.drawing.color.x11.dodgerblue
firebrick = hs.drawing.color.x11.firebrick
lawngreen = hs.drawing.color.x11.lawngreen
lightseagreen = hs.drawing.color.x11.lightseagreen
purple = hs.drawing.color.x11.purple
royalblue = hs.drawing.color.x11.royalblue
sandybrown = hs.drawing.color.x11.sandybrown
black50 = { red = 0, blue = 0, green = 0, alpha = 0.5 }
darkblue = { red = 24 / 255, blue = 195 / 255, green = 145 / 255, alpha = 1 }
gray = { red = 246 / 255, blue = 246 / 255, green = 246 / 255, alpha = 0.3 }
