local window = require "hs.window"
local spaces = require "hs.spaces"
--local countdown = require "hs.countdown"
-- hammer = "fn"
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
_meta = { "cmd", "shift", "alt" }

-- local editor = "Visual Studio Code"
--local editor = "Fleet"
local editor = "PyCharm Community Edition"

local gap = 5
local cols = 4
local counter = 0
--    local f = win:frame()
--    local g = win:frame()
--    f.x = max.x + (max.w * 0.5)
--    f.y = max.y + (max.h * 0.1)
--    f.w = max.w * 0.35
--    f.h = max.h * 0.8
--    g.x = max.x + (max.w * 0.5)
--    g.y = max.y + (max.h * 0.1)
--    g.w = max.w * 0.45
--    g.h = max.h * 0.8


local logKeyStroke = nil
local strokeisEnabled = false
local usbisEnabled = false
local usbWatcher = nil
function usbDeviceCallback(data)
    print(data["productName"])
    -- SAMSUNG_Android
    if data["productName"] == "SAMSUNG_Android" then
        -- Execute scrcpy to mirror android screen
        hs.alert.show("Android plugged in")
        hs.execute("adb tcpip 5555")
        --hs.task.new(os.getenv("SHELL"), function(exitCode, stdOut, stdErr)
        --    if exitCode == 0 then
        --        -- Successfully executed
        --        print("scrcpy executed successfully")
        --    else
        --        -- Handle error
        --        print("Error executing scrcpy:", stdOut, stdErr)
        --    end
        --end, nil, "scrcpy"):start("--max-size", "800", "--window-title", "'Samsung S22'", "--turn-screen-off", "--stay-awake", "--always-on-top", "--window-borderless", "--window-x", "0", "--window-y", "0", "--window-width", "800", "--window-height", "1600", "--max-fps", "30", "--no-control", "--force-adb-forward", "--forward-all-clicks", "--prefer-text", "--window-borderless", "--window-title", "'Samsung S22'")
    end

    if data["productName"] == "USB Keyboard" then
        if data["eventType"] == "added" then
            hs.alert.show("USB Keyboard plugged in")
        elseif data["eventType"] == "removed" then
            hs.alert.show("USB Keyboard unplugged")
        end
    end
end
local function toggleUSBLogging()
    if usbisEnabled then
        usbWatcher:stop()
        usbisEnabled = false
    else
        usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
        usbWatcher:start()
        usbisEnabled = true
    end
    print("USB is now " .. (usbisEnabled and "enabled" or "disabled"))
end

function tempFunction()
    hs.alert.show("Hotkey not set")
end                                                  -- Function to flash alert if hotkey not set

local function calculatePosition(counter, max, rows)
    local row = math.floor(counter / cols)
    local col = counter % cols
    local x = max.x + (col * (max.w / cols + gap))
    local y = max.y + (row * (max.h / rows + gap))
    return x, y
end                                                       -- Function for calculating window position

function getGoodFocusedWindow(nofull)
    local win = window.focusedWindow()
    if not win or not win:isStandard() then
        return
    end
    if nofull and win:isFullScreen() then
        return
    end
    return win
end-- Function for getting the focused window

function flashScreen(screen)
    local flash = hs.canvas.new(screen:fullFrame()):appendElements({
        action = "fill",
        fillColor = { alpha = 0.25, red = 1 },
        type = "rectangle" })
    flash:show()
    hs.timer.doAfter(.15, function()
        flash:delete()
    end)
end                                                                               -- Function for flashing the screen

function switchSpace(dir, switch)
    local win = getGoodFocusedWindow(true)
    if not win then
        return
    end
    local screen = win:screen()
    local uuid = screen:getUUID()
    local userSpaces = nil
    for k, v in pairs(spaces.allSpaces()) do
        userSpaces = v
        if k == uuid then
            break
        end
    end
    if not userSpaces then
        return
    end
    local thisSpace = spaces.windowSpaces(win) -- first space win appears on
    if not thisSpace then
        return
    else
        thisSpace = thisSpace[1]
    end
    local last = nil
    local skipSpaces = 0
    for _, spc in ipairs(userSpaces) do
        if spaces.spaceType(spc) ~= "user" then
            -- skippable space
            skipSpaces = skipSpaces + 1
        else
            if last and
                    ((dir == "left" and spc == thisSpace) or
                            (dir == "right" and last == thisSpace)) then
                local newSpace = (dir == "left" and last or spc)
                if switch then
                    spaces.gotoSpace(newSpace)  -- also possible, invokes MC
                    --   switchSpace(skipSpaces+1,dir)
                end
                -- spaces.moveWindowToSpace(win,newSpace)
                return
            end
            last = spc     -- Haven't found it yet...
            skipSpaces = 0
        end
    end
    flashScreen(screen)   -- Shouldn't get here, so no space found
