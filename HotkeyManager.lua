---@diagnostic disable: lowercase-global, undefined-global
-- HotkeyManager.lua
-- Module for managing and displaying hotkeys dynamically

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('HotkeyManager', 'debug')

local HotkeyManager = {}

-- Store all hotkey bindings
HotkeyManager.bindings = {
    hammer = {},
    hyper = {}
}

-- Constants for modifiers
HotkeyManager.MODIFIERS = {
    HAMMER = "hammer",
    HYPER = "hyper"
}

-- Store display window state
HotkeyManager.displayWindows = {
    hammer = nil,
    hyper = nil
}

-- Window display configuration
HotkeyManager.config = {
    width = 800,                              -- Width of the display window
    height = 600,                             -- Height of the display window
    backgroundColor = { 0.1, 0.1, 0.1, 0.9 }, -- Dark background with some transparency
    textColor = { 0.9, 0.9, 0.9, 1.0 },       -- Light text color
    font = "Menlo",
    fontSize = 14,
    fadeInDuration = 0.2,
    fadeOutDuration = 0.3,
    cornerRadius = 10,
    categoryColors = {
        ["Window Management"] = { 0.2, 0.6, 0.8, 1.0 }, -- Blue
        ["Applications"] = { 0.8, 0.4, 0.2, 1.0 },      -- Orange
        ["Files"] = { 0.2, 0.8, 0.4, 1.0 },             -- Green
        ["UI & Display"] = { 0.6, 0.3, 0.8, 1.0 },      -- Purple
        ["System"] = { 0.8, 0.3, 0.3, 1.0 },            -- Red
        ["Other"] = { 0.7, 0.7, 0.7, 1.0 }              -- Gray
    }
}
-- Register a hotkey binding
function HotkeyManager.registerBinding(modifiers, key, callback, description)
    local modType = nil

    -- Determine if this is a hammer or hyper binding
    if #modifiers == 3 and modifiers[1] == "cmd" and modifiers[2] == "ctrl" and modifiers[3] == "alt" then
        modType = HotkeyManager.MODIFIERS.HAMMER
    elseif #modifiers == 4 and modifiers[1] == "cmd" and modifiers[2] == "shift" and modifiers[3] == "ctrl" and modifiers[4] == "alt" then
        modType = HotkeyManager.MODIFIERS.HYPER
    else
        log:w("Unknown modifier combination, not registering in HotkeyManager:", hs.inspect(modifiers))
        return nil
    end

    -- Extract function name for description if not provided
    if not description then
        description = "Unknown action"

        -- Try different methods to get a reasonable description
        local info = debug.getinfo(callback)
        if info.name and info.name ~= "" then
            description = info.name:gsub("^.*_", "")
        else
            -- Try to extract from function body if we can
            local success, funcStr = pcall(string.dump, callback)
            if success and funcStr then
                -- Look for common patterns like Manager.functionName()
                local match = string.match(funcStr, "([%w_]+Manager)%.[a-zA-Z_]+")
                if match then
                    description = match:gsub("Manager", "") .. " action"
                end
            end

            -- If we still don't have a good description, check for common patterns in the function
            if description == "Unknown action" then
                local success, funcType = pcall(function()
                    if string.match(tostring(callback), "WindowManager") then
                        return "Window action"
                    elseif string.match(tostring(callback), "AppManager") then
                        return "App action"
                    elseif string.match(tostring(callback), "FileManager") then
                        return "File action"
                    end
                    return "Unknown action"
                end)

                if success and funcType ~= "Unknown action" then
                    description = funcType
                end
            end
        end
    end

    -- Check if the function is a temp function
    local isTempFunction = false
    if description:match("tempFunction") then
        isTempFunction = true
    end

    -- Store the binding
    table.insert(HotkeyManager.bindings[modType], {
        key = key,
        description = description,
        isTemp = isTempFunction
    })

    -- Sort bindings by key
    table.sort(HotkeyManager.bindings[modType], function(a, b)
        return a.key < b.key
    end)

    return true
end

