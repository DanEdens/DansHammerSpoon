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
        -- "CountDown",
        -- "HCalendar",
        -- "HSaria2",
        -- "HSearch",
        -- "SpeedMenu",
        -- "WinWin",
        -- "FnMate",
    }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end