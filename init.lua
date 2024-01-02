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

dofile(hs.configdir .. "/ExtendedClipboard.lua")

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- spoon.SpoonInstall:andUse("HSKeybindings")

-- hs.loadSpoon("SpoonInstall")


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    spoon.AClock:toggleShow()
end)
-- Bind hotkeys for HSKeybindings Spoon
-- hs.loadSpoon("HSKeybindings")
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
--     spoon.HSKeybindings:show()
-- end)


-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--     hs.alert.show("Hello World!")
-- end)



hs.hotkey.bind({"alt", "ctrl"}, "R", function()
    hs.reload()
end)

-- hs.alert.show("Config loaded")

-- local notRunning = { "app1", "app2", "app3" }  -- Replace with actual applications or scripts

-- -- Function to print messages
-- local function printMessage(message)
--     print(message)
-- end

-- -- Function to execute a command
-- local function executePsCommand(command)
--     -- Adapt this to the actual system command format you need
--     hs.execute("powershell.exe Start-Process " .. command)
--     hs.timer.usleep(1000000) -- Wait for 1 second
-- end

-- -- Function to simulate the event check
-- local function checkRunning(eventSuffix)
--     if eventSuffix == "Launch all" then
--         for _, app in ipairs(notRunning) do
--             printMessage("Launching: " .. app .. "...")
--             executePsCommand(app)
--         end
--     else
--         printMessage("Launching: " .. eventSuffix .. "...")
--         executePsCommand(eventSuffix)
--     end
-- end

-- -- Example usage
-- checkRunning("Launch all") -- Or replace with another event suffix


hs.alert.show("Config loaded")
