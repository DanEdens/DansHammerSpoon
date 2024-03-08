

dofile(hs.configdir .. "/loadConfig.lua")
dofile(hs.configdir .. "/ExtendedClipboard.lua")

-- dofile(hs.configdir .. "/workspace.lua")
-- dofile(hs.configdir .. "/test_balena_handler.lua")
dofile(hs.configdir .. "/hotkeys.lua")
-- dofile(hs.configdir .. "/temp.lua")


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

hs.alert.show("Config loaded")

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


-- everyday at 10:45 am
-- hs.timer.doAt("10:45", "1d", function()
--     hs.alert.show("Time to stand up!")
--     -- open chrome to a specific page
--     hs.execute("open -a 'Google Chrome' https://meet.google.com/xjk-uzpk-oit?authuser=1")
-- end)




--everyday at 9:45 am
hs.timer.doAt("9:44", "1d", function()
    hs.alert.show("Time to stand up!")
    -- open chrome to a specific page
    hs.execute("open -a 'Google Chrome' https://meet.google.com/xjk-uzpk-oit?authuser=1")
end)




-- hs.loadSpoon('ExtendedClipboard')


-- # set brightness to max
-- hs.execute("brightness 1")

-- set brightness to half
--hs.execute("brightness 0.5")