-- Show hotkey list for a specific modifier type in a persistent window
function HotkeyManager.showHotkeyList(modType)
    if not HotkeyManager.bindings[modType] then
        log:e("Unknown modifier type:", modType)
        return
    end
    
    local bindings = HotkeyManager.bindings[modType]
    if #bindings == 0 then
        log:w("No bindings registered for:", modType)
        hs.alert.show("No hotkeys registered")
        return
    end
    
    -- Check if the window is already showing, if so, close it and return
    if HotkeyManager.displayWindows[modType] then
        HotkeyManager.hideHotkeyList(modType)
        return
    end
    -- Group bindings by category
    local categories = {}

    -- First pass: categorize bindings
    for _, binding in ipairs(bindings) do
        if not binding.isTemp then
            local category = "Other"

            -- Determine category based on description
            if binding.description:match("[Ww]indow") or binding.description:match("[Ll]ayout") or
                binding.description:match("[Ss]creen") or binding.description:match("[Ss]huffle") or
                binding.description:match("[Mm]ove") or binding.description:match("[Pp]osition") then
                category = "Window Management"
            elseif binding.description:match("[Oo]pen") or binding.description:match("[Ll]aunch") or
                binding.description:match("App") then
                category = "Applications"
            elseif binding.description:match("[Ff]ile") or binding.description:match("[Ff]older") or
                binding.description:match("[Ii]mage") or binding.description:match("[Mm]enu") then
                category = "Files"
            elseif binding.description:match("[Ss]how") or binding.description:match("[Tt]oggle") or
                binding.description:match("[Ll]ist") or binding.description:match("[Hh]otkey") then
                category = "UI & Display"
            elseif binding.description:match("[Ff]unction") or binding.description:match("[Rr]eload") or
                binding.description:match("[Cc]onsole") then
                category = "System"
            end

            if not categories[category] then
                categories[category] = {}
            end

            table.insert(categories[category], binding)
        end
    end

    -- Sort each category's bindings by key
    for _, catBindings in pairs(categories) do
        table.sort(catBindings, function(a, b)
            return a.key < b.key
        end)
    end

    -- Generate the display text with categories
    local displayText = ""
    
    -- Add a title
    local titleText = modType == HotkeyManager.MODIFIERS.HAMMER and "Hammer Mode Hotkeys" or "Hyper Mode Hotkeys"
    displayText = displayText .. string.format("<span style='font-size:18pt; font-weight:bold;'>%s</span>\n", titleText)
    displayText = displayText ..
        "<span style='font-size:10pt; color:gray;'>(Press the same hotkey again to close this window)</span>\n\n"

    -- Order of categories
    local categoryOrder = { "Window Management", "Applications", "Files", "UI & Display", "System" }
    -- Add categories in preferred order
    for _, catName in ipairs(categoryOrder) do
        if categories[catName] and #categories[catName] > 0 then
            -- Add category header with color
            local color = HotkeyManager.config.categoryColors[catName]
            local colorStr = string.format("rgb(%d,%d,%d)", math.floor(color[1] * 255), math.floor(color[2] * 255),
                math.floor(color[3] * 255))
            displayText = displayText ..
                string.format("<span style='font-size:16pt; font-weight:bold; color:%s;'>%s</span>\n", colorStr, catName)

            -- Add hotkeys in this category
            displayText = displayText .. "<table style='width:100%; border-spacing:5px;'>\n"
            local rowCount = 0

            for i = 1, #categories[catName], 2 do
                rowCount = rowCount + 1
                displayText = displayText .. "<tr>\n"

                -- First column
                displayText = displayText .. string.format(
                    "<td style='width:45%%;'><span style='font-weight:bold;'>%s</span> — %s</td>\n",
                    categories[catName][i].key,
                    categories[catName][i].description
                )

                -- Second column if available
                if i + 1 <= #categories[catName] then
                    displayText = displayText .. string.format(
                        "<td style='width:45%%;'><span style='font-weight:bold;'>%s</span> — %s</td>\n",
                        categories[catName][i + 1].key,
                        categories[catName][i + 1].description
                    )
                else
                    displayText = displayText .. "<td style='width:45%;'></td>\n"
                end

                displayText = displayText .. "</tr>\n"
            end

            displayText = displayText .. "</table>\n<br>\n"
        end
    end

    -- Handle "Other" category last
    if categories["Other"] and #categories["Other"] > 0 then
        local color = HotkeyManager.config.categoryColors["Other"]
        local colorStr = string.format("rgb(%d,%d,%d)", math.floor(color[1] * 255), math.floor(color[2] * 255),
            math.floor(color[3] * 255))
        displayText = displayText ..
            string.format("<span style='font-size:16pt; font-weight:bold; color:%s;'>%s</span>\n", colorStr, "Other")

        displayText = displayText .. "<table style='width:100%; border-spacing:5px;'>\n"

        for i = 1, #categories["Other"], 2 do
            displayText = displayText .. "<tr>\n"

            -- First column
            displayText = displayText .. string.format(
                "<td style='width:45%%;'><span style='font-weight:bold;'>%s</span> — %s</td>\n",
                categories["Other"][i].key,
                categories["Other"][i].description
            )

            -- Second column if available
            if i + 1 <= #categories["Other"] then
                displayText = displayText .. string.format(
                    "<td style='width:45%%;'><span style='font-weight:bold;'>%s</span> — %s</td>\n",
                    categories["Other"][i + 1].key,
                    categories["Other"][i + 1].description
                )
            else
                displayText = displayText .. "<td style='width:45%;'></td>\n"
            end

            displayText = displayText .. "</tr>\n"
        end

        displayText = displayText .. "</table>\n"
    end

    -- Create a webview to display the content with HTML
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()

    local width = HotkeyManager.config.width
    local height = HotkeyManager.config.height
    local x = (screenFrame.w - width) / 2
    local y = (screenFrame.h - height) / 2

    local rect = hs.geometry.rect(x, y, width, height)
    local webview = hs.webview.new(rect)

    -- Style the webview
    webview:windowStyle({ "utility", "borderless" })
    webview:allowTextEntry(false)
    webview:level(hs.drawing.windowLevels.floating)
    webview:shadow(true)

    -- Set up HTML content
    local htmlContent = [[
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {
                font-family: -apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif;
                color: rgb(230, 230, 230);
                background-color: rgba(40, 40, 40, 0.95);
                margin: 15px;
                line-height: 1.4;
                cursor: default;
                user-select: none;
                -webkit-user-select: none;
            }
            table {
                border-collapse: separate;
            }
            td {
                padding: 5px 10px;
                border-radius: 5px;
                background-color: rgba(60, 60, 60, 0.6);
            }
            .close-button {
                position: absolute;
                top: 10px;
                right: 10px;
                background-color: rgba(200, 50, 50, 0.7);
                color: white;
                width: 24px;
                height: 24px;
                border-radius: 12px;
                text-align: center;
                line-height: 24px;
                font-weight: bold;
                cursor: pointer;
            }
            .close-button:hover {
                background-color: rgba(230, 50, 50, 0.9);
            }
            .help-text {
                position: absolute;
                bottom: 10px;
                left: 0;
                right: 0;
                text-align: center;
                font-size: 10pt;
                color: rgba(200, 200, 200, 0.7);
            }
        </style>
        <script>
            function closeWindow() {
                try {
                    window.webkit.messageHandlers.closeWindow.postMessage("");
                } catch(e) {
                    console.log("Error sending close message");
                }
            }
        </script>
    </head>
    <body>
    <div class="close-button" onclick="closeWindow()">✕</div>
    ]] .. displayText .. [[
    <div class="help-text">Press ESC or click anywhere to close</div>
    </body>
    </html>
    ]]

    -- Load the HTML and store the webview
    webview:html(htmlContent)
    webview:alpha(0.0) -- Start with 0 opacity for fade in
    webview:show()

    -- Add message handler for close button
    webview:windowCallback("closeWindow", function()
        HotkeyManager.hideHotkeyList(modType)
    end)
    
    -- Add a click handler to close on any click
    local clickWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function(event)
        local mousePoint = hs.mouse.absolutePosition()
        local webviewFrame = webview:frame()

        -- If the mouse click is within the webview's frame, close it
        if mousePoint.x >= webviewFrame.x and mousePoint.x <= webviewFrame.x + webviewFrame.w and
            mousePoint.y >= webviewFrame.y and mousePoint.y <= webviewFrame.y + webviewFrame.h then
            HotkeyManager.hideHotkeyList(modType)
            return true -- Consume the click
        end
        return false
    end)
    clickWatcher:start()

    -- Store the watcher with the window for cleanup
    webview.clickWatcher = clickWatcher

    -- Round the corners of the window
    if webview:hswindow() and webview:hswindow().setWindowRadius then
        webview:hswindow():setWindowRadius(HotkeyManager.config.cornerRadius)
    end
    
    -- Fade in the window
    webview:alpha(1.0, HotkeyManager.config.fadeInDuration)

    -- Store the webview for later reference
    HotkeyManager.displayWindows[modType] = webview

    -- Add an ESC key watcher to close the window with ESC
    local escWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
        local keyCode = event:getKeyCode()
        if keyCode == 53 then -- ESC key
            HotkeyManager.hideHotkeyList(modType)
            return true       -- Consume the ESC key
        end
        return false
    end)
    escWatcher:start()

    -- Store the watcher with the window for cleanup
    HotkeyManager.displayWindows[modType].escWatcher = escWatcher

    return webview
