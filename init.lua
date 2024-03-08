

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

usbWatcher = nil
function usbDeviceCallback(data)
    print(data["productName"])
    -- SAMSUNG_Android
    if (data["productName"] == "SAMSUNG_Android") then
        -- execute scrcpy to mirror android screen
        hs.alert.show("Android plugged in")
        hs.execute("scrcpy") --max-size 800 --window-title 'Samsung S22' --turn-screen-off --stay-awake --always-on-top --window-borderless --window-x 0 --window-y 0 --window-width 800 --window-height 1600 --max-fps 30 --no-control --force-adb-forward --forward-all-clicks --prefer-text --window-borderless --window-title 'Samsung S22'")
        -- if (data["eventType"] == "added") then
        --     hs.alert.show("Android plugged in")
        -- elseif (data["eventType"] == "removed") then
        --     hs.alert.show("Android unplugged")
        -- end
    end

    if (data["productName"] == "USB Keyboard") then
        if (data["eventType"] == "added") then
            hs.alert.show("USB Keyboard plugged in")
        elseif (data["eventType"] == "removed") then
            hs.alert.show("USB Keyboard unplugged")
        end
    end
end
usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

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

