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

-- Show hotkey list for a specific modifier type
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
    local colWidth = 40
    local maxPerCategory = 8 -- Max number of items to show per category in one row

    -- Order of categories (others will be appended at the end)
    local categoryOrder = { "Window Management", "Applications", "Files", "UI & Display", "System" }

    -- Add categories in preferred order
    for _, catName in ipairs(categoryOrder) do
        if categories[catName] then
            -- Add category header
            displayText = displayText .. "— " .. catName .. " —\n"

            local col = 0
            local count = 0
            local row = ""

            for i, binding in ipairs(categories[catName]) do
                local hotkeyText = string.format("%-6s -- %-25s", binding.key, binding.description)

                if col > 0 then
                    row = row .. string.rep(" ", colWidth - #hotkeyText) .. hotkeyText
                else
                    row = row .. hotkeyText
                end

                count = count + 1
                col = col + 1

                if col >= 2 or count >= #categories[catName] then
                    displayText = displayText .. row .. "  \\\n"
                    row = ""
                    col = 0
                end

                -- Start a new row after maxPerCategory items
                if i % maxPerCategory == 0 and i < #categories[catName] then
                    displayText = displayText .. "\n"
                    col = 0
                    row = ""
                end
            end

            displayText = displayText .. "\n"
        end
    end

    -- Handle "Other" category last
    if categories["Other"] and #categories["Other"] > 0 then
        displayText = displayText .. "— Other —\n"
        local col = 0
        local count = 0

        for i, binding in ipairs(categories["Other"]) do
            local hotkeyText = string.format("%-6s -- %-25s", binding.key, binding.description)
            
            if col > 0 then
                displayText = displayText .. string.rep(" ", colWidth - #hotkeyText) .. hotkeyText
            else
                displayText = displayText .. hotkeyText
            end
            
            count = count + 1
            col = col + 1
            
            if col >= 2 or count >= #categories["Other"] then
                displayText = displayText .. "  \\\n"
                col = 0
            end
        end
    end
    
    -- Show the alert
    hs.alert.show(displayText)
end

-- Show hammer hotkey list
function HotkeyManager.showHammerList()
    HotkeyManager.showHotkeyList(HotkeyManager.MODIFIERS.HAMMER)
end

-- Show hyper hotkey list
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

return HotkeyManager.init()
