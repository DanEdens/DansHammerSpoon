

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


usbWatcher = nil
function usbDeviceCallback(data)
    print(data["productName"])
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
hs.timer.doAt("10:45", "1d", function() 
    hs.alert.show("Time to stand up!")
    -- open chrome to a specific page
    hs.execute("open -a 'Google Chrome' https://meet.google.com/xjk-uzpk-oit?authuser=1")
end)

-- ctrl + cmd + alt + shift + ` to switch to vs code
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "`", function()
    hs.application.launchOrFocus("Visual Studio Code")
end)



--everyday at 10:45 am
hs.timer.doAt("10:44", "1d", function() 
    hs.alert.show("Time to stand up!")
    -- open chrome to a specific page
    hs.execute("open -a 'Google Chrome' https://meet.google.com/xjk-uzpk-oit?authuser=1")
end)



