dofile(hs.configdir .. "/loadConfig.lua")
dofile(hs.configdir .. "/ExtendedClipboard.lua")

require("hs.ipc")
-- dofile(hs.configdir .. "/workspace.lua")
-- dofile(hs.configdir .. "/test_balena_handler.lua")

-- dofile(hs.configdir .. "/temp.lua")

-- Load HammerGhost
hs.loadSpoon("HammerGhost")
spoon.HammerGhost:bindHotkeys({
    toggle = {{"cmd", "alt", "ctrl"}, "M"}  -- Use Cmd+Alt+Ctrl+G to toggle HammerGhost
})

-- Configure Console Dark Mode
local darkMode = {
    backgroundColor = { white = 0.1 },    -- Dark gray, almost black
    textColor = { white = 0.8 },          -- Light gray
    cursorColor = { white = 0.8 },        -- Light gray cursor
    selectionColor = { red = 0.3, blue = 0.4, green = 0.35 }, -- Subtle blue-green selection
    fontName = "Menlo",                   -- Use Menlo font
    fontSize = 12                         -- 12pt font size
}

-- Apply console styling
hs.console.darkMode(true)                 -- Enable system dark mode for the window frame
hs.console.windowBackgroundColor({
    red = 0.11,                          -- Slightly different than content background
    green = 0.11,                        -- to create a subtle depth effect
    blue = 0.11,
    alpha = 0.95
})
hs.console.outputBackgroundColor(darkMode.backgroundColor)
hs.console.consoleCommandColor(darkMode.textColor)
hs.console.consolePrintColor(darkMode.textColor)
hs.console.consoleResultColor({ white = 0.7 }) -- Slightly dimmer than regular text
hs.console.alpha(0.95)                    -- Slightly transparent
hs.console.titleVisibility("hidden")      -- Hide the title bar for a cleaner look

-- Wait a bit for the console window to be ready before setting appearance
hs.timer.doAfter(0.1, function()
    local consoleWindow = hs.console.hswindow()
    if consoleWindow and consoleWindow.setAppearance then
        consoleWindow:setAppearance(hs.drawing.windowAppearance.darkAqua)
    end
end)

-- Create and configure console toolbar
local toolbar = require("hs.webview.toolbar")
local consoleTB = toolbar.new("myConsole", {
    {
        id = "editConfig",
        label = "Edit Config",
        image = hs.image.imageFromName("NSEditTemplate"),
        fn = function()
            local editor = "cursor"  -- Use cursor as the editor
            local configFile = hs.configdir .. "/init.lua"
            if hs.fs.attributes(configFile) then
                hs.task.new("/usr/bin/open", nil, {"-a", editor, configFile}):start()
            else
                hs.alert.show("Could not find config file")
            end
        end
    },
    {
        id = "reloadConfig",
        label = "Reload",
        image = hs.image.imageFromName("NSRefreshTemplate"),
        fn = function()
            hs.reload()
            hs.alert.show("Config reloaded")
        end
    }
})
:canCustomize(true)
:autosaves(true)

-- Apply the toolbar after a short delay to ensure console is ready
hs.timer.doAfter(0.2, function()
    hs.console.toolbar(consoleTB)
end)