end                                                                          -- Function for moving window one space left or right

function moveWindowOneSpace(dir, switch)
    local win = getGoodFocusedWindow(true)
    if not win then
        return
    end
    local screen = win:screen()
    local uuid = screen:getUUID()
    local userSpaces = nil
    for k, v in pairs(spaces.allSpaces()) do
        userSpaces = v
        if k == uuid then
            break
        end
    end
    if not userSpaces then
        return
    end
    local thisSpace = spaces.windowSpaces(win) -- first space win appears on
    if not thisSpace then
        return
    else
        thisSpace = thisSpace[1]
    end
    local last = nil
    local skipSpaces = 0
    for _, spc in ipairs(userSpaces) do
        if spaces.spaceType(spc) ~= "user" then
            -- skippable space
            skipSpaces = skipSpaces + 1
        else
            if last and
                    ((dir == "left" and spc == thisSpace) or
                            (dir == "right" and last == thisSpace)) then
                local newSpace = (dir == "left" and last or spc)
                if switch then
                    spaces.gotoSpace(newSpace)  -- also possible, invokes MC
                    --   switchSpace(skipSpaces+1,dir)
                else
                    spaces.gotoSpace(newSpace)
                    spaces.moveWindowToSpace(win, newSpace)
                end
                return
            end
            last = spc     -- Haven't found it yet...
            skipSpaces = 0
        end
    end
    flashScreen(screen)   -- Shouldn't get here, so no space found
end                                                                    -- Function for moving window one space left or right

function logKeyStroke(event)
    local keyCode = event:getKeyCode()
    local flags = event:getFlags()
    local key = hs.keycodes.map[keyCode]
    local flagString = ""
    for k, v in pairs(flags) do
        if v then
            flagString = flagString .. " " .. k
        end
    end
    print("Key: " .. key .. " (" .. keyCode .. ") Flags: " .. flagString)
end                                                                               -- Function for console logging pressed hotkeys

local function toggleKeyLogging()
    if strokeisEnabled then
        hs.reload()
    else
        -- Create a new eventtap object if it doesn't exist
        logKeyStroke = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, logKeyStroke):start()
        strokeisEnabled = true
        hs.alert.show(logKeyStroke:isEnabled())
    end
end                                                                          -- Function for enabling key-logging

function miniShuffle()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local g = win:frame()
    local h = win:frame()
    local i = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.72)
    f.y = max.y + (max.h * 0.01) + 25
    f.w = max.w * 0.26
    f.h = max.h * 0.97

    g.x = max.x + (max.w * 0.76)
    g.y = max.y + (max.h * 0.01) - 25
    g.w = max.w * 0.24
    g.h = max.h * 0.97

    h.x = max.x + (max.w * 0.7)
    h.y = max.y + (max.h * 0.01) - 30
    h.w = max.w * 0.5
    h.h = max.h * 0.9

    i.x = max.x + (max.w * 0.5)
    i.y = max.y + (max.h * 0.01)
    i.w = max.w * 0.5
    i.h = max.h * 0.9

    -- toggle counter
    if counter == 0 then
        win:setFrame(f)
        counter = 1
    elseif counter == 1 then
        win:setFrame(g)
        counter = 2
    elseif counter == 2 then
        win:setFrame(h)
        counter = 3
    else
        win:setFrame(i)
        counter = 0
    end
end                                                                                     -- hammer 0     -- shuffle


function halfShuffle()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local rows = 2  -- Adjust the number of rows
    local x, y = calculatePosition(counter, max, rows) -- Calculate position based on counter and number of rows
    f.x = x
    f.y = y
    f.w = max.w / cols - 2 * gap
    f.h = max.h / rows - 2 * gap
    win:setFrame(f)
    counter = (counter + 1) % (rows * cols)
end                                                                                     -- hammer 0     -- shuffle