end

-- Hide the hotkey list window for a specific modifier type
function HotkeyManager.hideHotkeyList(modType)
    if not HotkeyManager.displayWindows[modType] then
        return
    end

    local webview = HotkeyManager.displayWindows[modType]
    local escWatcher = webview.escWatcher
    local clickWatcher = webview.clickWatcher

    -- Stop the ESC key watcher
    if escWatcher then
        escWatcher:stop()
        webview.escWatcher = nil
    end

    -- Stop the click watcher
    if clickWatcher then
        clickWatcher:stop()
        webview.clickWatcher = nil
    end
    
    -- Fade out and close the window
    webview:alpha(0.0, HotkeyManager.config.fadeOutDuration, function()
        webview:delete()
        HotkeyManager.displayWindows[modType] = nil
    end)
end

-- Show hammer hotkey list or toggle it off if already showing
function HotkeyManager.showHammerList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.HAMMER)
end

-- Show hyper hotkey list or toggle it off if already showing
function HotkeyManager.showHyperList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.HYPER)
end

-- Wrap the original hotkey.bind to automatically register the binding
local originalBind = hs.hotkey.bind
hs.hotkey.bind = function(mods, key, message, pressedfn, releasedfn, repeatfn)
    local description = nil
    local callback = nil

    -- Handle different function signatures
    if type(message) == "function" then
        callback = message
        releasedfn = pressedfn
        repeatfn = releasedfn
        pressedfn = message
    else
        description = message
        callback = pressedfn
    end

    -- Register the binding in our manager
    HotkeyManager.registerBinding(mods, key, callback, description)

    -- Call the original bind function
    return originalBind(mods, key, message, pressedfn, releasedfn, repeatfn)