-- Macro Tree System
local macroTree = {
    Applications = {
        {
            name = "Development",
            icon = "NSApplicationIcon",
            items = {
                {
                    name = "Open VSCode",
                    icon = "NSEditTemplate",
                    fn = function() hs.application.launchOrFocus("Visual Studio Code") end
                },
                {
                    name = "Open PyCharm",
                    icon = "NSAdvanced",
                    fn = function() hs.application.launchOrFocus("PyCharm Community Edition") end
                },
                {
                    name = "Open Cursor",
                    icon = "NSComputer",
                    fn = function() hs.application.launchOrFocus("cursor") end
                }
            }
        },
        {
            name = "Browsers",
            icon = "NSNetwork",
            items = {
                {
                    name = "Open Chrome",
                    icon = "NSGlobe",
                    fn = function() hs.application.launchOrFocus("Google Chrome") end
                },
                {
                    name = "Open Arc",
                    icon = "NSBonjour",
                    fn = function() hs.application.launchOrFocus("Arc") end
                }
            }
        },
        {
            name = "Communication",
            icon = "NSChat",
            items = {
                {
                    name = "Open Slack",
                    icon = "NSShareTemplate",
                    fn = function() hs.application.launchOrFocus("Slack") end
                }
            }
        }
    },
    WindowManagement = {
        {
            name = "Basic Actions",
            icon = "NSPreferencesGeneral",
            items = {
                {
                    name = "Center Window",
                    icon = "NSCenterTextAlignment",
                    fn = function() local win = hs.window.focusedWindow(); if win then win:centerOnScreen() end end
                },
                {
                    name = "Full Screen",
                    icon = "NSEnterFullScreenTemplate",
                    fn = function() local win = hs.window.focusedWindow(); if win then local f = win:screen():frame(); win:setFrame(f) end end
                },
                {
                    name = "Save Position",
                    icon = "NSSaveTemplate",
                    fn = saveWindowPosition
                },
                {
                    name = "Restore Position",
                    icon = "NSRefreshTemplate",
                    fn = restoreWindowPosition
                }
            }
        },
        {
            name = "Screen Positions",
            icon = "NSMultipleWindows",
            items = {
                {
                    name = "Left Half",
                    icon = "NSGoLeftTemplate",
                    fn = function() moveSide("left", false) end
                },
                {
                    name = "Right Half",
                    icon = "NSGoRightTemplate",
                    fn = function() moveSide("right", false) end
                },
                {
                    name = "Top Left",
                    icon = "NSGoBackTemplate",
                    fn = function() moveToCorner("topLeft") end
                },
                {
                    name = "Top Right",
                    icon = "NSGoForwardTemplate",
                    fn = function() moveToCorner("topRight") end
                },
                {
                    name = "Bottom Left",
                    icon = "NSGoDownTemplate",
                    fn = function() moveToCorner("bottomLeft") end
                },
                {
                    name = "Bottom Right",
                    icon = "NSGoUpTemplate",
                    fn = function() moveToCorner("bottomRight") end
                }
            }
        },
        {
            name = "Layouts",
            icon = "NSListViewTemplate",
            items = {
                {
                    name = "Mini Layout",
                    icon = "NSFlowViewTemplate",
                    fn = miniShuffle
                },
                {
                    name = "Horizontal Split",
                    icon = "NSColumnViewTemplate",
                    fn = function() halfShuffle(true, 3) end
                },
                {
                    name = "Vertical Split",
                    icon = "NSTableViewTemplate",
                    fn = function() halfShuffle(false, 4) end
                }
            }
        }
    },
    System = {
        {
            name = "Power",
            icon = "NSStatusAvailable",
            items = {
                {
                    name = "Lock Screen",
                    icon = "NSLockLockedTemplate",
                    fn = function() hs.caffeinate.lockScreen() end
                },
                {
                    name = "Show Desktop",
                    icon = "NSHomeTemplate",
                    fn = function() hs.spaces.toggleMissionControl() end
                }
            }
        },
        {
            name = "Configuration",
            icon = "NSPreferencesGeneral",
            items = {
                {
                    name = "Edit Config",
                    icon = "NSEditTemplate",
                    fn = function()
                        local editor = "cursor"
                        local configFile = hs.configdir .. "/init.lua"
                        if hs.fs.attributes(configFile) then
                            hs.task.new("/usr/bin/open", nil, {"-a", editor, configFile}):start()
                        end
                    end
                },
                {
                    name = "Reload Config",
                    icon = "NSRefreshTemplate",
                    fn = function() hs.reload(); hs.alert.show("Config reloaded") end
                }
            }
        }
    }
}

-- Create the macro chooser
local breadcrumbs = {}
local macroChooser = hs.chooser.new(function(choice)
    if not choice then
        -- If user cancelled and we're in a subcategory, go back one level
        if #breadcrumbs > 0 then
            table.remove(breadcrumbs)
            showCurrentLevel()
        end
        return
    end

    if choice.fn then
        -- Execute the macro
        choice.fn()
        breadcrumbs = {}
    else
        -- Navigate to subcategory
        table.insert(breadcrumbs, choice.text)
        showCurrentLevel()
    end
end)

-- Function to get current level in the macro tree based on breadcrumbs
function getCurrentLevel()
    local current = macroTree
    for _, crumb in ipairs(breadcrumbs) do
        for _, category in pairs(current) do
            if category.name == crumb then
                current = category.items
                break
            end
        end
    end
    return current
end

-- Function to show current level in the chooser
function showCurrentLevel()
    local current = getCurrentLevel()
    local choices = {}

    -- Add back button if we're in a subcategory
    if #breadcrumbs > 0 then
        table.insert(choices, {
            text = "← Back",
            subText = "Return to previous menu",
            image = hs.image.imageFromName("NSGoLeftTemplate")
        })
    end

    -- Add items from current level
    for name, category in pairs(current) do
        -- Create image from system icon or fallback to text icon
        local img
        if category.icon then
            if category.icon:len() <= 2 then
                -- For emoji/text icons, create an attributed string
                img = hs.styledtext.new(category.icon, {font = {size = 16}})
            else
                -- For system icons, use imageFromName
                img = hs.image.imageFromName(category.icon) or
                      hs.image.imageFromName("NSActionTemplate")
            end
        end

        table.insert(choices, {
            text = category.name,
            subText = category.items and "Open submenu" or "Execute action",
            image = img,
            fn = category.items and nil or category.fn
        })
    end

    -- Update chooser title to show breadcrumbs
    local title = "Macro Tree"
    if #breadcrumbs > 0 then
        title = table.concat(breadcrumbs, " → ")
    end
    macroChooser:placeholderText(title)

    macroChooser:choices(choices)
    macroChooser:show()
end

-- Function to show macro tree
function showMacroTree()
    breadcrumbs = {}
    showCurrentLevel()
end

