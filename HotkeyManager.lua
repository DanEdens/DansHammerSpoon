---@diagnostic disable: lowercase-global, undefined-global
-- HotkeyManager.lua
-- Module for managing and displaying hotkeys dynamically

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

local HotkeyManager = {}

-- Store all hotkey bindings
HotkeyManager.bindings = {
    hammer = {},
    hyper = {},
    other = {}
}

-- Constants for modifiers
HotkeyManager.MODIFIERS = {
    HAMMER = "hammer",
    HYPER = "hyper",
    OTHER = "other"
}

-- Store display window state
HotkeyManager.displayWindows = {
    hammer = nil,
    hyper = nil
}

-- Default configuration
HotkeyManager.config = {
    -- Display settings
    width = 800,           -- Width of the hotkey display
    height = 600,          -- Height of the hotkey display
    cornerRadius = 10,     -- Corner radius for the hotkey display
    font = "Menlo",        -- Font for the hotkey display
    fontSize = 14,         -- Font size for the hotkey display
    fadeInDuration = 0.3,  -- Duration of the fade in animation
    fadeOutDuration = 0.3, -- Duration of the fade out animation

    -- Alert settings
    alertDuration = 7,                            -- Duration in seconds to show the hotkey alert
    alertFontSize = 16,                           -- Font size for the alert text
    alertTextColor = { 1, 1, 1, 1 },              -- White text
    alertBackgroundColor = { 0.1, 0.1, 0.1, 0.85 }, -- Dark background with transparency

    -- Category colors for the hotkey display
    categoryColors = {
        ["Window Management"] = { 0.4, 0.7, 0.9 },
        ["Applications"] = { 0.9, 0.5, 0.5 },
        ["Files"] = { 0.5, 0.9, 0.6 },
        ["UI & Display"] = { 0.8, 0.7, 0.3 },
        ["System"] = { 0.9, 0.5, 0.9 },
        ["Other"] = { 0.7, 0.7, 0.7 }
    }
}

-- Helper function to check if a table contains a value
local function tableContains(tbl, element)
    -- Safety check to ensure we're working with a table
    if type(tbl) ~= "table" then
        log:e("tableContains called with non-table: " .. type(tbl))
        return false
    end
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Register a hotkey binding
function HotkeyManager.registerBinding(modifiers, key, callback, description)
    local modType = nil

    -- Ensure modifiers is a table
    if type(modifiers) ~= "table" then
        -- Convert single string modifiers to a table
        log:w("Non-table modifiers passed to registerBinding: " .. tostring(modifiers))
        if type(modifiers) == "string" then
            modifiers = { modifiers }
        else
            modType = "other"
        end
    end

    -- Now we ensure modifiers is a table, determine the type
    if type(modifiers) == "table" then
        -- Determine if this is a hammer or hyper binding by checking for presence of modifiers
        -- regardless of their order
        if #modifiers == 3 and
            tableContains(modifiers, "cmd") and
            tableContains(modifiers, "ctrl") and
            tableContains(modifiers, "alt") then
            modType = HotkeyManager.MODIFIERS.HAMMER
        elseif #modifiers == 4 and
            tableContains(modifiers, "cmd") and
            tableContains(modifiers, "shift") and
            tableContains(modifiers, "ctrl") and
            tableContains(modifiers, "alt") then
            modType = HotkeyManager.MODIFIERS.HYPER
        else
            modType = "other" -- Store all other combos in 'other'
        end
    else
        modType = "other"
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
    local titleText = modType == HotkeyManager.MODIFIERS.HAMMER and "Hammer Mode Hotkeys" or
        modType == HotkeyManager.MODIFIERS.HYPER and "Hyper Mode Hotkeys" or "Other Hotkeys"
    displayText = displayText .. titleText .. "\n\n"

    -- Order of categories
    local categoryOrder = { "Window Management", "Applications", "Files", "UI & Display", "System" }

    -- Add categories in preferred order
    for _, catName in ipairs(categoryOrder) do
        if categories[catName] and #categories[catName] > 0 then
            -- Add category header
            displayText = displayText .. "— " .. catName .. " —\n"

            -- Create two columns of hotkeys
            local colWidth = 40
            local col = 0
            local row = ""

            for i, binding in ipairs(categories[catName]) do
                local hotkeyText = string.format("%-6s -- %-25s", binding.key, binding.description)

                if col > 0 then
                    row = row .. string.rep(" ", colWidth - #hotkeyText) .. hotkeyText
                else
                    row = row .. hotkeyText
                end

                col = col + 1

                if col >= 2 or i == #categories[catName] then
                    displayText = displayText .. row .. "\n"
                    row = ""
                    col = 0
                end
            end

            displayText = displayText .. "\n"
        end
    end

    -- Handle "Other" category last
    if categories["Other"] and #categories["Other"] > 0 then
        displayText = displayText .. "— Other —\n"

        -- Create two columns of hotkeys
        local colWidth = 40
        local col = 0
        local row = ""

        for i, binding in ipairs(categories["Other"]) do
            local hotkeyText = string.format("%-6s -- %-25s", binding.key, binding.description)

            if col > 0 then
                row = row .. string.rep(" ", colWidth - #hotkeyText) .. hotkeyText
            else
                row = row .. hotkeyText
            end

            col = col + 1

            if col >= 2 or i == #categories["Other"] then
                displayText = displayText .. row .. "\n"
                row = ""
                col = 0
            end
        end
    end

    -- Show alert with a large size and longer duration
    local screenRect = hs.screen.mainScreen():frame()
    local alertSize = { w = HotkeyManager.config.width, h = HotkeyManager.config.height }

    -- Create alert with settings for wider display
    hs.alert.closeAll()
    hs.alert.show(
        displayText,
        {
            strokeWidth = 0,
            fillColor = { white = 0.1, alpha = 0.95 },
            textColor = { white = 0.9, alpha = 1 },
            textFont = HotkeyManager.config.font,
            textSize = HotkeyManager.config.fontSize,
            radius = HotkeyManager.config.cornerRadius,
            atScreenEdge = 0,
            fadeInDuration = HotkeyManager.config.fadeInDuration,
            fadeOutDuration = HotkeyManager.config.fadeOutDuration,
            padding = 20
        },
        15
    )
end

-- Hide the hotkey list window for a specific modifier type
function HotkeyManager.hideHotkeyList(modType)
    -- Simply close all alerts
    hs.alert.closeAll()
end

-- Show hammer hotkey list or toggle it off if already showing
function HotkeyManager.showHammerList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.HAMMER)
end

-- Show hyper hotkey list or toggle it off if already showing
function HotkeyManager.showHyperList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.HYPER)
end

-- Show other hotkey list or toggle it off if already showing
function HotkeyManager.showOtherList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.OTHER)
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
        return HotkeyManager
    end

    -- Apply each provided option with proper error handling
    pcall(function()
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
                        if not HotkeyManager.config.categoryColors then
                            HotkeyManager.config.categoryColors = {}
                        end
                        HotkeyManager.config.categoryColors[cat] = color
                    end
                end
            else
                log:w("Unknown configuration option: " .. key)
            end
        end
    end)

    log:i("Display configuration updated")
    return HotkeyManager
end
return HotkeyManager.init()
