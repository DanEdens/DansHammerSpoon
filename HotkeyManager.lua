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
        local info = debug.getinfo(callback, "n")
        if info.name then
            description = info.name:gsub("^.*_", "")
        else
            -- Try to extract from function body
            local funcStr = string.dump(callback)
            local funcName = funcStr:match("([%w_]+)%(")
            if funcName then
                description = funcName
            else
                description = "Unknown action"
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

    -- Generate the display text
    local displayText = ""
    local colWidth = 40
    local columns = 2
    local rows = math.ceil(#bindings / columns)
    local col = 0
    local count = 0

    for i, binding in ipairs(bindings) do
        if not binding.isTemp then
            local hotkeyText = string.format("%-6s -- %-25s", binding.key, binding.description)

            if col > 0 then
                displayText = displayText .. string.rep(" ", colWidth - #hotkeyText) .. hotkeyText
            else
                displayText = displayText .. hotkeyText
            end

            count = count + 1
            col = col + 1

            if col >= columns or count >= #bindings then
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