-- Bind hotkey to show macro tree (Cmd+Alt+Ctrl+M)
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", showMacroTree)

-- myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

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
-- hs.timer.doAt("9:44", "1d", function()
--     hs.alert.show("Time to stand up!")
--     -- open slack to a specific channel
--     hs.execute("open -a 'Slack' https://app.slack.com/client/T036VBQJD/C042B3Q7DQQ")
-- end)




-- hs.loadSpoon('ExtendedClipboard')

-- hammer_bright = os.getenv("HAMMER_BRIGHT")
-- # set brightness to max
hs.brightness.set(100)
hs.window.animationDuration = 0

white = hs.drawing.color.white
black = hs.drawing.color.black
blue = hs.drawing.color.blue
osx_red = hs.drawing.color.osx_red
osx_green = hs.drawing.color.osx_green
osx_yellow = hs.drawing.color.osx_yellow
tomato = hs.drawing.color.x11.tomato
dodgerblue = hs.drawing.color.x11.dodgerblue
firebrick = hs.drawing.color.x11.firebrick
lawngreen = hs.drawing.color.x11.lawngreen
lightseagreen = hs.drawing.color.x11.lightseagreen
purple = hs.drawing.color.x11.purple
royalblue = hs.drawing.color.x11.royalblue
sandybrown = hs.drawing.color.x11.sandybrown
black50 = {red=0,blue=0,green=0,alpha=0.5}
darkblue = {red=24/255,blue=195/255,green=145/255,alpha=1}
gray = {red=246/255,blue=246/255,green=246/255,alpha=0.3}



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

-- function showavailableHotkey()
--     if not hotkeytext then
--         local hotkey_list=hs.hotkey.getHotkeys()
--         local mainScreen = hs.screen.mainScreen()
--         local mainRes = mainScreen:fullFrame()
--         local localMainRes = mainScreen:absoluteToLocal(mainRes)
--         local hkbgrect = hs.geometry.rect(mainScreen:localToAbsolute(localMainRes.w/5,localMainRes.h/5,localMainRes.w/5*3,localMainRes.h/5*3))
--         hotkeybg = hs.drawing.rectangle(hkbgrect)
--         -- hotkeybg:setStroke(false)
--         if not hotkey_tips_bg then hotkey_tips_bg = "light" end
--         if hotkey_tips_bg == "light" then
--             hotkeybg:setFillColor({red=238/255,blue=238/255,green=238/255,alpha=0.95})
--         elseif hotkey_tips_bg == "dark" then
--             hotkeybg:setFillColor({red=0,blue=0,green=0,alpha=0.95})
--         end
--         hotkeybg:setRoundedRectRadii(10,10)
--         hotkeybg:setLevel(hs.drawing.windowLevels.modalPanel)
--         hotkeybg:behavior(hs.drawing.windowBehaviors.stationary)
--         local hktextrect = hs.geometry.rect(hkbgrect.x+40,hkbgrect.y+30,hkbgrect.w-80,hkbgrect.h-60)
--         hotkeytext = hs.drawing.text(hktextrect,"")
--         hotkeytext:setLevel(hs.drawing.windowLevels.modalPanel)
--         hotkeytext:behavior(hs.drawing.windowBehaviors.stationary)
--         hotkeytext:setClickCallback(nil,function() hotkeytext:delete() hotkeytext=nil hotkeybg:delete() hotkeybg=nil end)
--         hotkey_filtered = {}
--         for i=1,#hotkey_list do
--             if hotkey_list[i].idx ~= hotkey_list[i].msg then
--                 table.insert(hotkey_filtered,hotkey_list[i])
--             end
--         end
--         local availablelen = 70
--         local hkstr = ''
--         for i=2,#hotkey_filtered,2 do
--             local tmpstr = hotkey_filtered[i-1].msg .. hotkey_filtered[i].msg
--             if string.len(tmpstr)<= availablelen then
--                 local tofilllen = availablelen-string.len(hotkey_filtered[i-1].msg)
--                 hkstr = hkstr .. hotkey_filtered[i-1].msg .. string.format('%'..tofilllen..'s',hotkey_filtered[i].msg) .. '\n'
--             else
--                 hkstr = hkstr .. hotkey_filtered[i-1].msg .. '\n' .. hotkey_filtered[i].msg .. '\n'
--             end
--         end
--         if math.fmod(#hotkey_filtered,2) == 1 then hkstr = hkstr .. hotkey_filtered[#hotkey_filtered].msg end
--         local hkstr_styled = hs.styledtext.new(hkstr, {font={name="Courier-Bold",size=16}, color=dodgerblue, paragraphStyle={lineSpacing=12.0,lineBreak='truncateMiddle'}, shadow={offset={h=0,w=0},blurRadius=0.5,color=darkblue}})
--         hotkeytext:setStyledText(hkstr_styled)
--         hotkeybg:show()
--         hotkeytext:show()
--     else
--         hotkeytext:delete()
--         hotkeytext=nil
--         hotkeybg:delete()
--         hotkeybg=nil
--     end
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

dofile(hs.configdir .. "/hotkeys.lua")
