

dofile(hs.configdir .. "/loadConfig.lua")
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


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    spoon.AClock:toggleShow()
end)

-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
--     spoon.ClipboardTool:toggleClipboard()
-- end)


hs.hotkey.bind({"alt", "ctrl"}, "R", function()
    hs.reload()
end)




hs.alert.show("Config loaded")



