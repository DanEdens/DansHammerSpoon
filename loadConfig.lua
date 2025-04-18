-- custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {
        "AClock",
        -- "BingDaily",
        -- "CircleClock",
        -- "HSKeybindings",
        -- "SpoonInstall",
        "ClipShow",
        -- "ClipboardTool",
        -- "CountDown",
        -- "HCalendar",
        -- "HSaria2",
        -- "HSearch",
        "Layouts",
        -- "SpeedMenu",
        -- "WinWin",
        -- "FnMate",
    }
end

-- Load Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end

-- Function to check if a value exists in a list
local function isInList(value, list)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

-- Check if ClipboardTool is in the hspoon_list and start it
if isInList("ClipboardTool", hspoon_list) then
    spoon.ClipboardTool:start()
    hs.alert.show("ClipboardTool loaded")
else
    hs.alert.show("ClipboardTool not loaded")
end
