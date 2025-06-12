-- test_init_flow.lua
-- Tests the initialization flow of Hammerspoon to detect redundancies and ordering issues

-- Create a mock logger to track module loads and initialization
local trackingLog = {}

-- Track module initialization
local moduleInitOrder = {}
local spoonLoadOrder = {}
local redundantLoads = {}

-- Track component load times
local loadTimings = {}
local startTime = os.time()

-- Mock various key modules to track their initialization
local mockModules = {
    "WindowManager",
    "FileManager",
    "HotkeyManager",
    "ProjectManager",
    "AppManager",
    "DeviceManager",
    "WindowToggler"
}

-- Store original require function
local originalRequire = require

-- Override require to track module loading
function require(moduleName)
    local moduleStart = os.clock()

    -- Pass through to the original require
    local result = originalRequire(moduleName)

    -- Track the module load
    local loadTime = os.clock() - moduleStart

    -- Only track our core modules
    for _, name in ipairs(mockModules) do
        if moduleName == name then
            table.insert(moduleInitOrder, { name = moduleName, time = loadTime })
            loadTimings[moduleName] = loadTime

            -- Check for redundant loading
            local count = 0
            for _, loaded in ipairs(moduleInitOrder) do
                if loaded.name == moduleName then
                    count = count + 1
                end
            end

            if count > 1 then
                table.insert(redundantLoads, moduleName)
            end

            print("Module loaded: " .. moduleName .. " in " .. loadTime .. "s")
        end
    end

    return result
end

-- Mock spoon loading
local originalLoadSpoon = hs.loadSpoon
function hs.loadSpoon(spoonName)
    local spoonStart = os.clock()
    local result = originalLoadSpoon(spoonName)
    local loadTime = os.clock() - spoonStart

    table.insert(spoonLoadOrder, { name = spoonName, time = loadTime })
    loadTimings[spoonName .. " (Spoon)"] = loadTime

    print("Spoon loaded: " .. spoonName .. " in " .. loadTime .. "s")

    return result
end

-- Report function
local function reportInitialization()
    print("\n=== Initialization Report ===\n")

    -- Module initialization order
    print("Module Initialization Order:")
    for i, module in ipairs(moduleInitOrder) do
        print(string.format("%2d. %s (%.3fs)", i, module.name, module.time))
    end

    -- Spoon loading order
    print("\nSpoon Loading Order:")
    for i, spoon in ipairs(spoonLoadOrder) do
        print(string.format("%2d. %s (%.3fs)", i, spoon.name, spoon.time))
    end

    -- Redundant loads
    if #redundantLoads > 0 then
        print("\nRedundant Module Loads:")
        for _, moduleName in ipairs(redundantLoads) do
            print("  - " .. moduleName)
        end
    else
        print("\nNo redundant module loads detected.")
    end

    -- Performance report
    print("\nPerformance Report:")
    local sortedTimings = {}
    for name, time in pairs(loadTimings) do
        table.insert(sortedTimings, { name = name, time = time })
    end

    table.sort(sortedTimings, function(a, b) return a.time > b.time end)

    for i, timing in ipairs(sortedTimings) do
        print(string.format("%2d. %s: %.3fs", i, timing.name, timing.time))
    end

    -- Total initialization time
    local totalTime = os.time() - startTime
    print("\nTotal initialization time: " .. totalTime .. "s")
end

-- Install a timer to run the report after initialization
hs.timer.doAfter(5, reportInitialization)

-- Notify that we're testing
hs.alert.show("Testing init flow...")

-- Now proceed with normal initialization
print("Beginning initialization flow test...")

-- The actual initialization will happen in init.lua
-- This is just a hook to track the process

--
-- privatepath = hs.fs.pathToAbsolute(hs.configdir..'/private')
-- if privatepath == nil then
--     hs.fs.mkdir(hs.configdir..'/private')
-- end
-- privateconf = hs.fs.pathToAbsolute(hs.configdir..'/private/awesomeconfig.lua')
-- if privateconf ~= nil then
--     require('private/awesomeconfig')
-- end

-- hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
-- if string.len(hsreload_keys[2]) > 0 then
--     hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
-- end

-- lockscreen_keys = lockscreen_keys or {{"cmd", "shift", "ctrl"}, "L"}
-- if string.len(lockscreen_keys[2]) > 0 then
--     hs.hotkey.bind(lockscreen_keys[1], lockscreen_keys[2],"Lock Screen", function() hs.caffeinate.lockScreen() end)
-- end

-- if modalmgr == nil then
--     showtime_lkeys = showtime_lkeys or {{"cmd", "shift", "ctrl"}, "T"}
--     if string.len(showtime_lkeys[2]) > 0 then
--         hs.hotkey.bind(showtime_lkeys[1], showtime_lkeys[2], 'Show Digital Clock', function() show_time() end)
--     end
-- end