function fullShuffle()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local rows = 1  -- Adjust the number of rows
    local x, y = calculatePosition(counter, max, rows)
    f.x = x
    f.y = y
    f.w = max.w / cols - 2 * gap
    f.h = max.h
    win:setFrame(f)
    counter = (counter + 1) % (rows * cols)
end                                                                                     -- hammer 0     -- Full shuffle

function leftTopCorner()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end                                                                                   -- hammer 1     -- Move window Top Left corner

function leftBottomCorner()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end                                                                                -- hammer 1     -- Move window Bottom Left corner

function rightTopCorner()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end                                                                                  -- hammer 2     -- Move window Top Right corner

function rightBottomCorner()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end                                                                               -- hammer 2     -- Move window Bottom Right corner

function fullScreen()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end                                                                                      -- hammer 3     -- full screen

function nearlyFullScreen()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w * 0.1)
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.8
    f.h = max.h * 0.8
    win:setFrame(f)
end                                                                                -- _hyper 3     -- 80% full screen centered

function moveWindow95By72FromLeftSide()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + 30
    f.y = max.y + (max.h * 0.01)
    f.w = max.w * 0.72 - 30
    f.h = max.h * 0.98
    win:setFrame(f)
end                                                                    -- hammer 4     -- Move window 95 by 72 left side

function moveWindow95By30FromRightSide()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w * 0.73)
    f.y = max.y + (max.h * 0.01)
    f.w = max.w * 0.27
    f.h = max.h * 0.98
    win:setFrame(f)
end                                                                   -- hammer 4     -- Move window 95 by 72 left side

function leftSideSmall()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.4
    f.h = max.h * 0.8
    win:setFrame(f)
end                                                                                   -- hammer 6     -- smaller left side

function leftSide()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end                                                                                        -- _hyper 6     -- left half

function rightSideSmall()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w * 0.6)
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.4
    f.h = max.h * 0.8
    win:setFrame(f)
end                                                                                  -- hammer 7     -- smaller right side

function rightSide()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end                                                                                       -- _hyper 7     -- right half
function moveWindowMouseCenter()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()
    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    win:setFrame(f)
end                                                                           -- hammer 9     -- move focused window to mouse as center
function moveWindowMouseCorner()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()
    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
end                                                                           -- _hyper 9     -- move focused window to cursor as top left corner
function moveToNextScreenLeft()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:next()
    local max = nextScreen:frame()
    f.x = max.x
    f.y = max.y
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end                                                                            -- hammer right -- move to next screen left
function moveToNextScreenRight()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:next()
    local max = nextScreen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end                                                                           -- _hyper right -- move to next screen right
function moveToPreviousScreenLeft()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:previous()
    local max = nextScreen:frame()
    f.x = max.x
    f.y = max.y
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end                                                                        -- hammer left  -- move to previous screen left
function moveToPreviousScreenRight()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:previous()
    local max = nextScreen:frame()
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end                                                                       -- _hyper left  -- move to previous screen right
function showHyperList()
    hs.alert.show("\
    W     -- Aclock Show  \
    F2    -- Open console.app  \
    B     -- Chrome  \
    l     -- System settings  \
    m     -- zshenv  \
    Tab   -- launchpad  \
    e     -- edit zshenv  \
    z     -- edit zshrc  \
    F9    -- move window one space left  \
    F10   -- move window one space right  \
    0     -- 1/4th screen vertical  \
    1     -- Move window Bottom-Left corner  \
    2     -- Move window Bottom-Right corner  \
    3     -- 80% full screen centered  \
    4     -- Move window to 95 by 30 from right side  \
    6     -- left half  \
    7     -- right half  \
    9     -- move focused window to cursor as top left corner  \
    right -- move to next screen right  \
    left  -- move to previous screen right  \
    -     -- flash list of hyper options  \
    ")
