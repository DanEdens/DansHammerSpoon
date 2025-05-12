-- custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {
        "AClock",
        "EmmyLua",
        -- "BingDaily",
        -- "CircleClock",
        -- "HSKeybindings",
        -- "SpoonInstall",
        "ClipShow",
        "ClipboardTool",
        -- "CountDown",
        "DragonGrid",
        -- "HammerGhost",
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

-- Start each spoon that has a start function
for _, spoon_name in pairs(hspoon_list) do
    if spoon[spoon_name] and type(spoon[spoon_name].start) == "function" then
        spoon[spoon_name]:start()
        hs.alert.show(spoon_name .. " started")
    end
end