-- function show_time()
--     if time_draw == nil then
--         local mainScreen = hs.screen.mainScreen()
--         local mainRes = mainScreen:fullFrame()
--         local localMainRes = mainScreen:absoluteToLocal(mainRes)
--         local time_str = hs.styledtext.new(os.date("%H:%M"),{font={name="Impact",size=120},color=darkblue,paragraphStyle={alignment="center"}})
--         local timeframe = hs.geometry.rect(mainScreen:localToAbsolute((localMainRes.w-300)/2,(localMainRes.h-200)/2,300,150))
--         time_draw = hs.drawing.text(timeframe,time_str)
--         time_draw:setLevel(hs.drawing.windowLevels.overlay)
--         time_draw:show()
--         if ttimer == nil then
--             ttimer = hs.timer.doAfter(4, function() time_draw:delete() time_draw=nil end)
--         else
--             ttimer:start()
--         end
--     else
--         ttimer:stop()
--         time_draw:delete()
--         time_draw=nil
--     end
-- end

-- showhotkey_keys = showhotkey_keys or {{"cmd", "shift", "ctrl"}, "space"}
-- if string.len(showhotkey_keys[2]) > 0 then
--     hs.hotkey.bind(showhotkey_keys[1], showhotkey_keys[2], "Toggle Hotkeys Cheatsheet", function() showavailableHotkey() end)
-- end

-- modal_list = {}

-- function modal_stat(color,alpha)
--     if not modal_tray then
--         local mainScreen = hs.screen.mainScreen()
--         local mainRes = mainScreen:fullFrame()
--         local localMainRes = mainScreen:absoluteToLocal(mainRes)
--         modal_tray = hs.canvas.new(mainScreen:localToAbsolute({x=localMainRes.w-40,y=localMainRes.h-40,w=20,h=20}))
--         modal_tray[1] = {action="fill",type="circle",fillColor=white}
--         modal_tray[1].fillColor.alpha=0.7
--         modal_tray[2] = {action="fill",type="circle",fillColor=white,radius="40%"}
--         modal_tray:level(hs.canvas.windowLevels.status)
--         modal_tray:clickActivating(false)
--         modal_tray:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.stationary)
--         modal_tray._default.trackMouseDown = true
--     end
--     modal_tray:show()
--     modal_tray[2].fillColor = color
--     modal_tray[2].fillColor.alpha = alpha
-- end

-- activeModals = {}
-- function exit_others(excepts)
--     function isInExcepts(value,tbl)
--         for i=1,#tbl do
--            if tbl[i] == value then
--                return true
--            end
--         end
--         return false
--     end
--     if excepts == nil then excepts = {} end
--     for i = 1, #activeModals do
--         if not isInExcepts(activeModals[i].id, excepts) then
--             activeModals[i].modal:exit()
--         end
--     end
-- end

-- function move_win(direction)
--     local win = hs.window.focusedWindow()
--     local screen = win:screen()
--     if win then
--         if direction == 'up' then win:moveOneScreenNorth() end
--         if direction == 'down' then win:moveOneScreenSouth() end
--         if direction == 'left' then win:moveOneScreenWest() end
--         if direction == 'right' then win:moveOneScreenEast() end
--         if direction == 'next' then win:moveToScreen(screen:next()) end
--     end
-- end

-- function resize_win(direction)
--     local win = hs.window.focusedWindow()
--     if win then
--         local f = win:frame()
--         local screen = win:screen()
--         local localf = screen:absoluteToLocal(f)
--         local max = screen:fullFrame()
--         local stepw = max.w/30
--         local steph = max.h/30
--         if direction == "right" then
--             localf.w = localf.w+stepw
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "left" then
--             localf.w = localf.w-stepw
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "up" then
--             localf.h = localf.h-steph
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "down" then
--             localf.h = localf.h+steph
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "halfright" then
--             localf.x = max.w/2 localf.y = 0 localf.w = max.w/2 localf.h = max.h
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "halfleft" then
--             localf.x = 0 localf.y = 0 localf.w = max.w/2 localf.h = max.h
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "halfup" then
--             localf.x = 0 localf.y = 0 localf.w = max.w localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "halfdown" then
--             localf.x = 0 localf.y = max.h/2 localf.w = max.w localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "cornerNE" then
--             localf.x = max.w/2 localf.y = 0 localf.w = max.w/2 localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "cornerSE" then
--             localf.x = max.w/2 localf.y = max.h/2 localf.w = max.w/2 localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "cornerNW" then
--             localf.x = 0 localf.y = 0 localf.w = max.w/2 localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "cornerSW" then
--             localf.x = 0 localf.y = max.h/2 localf.w = max.w/2 localf.h = max.h/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "center" then
--             localf.x = (max.w-localf.w)/2 localf.y = (max.h-localf.h)/2
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "fcenter" then
--             localf.x = stepw*5 localf.y = steph*5 localf.w = stepw*20 localf.h = steph*20
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "fullscreen" then
--             localf.x = 0 localf.y = 0 localf.w = max.w localf.h = max.h
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "shrink" then
--             localf.x = localf.x+stepw localf.y = localf.y+steph localf.w = localf.w-(stepw*2) localf.h = localf.h-(steph*2)
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "expand" then
--             localf.x = localf.x-stepw localf.y = localf.y-steph localf.w = localf.w+(stepw*2) localf.h = localf.h+(steph*2)
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "mright" then
--             localf.x = localf.x+stepw
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "mleft" then
--             localf.x = localf.x-stepw
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "mup" then
--             localf.y = localf.y-steph
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "mdown" then
--             localf.y = localf.y+steph
--             local absolutef = screen:localToAbsolute(localf)
--             win:setFrame(absolutef)
--         end
--         if direction == "ccursor" then
--             localf.x = localf.x+localf.w/2 localf.y = localf.y+localf.h/2
--             hs.mouse.setRelativePosition({x=localf.x,y=localf.y},screen)
--         end
--     else
--         hs.alert.show("No focused window!")
--     end
-- end