end                                                                                   -- _hyper -     -- flash list of hyper options
function showHammerList()
    hs.alert.show("\
    8      --  Layouts Menu \
    F4     --  enable keylogging \
    F5     --  Reload HS \
    F1     --  Toggle HS Console \
    F2     --  Open ~/lab \
    F2     --  Finder \
    `      --  Vscode \
    P      --  Pycharm \
    B      --  Arc \
    l      --  Logi Options+ \
    f      --  Fleet \
    m      --  Play/pause \
    s      --  Slack \
    g      --  Github desktop \
    Tab    --  mission control \
    e      --  edit hotkeys.lua \
    z      --  edit bash_aliases \
    F9     --  move window one space left \
    F10    --  move window one space right \
    f11    --  move to next space \
    f12    --  move to previous space \
    0      --  shuffle \
    1      --  Move window Left corner \
    2      --  Move window Right corner \
    3      --  full screen \
    4      --  Move window 95 by 72 from left side \
    6      --  smaller left side \
    7      --  smaller right side \
    9      --  move focused window to mouse as center \
    right  --  move to next screen left \
    left   --  move to previous screen left \
    -      --  flash list of hammer options")
end                                                                                  -- hammer -     -- flash list of hammer options
function showavailableHotkey()
    -- scrape and list setup hotkeys
    if not hotkeytext then
        local hotkey_list = hs.hotkey.getHotkeys()
        local mainScreen = hs.screen.mainScreen()
        local mainRes = mainScreen:fullFrame()
        local localMainRes = mainScreen:absoluteToLocal(mainRes)
        local hkbgrect = hs.geometry.rect(mainScreen:localToAbsolute(localMainRes.w / 5, localMainRes.h / 5, localMainRes.w / 5 * 3, localMainRes.h / 5 * 3))
        hotkeybg = hs.drawing.rectangle(hkbgrect)
        -- hotkeybg:setStroke(false)
        if not hotkey_tips_bg then
            hotkey_tips_bg = "light"
        end
        if hotkey_tips_bg == "light" then
            hotkeybg:setFillColor({ red = 238 / 255, blue = 238 / 255, green = 238 / 255, alpha = 0.95 })
        elseif hotkey_tips_bg == "dark" then
            hotkeybg:setFillColor({ red = 0, blue = 0, green = 0, alpha = 0.95 })
        end
        hotkeybg:setRoundedRectRadii(10, 10)
        hotkeybg:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeybg:behavior(hs.drawing.windowBehaviors.stationary)
        local hktextrect = hs.geometry.rect(hkbgrect.x + 40, hkbgrect.y + 30, hkbgrect.w - 80, hkbgrect.h - 60)
        hotkeytext = hs.drawing.text(hktextrect, "")
        hotkeytext:setLevel(hs.drawing.windowLevels.modalPanel)
        hotkeytext:behavior(hs.drawing.windowBehaviors.stationary)
        hotkeytext:setClickCallback(nil, function()
            hotkeytext:delete()
            hotkeytext = nil
            hotkeybg:delete()
            hotkeybg = nil
        end)
        hotkey_filtered = {}
        for i = 1, #hotkey_list do
            if hotkey_list[i].idx ~= hotkey_list[i].msg then
                table.insert(hotkey_filtered, hotkey_list[i])
            end
        end
        local availablelen = 70
        local hkstr = ''
        for i = 2, #hotkey_filtered, 2 do
            local tmpstr = hotkey_filtered[i - 1].msg .. hotkey_filtered[i].msg
            if string.len(tmpstr) <= availablelen then
                local tofilllen = availablelen - string.len(hotkey_filtered[i - 1].msg)
                hkstr = hkstr .. hotkey_filtered[i - 1].msg .. string.format('%' .. tofilllen .. 's', hotkey_filtered[i].msg) .. '\n'
            else
                hkstr = hkstr .. hotkey_filtered[i - 1].msg .. '\n' .. hotkey_filtered[i].msg .. '\n'
            end
        end
        if math.fmod(#hotkey_filtered, 2) == 1 then
            hkstr = hkstr .. hotkey_filtered[#hotkey_filtered].msg
        end
        local hkstr_styled = hs.styledtext.new(hkstr, { font = { name = "Courier-Bold", size = 16 }, color = dodgerblue, paragraphStyle = { lineSpacing = 12.0, lineBreak = 'truncateMiddle' }, shadow = { offset = { h = 0, w = 0 }, blurRadius = 0.5, color = darkblue } })
        hotkeytext:setStyledText(hkstr_styled)
        hotkeybg:show()
        hotkeytext:show()
    else
        hotkeytext:delete()
        hotkeytext = nil
        hotkeybg:delete()
        hotkeybg = nil
    end
end                                                                             -- hammer -     -- flash list of hammer options
function openMostRecentImage()
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    local filePath = hs.execute("ls -t " .. desktopPath .. "/*.png | head -n 1")
    print("filePath: " .. filePath)
    if filePath ~= "" then
        hs.execute("open " .. filePath)
    else
        hs.alert.show("No recent image found on the desktop")
    end
end                                                                             -- hammer i     -- Open most recent image

-- function to set target to a specific window title 'RegressionTestKit'
function setTargetWindow()
    local win = hs.window.get("RegressionTestKit")
    if win then
        hs.alert.show("RegressionTestKit window found")
        win:focus()
    else
        hs.alert.show("RegressionTestKit window not found")
    end
end
-- function to list to console availble windows that could be targeted
function listWindows()
    local wins = hs.window.allWindows()
    for i, win in ipairs(wins) do
        print(i, win:title())
        -- show in gui window

    end
end
-- Function to toggle the display of the window list canvas
local windowListCanvas
local windowListVisible = false

function toggleWindowList()
    if windowListVisible then
        -- Hide the window list canvas
        if windowListCanvas then
            windowListCanvas:delete()
            windowListCanvas = nil
        end
        windowListVisible = false
    else
        -- Create and show the window list canvas
        local mousePos = hs.mouse.absolutePosition()

        windowListCanvas = hs.canvas.new(hs.geometry.rect(
                mousePos.x - 200, mousePos.y - 200, 400, 400
        ))
        windowListCanvas:appendElements({
            type = "rectangle",
            frame = { x = 0, y = 0, w = 400, h = 400 },
            fillColor = { white = 0, alpha = 0.8 },
        })

        local windows = hs.window.allWindows()
        local yOffset = 10
        for i, win in ipairs(windows) do
            windowListCanvas:appendElements({
                type = "text",
                frame = { x = 10, y = yOffset, w = 380, h = 20 },
                text = win:title(),
                textColor = { white = 1 },
                textSize = 14
            })
            yOffset = yOffset + 25
        end

        windowListCanvas:show()
        windowListVisible = true
    end
end

--local clipLogger
--
--function toggleClipLogger()
--    if clipLogger then
--        clipLogger:stop()
--        clipLogger = nil
--    else
--        clipLogger = hs.eventtap.new({ hs.eventtap.event.types.typesChanged }, function(event)
--            local clipboard = hs.pasteboard.getContents()
--            if clipboard then
--                local file = io.open(os.getenv("HOME") .. "/cliplog.txt", "a")
--                file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. clipboard .. "\n")
--                file:close()
--            end
--        end)
--        clipLogger:start()
--    end
--end
--



-- Bind the hotkey to display available windows in a GUI window
--hs.hotkey.bind(_hyper, "p", toggleWindowList)
--hs.hotkey.bind(_hyper, "p", toggleClipLogger)

-- @formatter:off
hs.hotkey.bind(hammer, "i", openMostRecentImage)
hs.hotkey.bind(_hyper, "w", function() spoon.AClock:toggleShow() end)                                            -- _hyper W     -- Aclock Show
hs.hotkey.bind(hammer, "p", function() hs.application.launchOrFocus("PyCharm Community Edition") end)            -- hammer P     -- Pycharm
hs.hotkey.bind(_hyper, "p", function() hs.application.launchOrFocus("scrcpy") end)                               -- _hyper P     -- scrcpy
--hs.hotkey.bind(hammer, "p", showWindowTitles)  -- setTargetWindow)                                               -- _hyper P     -- Set target window
hs.hotkey.bind(hammer, "b", function() hs.application.launchOrFocus("Arc") end)                                  -- hammer B     -- Arc
hs.hotkey.bind(_hyper, "b", function() hs.application.launchOrFocus("Google Chrome") end)                        -- _hyper B     -- Chrome
hs.hotkey.bind(hammer, "d", function() hs.application.launchOrFocus("AnythingLLM") end)                          -- hammer D     -- AnythingLLM
hs.hotkey.bind(_hyper, "d", function() hs.application.launchOrFocus("MongoDB Compass") end)                      -- _hyper D     -- MongoDB Compass
hs.hotkey.bind(hammer, "y", function() CountDown:startFor(5) end)                                                -- hammer Y     -- Countdown Timer
--hs.hotkey.bind(_hyper, "y", function() hs.application.launchOrFocus("Raycast") end)                             -- _hyper Y     -- Raycast

