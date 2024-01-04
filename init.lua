

dofile(hs.configdir .. "/loadConfig.lua")
dofile(hs.configdir .. "/ExtendedClipboard.lua")
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