-- resizeextra_lefthalf_keys = resizeextra_lefthalf_keys or {{"cmd", "alt"}, "left"}
-- if string.len(resizeextra_lefthalf_keys[2]) > 0 then
--     hs.hotkey.bind(resizeextra_lefthalf_keys[1], resizeextra_lefthalf_keys[2], "Lefthalf of Screen", function() resize_win('halfleft') end)
-- end
-- resizeextra_righthalf_keys = resizeextra_righthalf_keys or {{"cmd", "alt"}, "right"}
-- if string.len(resizeextra_righthalf_keys[2]) > 0 then
--     hs.hotkey.bind(resizeextra_righthalf_keys[1], resizeextra_righthalf_keys[2], "Righthalf of Screen", function() resize_win('halfright') end)
-- end
-- resizeextra_fullscreen_keys = resizeextra_fullscreen_keys or {{"cmd", "alt"}, "up"}
-- if string.len(resizeextra_fullscreen_keys[2]) > 0 then
--     hs.hotkey.bind(resizeextra_fullscreen_keys[1], resizeextra_fullscreen_keys[2], "Fullscreen", function() resize_win('fullscreen') end)
-- end
-- resizeextra_fcenter_keys = resizeextra_fcenter_keys or {{"cmd", "alt"}, "down"}
-- if string.len(resizeextra_fcenter_keys[2]) > 0 then
--     hs.hotkey.bind(resizeextra_fcenter_keys[1], resizeextra_fcenter_keys[2], "Resize & Center", function() resize_win('fcenter') end)
-- end
-- resizeextra_center_keys = resizeextra_center_keys or {{"cmd", "alt"}, "return"}
-- if string.len(resizeextra_center_keys[2]) > 0 then
--     hs.hotkey.bind(resizeextra_center_keys[1], resizeextra_center_keys[2], "Center Window", function() resize_win('center') end)
-- end

-- -- Fn related keybindings
-- local function catcher(event)
--     if event:getFlags()['fn'] and event:getCharacters() == "h" then
--         return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "l" then
--         return true, {hs.eventtap.event.newKeyEvent({}, "right", true)}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "j" then
--         return true, {hs.eventtap.event.newKeyEvent({}, "down", true)}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "k" then
--         return true, {hs.eventtap.event.newKeyEvent({}, "up", true)}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "y" then
--         return true, {hs.eventtap.event.newScrollEvent({3,0},{},"line")}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "o" then
--         return true, {hs.eventtap.event.newScrollEvent({-3,0},{},"line")}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "u" then
--         return true, {hs.eventtap.event.newScrollEvent({0,-3},{},"line")}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "i" then
--         return true, {hs.eventtap.event.newScrollEvent({0,3},{},"line")}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "," then
--         local currentpos = hs.mouse.getRelativePosition()
--         return true, {hs.eventtap.leftClick(currentpos)}
--     elseif event:getFlags()['fn'] and event:getCharacters() == "." then
--         local currentpos = hs.mouse.getRelativePosition()
--         return true, {hs.eventtap.rightClick(currentpos)}
--     end
--     return false
-- end

-- fn_tapper = hs.eventtap.new({hs.eventtap.event.types.keyDown}, catcher):start()

-- if not module_list then
--     module_list = {
--         "widgets/netspeed",
--         "widgets/calendar",
--         "widgets/hcalendar",
--         "widgets/analogclock",
--         "widgets/timelapsed",
--         "widgets/aria2",
--         "modes/basicmode",
--         "modes/indicator",
--         "modes/clipshow",
--         "modes/cheatsheet",
--         "modes/hsearch",
--         "misc/bingdaily",
--     }
-- end

-- for i=1,#module_list do
--     require(module_list[i])
-- end

-- if #modal_list > 0 then require("modalmgr") end

-- globalGC = hs.timer.doEvery(180, collectgarbage)
-- globalScreenWatcher = hs.screen.watcher.newWithActiveScreen(function(activeChanged)
--     if activeChanged then
--         exit_others()
--         clipshowclear()
--         if modal_tray then modal_tray:delete() modal_tray = nil end
--         if hotkeytext then hotkeytext:delete() hotkeytext = nil end
--         if hotkeybg then hotkeybg:delete() hotkeybg = nil end
--         if time_draw then time_draw:delete() time_draw = nil end
--         if cheatsheet_view then cheatsheet_view:delete() cheatsheet_view = nil end
--     end
-- end):start()

-- End of init.lua configuration

-- hammer_bright = os.getenv("HAMMER_BRIGHT")
-- # set brightness to max