hs.hotkey.bind(hammer, "l", function() hs.application.launchOrFocus("logioptionsplus") end)                      -- hammer L     -- Logi Options+
hs.hotkey.bind(_hyper, "l", function() hs.application.launchOrFocus("System Preferences") end)                   -- _hyper L     -- System Preferences
hs.hotkey.bind(hammer, "f", function() hs.execute("scrcpy ") end)                                                -- hammer F     -- scrcpy
hs.hotkey.bind(hammer, "m", function() hs.eventtap.event.newSystemKeyEvent('PLAY', true):post() end)             -- hammer M     -- Play/Pause
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                    -- _hyper M     -- Edit zshrc
hs.hotkey.bind(hammer, "s", function() hs.application.launchOrFocus("Slack") end)                                -- hammer S     -- Slack
hs.hotkey.bind(hammer, "g", function() hs.application.launchOrFocus("GitHub Desktop") end)                       -- hammer G     -- GitHub Desktop
hs.hotkey.bind(hammer, "e", function() hs.execute("open -a '" .. editor .. "' ~/.zshenv") end)                   -- hammer E     -- Edit zshenv
hs.hotkey.bind(_hyper, "e", function() hs.execute("open -a '" .. editor .. "' ~/.hammerspoon/hotkeys.lua") end)  -- _hyper E     -- Edit hotkeys.lua
hs.hotkey.bind(hammer, "z", function() hs.execute("open -a '" .. editor .. "' ~/.bash_aliases") end)             -- hammer Z     -- Edit bash_aliases
hs.hotkey.bind(_hyper, "z", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                    -- _hyper Z     -- Edit zshrc
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)                                                  -- hammer F1    -- Toggle HammerSpoon Console
hs.hotkey.bind(_hyper, "F1", function() hs.application.launchOrFocus("Console") end)                             -- _hyper F1    -- Open Console.app
hs.hotkey.bind(hammer, "F2", function() hs.execute("open -a 'post S22 var=:=Task nexus_cycle_character'") end)   -- hammer F2    -- Post S22
--hs.hotkey.bind(hammer, "F2", function() hs.application.launchOrFocus("Marta") end)                              -- hammer F2    -- Open Marta
hs.hotkey.bind(_hyper, "F2", function() hs.execute("marta ~/lab") end)                                           -- _hyper F2    -- Open ~/lab
hs.hotkey.bind(hammer, "F3", function() toggleUSBLogging() end)                                                  -- hammer F3    -- Toggle USB Logging
hs.hotkey.bind(_hyper, "F3", function() tempFunction() end)                                                      -- _hyper F3    -- Temporary Function
hs.hotkey.bind(hammer, "F4", function() toggleKeyLogging() end)                                                  -- hammer F4    -- Toggle Key Logging
hs.hotkey.bind(_hyper, "F4", function() tempFunction() end)                                                      -- _hyper F4    -- Temporary Function
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)                                                         -- hammer F5    -- Reload HammerSpoon
hs.hotkey.bind(_hyper, "F5", function() tempFunction() end)                                                      -- _hyper F5    -- Temporary Function
hs.hotkey.bind(hammer, "F6", function() tempFunction() end)                                                      -- hammer F6    -- Temporary Function
hs.hotkey.bind(_hyper, "F6", function() tempFunction() end)                                                      -- _hyper F6    -- Temporary Function
hs.hotkey.bind(hammer, "F7", function() tempFunction() end)                                                      -- hammer F7    -- Temporary Function
hs.hotkey.bind(_hyper, "F7", function() tempFunction() end)                                                      -- _hyper F7    -- Temporary Function
hs.hotkey.bind(hammer, "F8", function() tempFunction() end)                                                      -- hammer F8    -- Temporary Function
hs.hotkey.bind(_hyper, "F8", function() tempFunction() end)                                                      -- _hyper F8    -- Temporary Function
hs.hotkey.bind(_hyper, "F11", nil, function() moveWindowOneSpace("left", false) end)                             -- _hyper F11   -- Move window one space left
hs.hotkey.bind(_hyper, "F12", nil, function() moveWindowOneSpace("right", false) end)                            -- _hyper F12   -- Move window one space right
hs.hotkey.bind("shift", "F13", function() hs.execute("open ~/Pictures/Greenshot") end)                           -- shift F13    -- Open Screenshots folder
hs.hotkey.bind(hammer, "0", function() halfShuffle() end)                                                        -- hammer 0     -- Half Shuffle
hs.hotkey.bind(_hyper, "0", function() fullShuffle() end)                                                        -- _hyper 0     -- Full Shuffle (1/4th screen vertical)
hs.hotkey.bind(hammer, "1", function() leftTopCorner() end)                                                      -- hammer 1     -- Move window to Left Top Corner
hs.hotkey.bind(_hyper, "1", function() leftBottomCorner() end)                                                   -- _hyper 1     -- Move window to Bottom Left Corner
hs.hotkey.bind(hammer, "2", function() rightTopCorner() end)                                                     -- hammer 2     -- Move window to Right Top Corner
hs.hotkey.bind(_hyper, "2", function() rightBottomCorner() end)                                                  -- _hyper 2     -- Move window to Bottom Right Corner
hs.hotkey.bind(hammer, "3", function() fullScreen() end)                                                         -- hammer 3     -- Full Screen
hs.hotkey.bind(_hyper, "3", function() nearlyFullScreen() end)                                                   -- _hyper 3     -- Nearly Full Screen (80% centered)
hs.hotkey.bind(hammer, "4", function() moveWindow95By72FromLeftSide() end)                                       -- hammer 4     -- Move window 95 by 72 from left side
hs.hotkey.bind(_hyper, "4", function() miniShuffle() end)                                                        -- _hyper 4     -- Mini Shuffle (95 by 30 from right side)
hs.hotkey.bind(hammer, "5", function() tempFunction() end)                                                       -- hammer 5     -- Temporary Function
hs.hotkey.bind(_hyper, "5", function() tempFunction() end)                                                       -- _hyper 5     -- Temporary Function
hs.hotkey.bind(hammer, "6", function() leftSideSmall() end)                                                      -- hammer 6     -- Smaller Left Side
hs.hotkey.bind(_hyper, "6", function() leftSide() end)                                                           -- _hyper 6     -- Left Half
hs.hotkey.bind(hammer, "7", function() rightSideSmall() end)                                                     -- hammer 7     -- Smaller Right Side
hs.hotkey.bind(_hyper, "7", function() rightSide() end)                                                          -- _hyper 7     -- Right Half
spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()                                                    -- hammer 8     -- Layouts Menu
hs.hotkey.bind(_hyper, "8", function() tempFunction() end)                                                       -- _hyper 8     -- Temporary Function
hs.hotkey.bind(hammer, "9", function() moveWindowMouseCenter() end)                                              -- hammer 9     -- Move window to mouse as center
hs.hotkey.bind(_hyper, "9", function() moveWindowMouseCorner() end)                                              -- _hyper 9     -- Move window to cursor as top-left corner
hs.hotkey.bind(hammer, "left", function() moveToNextScreenLeft() end)                                            -- hammer Left  -- Move to next screen left
hs.hotkey.bind(_hyper, "left", function() moveToNextScreenRight() end)                                           -- _hyper Left  -- Move to next screen right
hs.hotkey.bind(hammer, "right", function() moveToPreviousScreenLeft() end)                                       -- hammer Right -- Move to previous screen left
hs.hotkey.bind(_hyper, "right", function() moveToPreviousScreenRight() end)                                      -- _hyper Right -- Move to previous screen right
hs.hotkey.bind(hammer, "-", function() showHammerList() end)                                                     -- hammer -     -- Flash list of hammer options
hs.hotkey.bind(_hyper, "-", function() showHyperList() end)                                                      -- _hyper -     -- Flash list of hyper options
hs.hotkey.bind(hammer, "`", function() hs.application.launchOrFocus("Visual Studio Code") end)                   -- hammer `     -- Vscode
hs.hotkey.bind(hammer, "Tab", function() hs.application.launchOrFocus("Mission Control.app") end)                -- hammer Tab   -- Mission Control
hs.hotkey.bind(_hyper, "Tab", function() hs.application.launchOrFocus("Launchpad") end)                          -- _hyper Tab   -- Launchpad
hs.hotkey.bind(hammer, "t", function() hs.execute("open -a 'Barrier'") end)                                      -- hammer T     -- Barrier
--hs.hotkey.bind(hammer, "H", function () showavailableHotkey() end)                                               -- hammer H     -- List setup hotkeys
-- @formatter:on