end

-- Initialize hotkey manager by overriding the global functions
-- This will be called when the module is required
function HotkeyManager.init()
    log:i("Initializing HotkeyManager")

    -- Replace the global functions
    _G.showHammerList = HotkeyManager.showHammerList
    _G.showHyperList = HotkeyManager.showHyperList

    return HotkeyManager
end

-- Configure the display window appearance
function HotkeyManager.configureDisplay(options)
    if type(options) ~= "table" then
        log:e("configureDisplay requires a table of options")
        return
    end

    -- Apply each provided option
    for key, value in pairs(options) do
        if key == "width" or key == "height" or key == "fadeInDuration" or key == "fadeOutDuration" or key == "cornerRadius" or key == "fontSize" then
            if type(value) == "number" then
                HotkeyManager.config[key] = value
            else
                log:w("Invalid value for " .. key .. ", must be a number")
            end
        elseif key == "font" then
            if type(value) == "string" then
                HotkeyManager.config[key] = value
            else
                log:w("Invalid value for font, must be a string")
            end
        elseif key == "backgroundColor" or key == "textColor" then
            if type(value) == "table" and #value >= 3 then
                HotkeyManager.config[key] = value
            else
                log:w("Invalid value for " .. key .. ", must be a table of RGB(A) values")
            end
        elseif key == "categoryColors" and type(value) == "table" then
            -- Merge new category colors with existing ones
            for cat, color in pairs(value) do
                if type(color) == "table" and #color >= 3 then
                    HotkeyManager.config.categoryColors[cat] = color
                end
            end
        else
            log:w("Unknown configuration option: " .. key)
        end
    end

    log:i("Display configuration updated")
    return HotkeyManager
end
return HotkeyManager.init()
