local log = hs.logger.new('WindowManager','debug')
log.i('Initializing window management system')

local window = require "hs.window"
local spaces = require "hs.spaces"
--local countdown = require "hs.countdown"
-- hammer = "fn"
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
_meta = { "cmd", "shift", "alt" }

-- Set default editor
local editor = "cursor"
-- local editor = "nvim"
--local editor = "PyCharm Community Edition"

-- Create a menu from a list of files to edit
local fileList = {
    { name = "init.lua", path = "~/.hammerspoon/init.lua" },
    { name = "global hotkeys", path = "~/.hammerspoon/hotkeys.lua" },
    { name = "hs config", path = "~/.hammerspoon/config.lua" },
    { name = "zshenv", path = "~/.zshenv"},
    { name = "zshrc", path = "~/.zshrc"},
    { name = "bash_aliases", path = "~/.bash_aliases"},
    { name = "tasks", path = "/Users/d.edens/lab/regressiontestkit/tasks.py"},
    { name = "ssh config", path = "/Users/d.edens/.ssh/config"},
    { name = "RTK.cursorrules", path = "/Users/d.edens/lab/regressiontestkit/regressiontest/.cursorrules"},
    { name = "cursor keybindings", path = "~/Library/Application Support/Cursor/User/keybindings.json"},
    { name = "cursor settings", path = "~/Library/Application Support/Cursor/User/settings.json"},
    { name = "pycharm keybindings", path = "/Users/d.edens/Library/Application Support/JetBrains/PyCharmCE2024.2/keymaps/JetSetStudio.xml"},
    { name = "pycharm templates", path = "/Users/d.edens/Library/Application Support/JetBrains/PyCharmCE2024.2/templates/Python.xml"},
}
local selectedFile = nil
local fileChooser = nil

local projects_list = {
    { name = "lab", path = "~/lab" },
    { name = "regressiontestkit", path = "/Users/d.edens/lab/regressiontestkit"},
    { name = "OculusTestKit", path = "/Users/d.edens/lab/regressiontestkit/OculusTestKit" },
    { name = "hs", path = "~/.hammerspoon" },

}

    -- { name = "pycharm settings", path = "/Users/d.edens/Library/Application Support/JetBrains/PyCharmCE2024.2/options/"},

local scripts_dir = os.getenv("HOME") .. "/.hammerspoon/scripts"

function populateJiraTickets()
    -- retrieve currently active tickets

end

function selectJiraTicket()
    -- select a ticket from the list to focus on
    -- if var not set, run populateJiraTickets()
    -- Once selected, sed the env var in zshrc and hs.
end

function S22command()
    -- send command to my phone via join api call
end


function openSelectedFile()
    -- if selectedFile isnt null then
    if selectedFile ~= nil then
        hs.execute("open -a '" .. editor .. "' " .. selectedFile.path)
    else
        showFileMenu()
    end
end

function showFileMenu()
    local choices = {}
    for _, file in ipairs(fileList) do
        table.insert(choices, {
            text = file.name,
            subText = "Edit this file",
            path = file.path
        })
    end

    if not fileChooser then
        fileChooser = hs.chooser.new(function(choice)
            if choice then
                selectedFile = choice
                openSelectedFile()
                fileChooser:hide()
            end
        end)
    end
    fileChooser:choices(choices)
    fileChooser:show()
end

-- Create a menu to select the editor
local editorList = {
    { name = "Visual Studio Code", command = "Visual Studio Code" },
    { name = "cursor", command = "cursor" },
    { name = "nvim", command = "nvim" },
    { name = "PyCharm Community Edition", command = "PyCharm Community Edition" }
}

function showEditorMenu()
    local choices = {}
    for _, editorOption in ipairs(editorList) do
        table.insert(choices, {
            text = editorOption.name,
            subText = "Select this editor",
            command = editorOption.command
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            editor = choice.command
            hs.alert.show("Editor set to: " .. editor)
            chooser:hide()
        end
    end)
    chooser:choices(choices)
    chooser:show()
end

local gap = 5
local cols = 4
local counter = 0


local logKeyStroke = nil
local strokeisEnabled = false
local usbisEnabled = false
local usbWatcher = nil

function usbDeviceCallback(data)
    log.i('USB event detected:', hs.inspect(data))

    -- Guard against nil data
    if not data then
        log.e('Received nil data in USB callback')
        return
    end

    for key, value in pairs(data) do
        log.d(key .. ": " .. tostring(value))
    end

    if data["eventType"] == "added" then
        if data["vendorName"] == "SAMSUNG" and data["productName"] == "SAMSUNG_Android" then
            log.i('Samsung device connected:', data["productID"])
            local device_id = nil

            if data["productID"] == 26720 then
                device_id = "988a1b30573456354d"
                hs.alert.show("Samsung Android plugged in (Device 988a1b30573456354d)")
            elseif data["productID"] == 26732 then
                device_id = "R5CT602ZVTJ"
                hs.alert.show("Samsung Android plugged in (Device R5CT602ZVTJ)")
            end

            if device_id then
                local cmd = string.format("%s/launch_scrcpy.sh samsung %s", scripts_dir, device_id)
                log.d('Executing script:', cmd)
                hs.task.new("/bin/zsh", nil, {cmd}):start()
            else
                log.w('Unknown Samsung device ID:', data["productID"])
            end

        elseif data["vendorName"] == "Google" then
            log.i('Google device connected:', data["productName"])
            local cmd = string.format("%s/launch_scrcpy.sh google", scripts_dir)
            log.d('Executing script:', cmd)
            hs.task.new("/bin/zsh", nil, {cmd}):start()
            hs.alert.show("Google " .. data["productName"] .. " plugged in")
        else
            log.i('Other device connected:', data["vendorName"])
            hs.alert.show(data["vendorName"] .. " device plugged in")
        end
    end
end

-- Create a USB watcher and set the callback
usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
--usbWatcher:start()
local function toggleUSBLogging()
    if usbisEnabled then
        usbWatcher:stop()
        usbisEnabled = false
    else
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


function halfShuffle(isHorizontal, numSections)
    log.i('Half shuffle called:', {horizontal = isHorizontal, sections = numSections})

    isHorizontal = isHorizontal or false
    numSections = numSections or 6

    local win = hs.window.focusedWindow()
    if not win then
        log.w('No focused window found')
        return
    end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    log.d('Current window frame:', hs.inspect(f))
    log.d('Screen frame:', hs.inspect(max))

    if isHorizontal then
        log.d('Calculating horizontal sections')
        local sectionWidth = max.w / numSections
        local sectionHeight = max.h * 0.98

        local x = max.x + (counter * sectionWidth)
        local y = max.y + (max.h * 0.01)

        f.x = x
        f.y = y
        f.w = sectionWidth
        f.h = sectionHeight
    else
        log.d('Calculating vertical sections')
        local sectionWidth = max.w * 0.33
        local sectionHeight = max.h / numSections

        local x = max.x + (max.w * 0.01)
        local y = max.y + (counter * sectionHeight)

        f.x = x
        f.y = y
        f.w = sectionWidth
        f.h = sectionHeight
    end

    log.d('New window frame:', hs.inspect(f))
    win:setFrame(f)

    counter = (counter + 1) % numSections
    log.d('Counter updated to:', counter)
end

function half2Shuffle()

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

function moveToCorner(position)
    log.i('Moving window to corner:', position)
    local win = hs.window.focusedWindow()
    if not win then
        log.w('No focused window found')
        return
    end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    log.d('Current window frame:', hs.inspect(f))
    log.d('Screen frame:', hs.inspect(max))

    local positions = {
        topLeft = { x = 0, y = 0 },
        topRight = { x = 0.5, y = 0 },
        bottomLeft = { x = 0, y = 0.5 },
        bottomRight = { x = 0.5, y = 0.5 }
    }

    local pos = positions[position]
    if not pos then
        log.e('Invalid position specified:', position)
        return
    end

    f.x = max.x + (max.w * pos.x)
    f.y = max.y + (max.h * pos.y)
    f.w = max.w / 2
    f.h = max.h / 2

    log.d('New window frame:', hs.inspect(f))
    win:setFrame(f)
    log.i('Window moved successfully to', position)
end

function moveSide(side, isSmall)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local width = isSmall and (max.w * 0.4) or (max.w / 2)
    local height = isSmall and (max.h * 0.8) or max.h
    local yOffset = isSmall and (max.h * 0.1) or 0
    local xOffset = (side == "right") and (max.w - width) or 0

    f.x = max.x + xOffset
    f.y = max.y + yOffset
    f.w = width
    f.h = height

    win:setFrame(f)
end

function moveToScreen(direction, position)
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local nextScreen = (direction == "next") and screen:next() or screen:previous()
    local f = win:frame()
    local max = nextScreen:frame()

    if position == "left" then
        f.x = max.x
        f.y = max.y
    else
        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h / 2
    end

    win:setFrame(f)
    win:moveToScreen(nextScreen)
end

function moveWindow(direction)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local moveStep = 150

    local movements = {
        left = { x = -moveStep, y = 0 },
        right = { x = moveStep, y = 0 },
        up = { x = 0, y = -moveStep },
        down = { x = 0, y = moveStep }
    }

    local move = movements[direction]
    f.x = f.x + move.x
    f.y = f.y + move.y

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
end

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


local lastWindowPosition = {}

function saveWindowPosition()
    log.i('Saving window position')
    local win = hs.window.focusedWindow()
    if win then
        lastWindowPosition[win:id()] = win:frame()
        log.d('Saved position for window:', win:id(), hs.inspect(win:frame()))
        hs.alert.show("Window position saved")
    else
        log.w('No focused window to save position')
    end
end

function restoreWindowPosition()
    log.i('Restoring window position')
    local win = hs.window.focusedWindow()
    if win and lastWindowPosition[win:id()] then
        log.d('Restoring position for window:', win:id(), hs.inspect(lastWindowPosition[win:id()]))
        win:setFrame(lastWindowPosition[win:id()])
        hs.alert.show("Window position restored")
    else
        log.w('No saved position found for window:', win and win:id() or 'no window focused')
    end
end

local lastWindowPositions = {}

-- Function to save the position of all windows
function saveAllWindowPositions()
    local wins = hs.window.allWindows()  -- Get all open windows
    for _, win in ipairs(wins) do
        lastWindowPositions[win:id()] = win:frame()  -- Save the window's frame (position and size)
    end
    hs.alert.show("All window positions saved")
end

-- Function to restore the position of all windows
function restoreAllWindowPositions()
    local wins = hs.window.allWindows()  -- Get all open windows
    for _, win in ipairs(wins) do
        local savedPosition = lastWindowPositions[win:id()]
        if savedPosition then
            win:setFrame(savedPosition)  -- Restore the window's frame (position and size)
        end
    end
    hs.alert.show("All window positions restored")
end





function showHyperList()
    hs.alert.show("\
    W     -- Aclock Show  \
    P     -- Open Cursor  \
    B     -- Chrome  \
    D     -- MongoDB Compass  \
    F3    -- Shuffle Layouts  \
    F6    -- Save All Window Positions  \
    F7    -- Restore All Window Positions  \
    F11   -- Move Window One Space Left  \
    F12   -- Move Window One Space Right  \
    0     -- Vertical Shuffle (4 sections)  \
    1     -- Move Window Bottom-Left Corner  \
    2     -- Move Window Bottom-Right Corner  \
    3     -- 80% Full Screen Centered  \
    4     -- Mini Shuffle  \
    6     -- Full Left Half  \
    7     -- Full Right Half  \
    9     -- Open Selected File  \
    Left  -- Move to Previous Screen  \
    Right -- Move to Next Screen  \
    -     -- Show This List  \
    `     -- Visual Studio Code  \
    Tab   -- Launchpad  \
    ")
end

function showHammerList()
    hs.alert.show("\
    P     -- PyCharm  \
    B     -- Arc Browser  \
    D     -- AnythingLLM  \
    Y     -- Countdown Timer  \
    L     -- Logi Options+  \
    F     -- Scrcpy  \
    M     -- Media Play/Pause  \
    S     -- Slack  \
    G     -- GitHub Desktop  \
    E     -- Edit File Menu  \
    T     -- Barrier  \
    F1    -- Toggle HS Console  \
    F2    -- Post S22  \
    F3    -- Toggle USB Logging  \
    F4    -- Toggle Key Logging  \
    F5    -- Reload HS  \
    F6    -- Save Window Position  \
    F7    -- Restore Window Position  \
    F8    -- Set Target Window  \
    0     -- Horizontal Shuffle (3 sections)  \
    1     -- Move Window Top-Left Corner  \
    2     -- Move Window Top-Right Corner  \
    3     -- Full Screen  \
    4     -- Move Window 95/72 Left Side  \
    6     -- Small Left Side  \
    7     -- Small Right Side  \
    8     -- Layouts Menu  \
    9     -- Move Window to Mouse Center  \
    Left  -- Move Window Left  \
    Right -- Move Window Right  \
    Up    -- Move Window Up  \
    Down  -- Move Window Down  \
    -     -- Show This List  \
    `     -- Cursor  \
    Tab   -- Mission Control  \
    ")
end

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
end

function openMostRecentImage()
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    local filePath = hs.execute("ls -t " .. desktopPath .. "/*.png | head -n 1")
    print("filePath: " .. filePath)
    if filePath ~= "" then
        hs.execute("open " .. filePath)
    else
        hs.alert.show("No recent image found on the desktop")
    end
end

-- function to set target to a specific window title 'RegressionTestKit'
function setTargetWindow()
    local win = hs.window.get("regressiontestkit")
    if win then
        hs.alert.show("RegressionTestKit window found")
        win:focus()
    else
        -- open testkit repo with cursor
        -- TODO
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


local moveStep = 150  -- Amount to move window by in pixels

function moveWindowLeft()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.x = f.x - moveStep
    win:setFrame(f)
end

function moveWindowRight()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.x = f.x + moveStep
    win:setFrame(f)
end

function moveWindowUp()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.y = f.y - moveStep
    win:setFrame(f)
end

function moveWindowDown()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.y = f.y + moveStep
    win:setFrame(f)
end

-- Global variable to track canvas state
local canvasVisible = false
local windowCanvas

function toggleWindowCanvas()
    if not windowCanvas then
        -- Create the canvas if it doesn't exist
        windowCanvas = hs.canvas.new(hs.geometry.rect(0, 0, 300, 200)):appendElements({
            type = "rectangle",
            frame = { x = 0, y = 0, w = 300, h = 200 },
            fillColor = { alpha = 0.8, white = 0.1 }
        })               :appendElements({
            type = "text",
            frame = { x = 10, y = 10, w = 280, h = 180 },
            text = "",
            textColor = { white = 1 },
            textSize = 12
        })
    end

    if canvasVisible then
        windowCanvas:delete()
        canvasVisible = false
    else
        -- Update the canvas with window titles
        local text = ""
        local wins = hs.window.allWindows()
        for i, win in ipairs(wins) do
            text = text .. i .. ". " .. win:title() .. "\n"
        end
        windowCanvas:element(2):set("text", text)

        -- Position the canvas centered around the cursor
        local mouse = hs.mouse.getAbsolutePosition()
        local canvasFrame = windowCanvas:frame()
        canvasFrame.x = mouse.x - (canvasFrame.w / 2)
        canvasFrame.y = mouse.y - (canvasFrame.h / 2)
        windowCanvas:frame(canvasFrame)

        windowCanvas:show()
        canvasVisible = true
    end
end
local layoutCounter = 0

function shuffleLayouts()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local max = screen:frame()

    if layoutCounter == 0 then
        -- Full screen
        win:setFrame(max)
    elseif layoutCounter == 1 then
        -- Left half
        win:setFrame(hs.geometry.rect(max.x, max.y, max.w / 2, max.h))
    elseif layoutCounter == 2 then
        -- Right half
        win:setFrame(hs.geometry.rect(max.x + (max.w / 2), max.y, max.w / 2, max.h))
    elseif layoutCounter == 3 then
        -- Top half
        win:setFrame(hs.geometry.rect(max.x, max.y, max.w, max.h / 2))
    elseif layoutCounter == 4 then
        -- Bottom half
        win:setFrame(hs.geometry.rect(max.x, max.y + (max.h / 2), max.w, max.h / 2))
    end

    layoutCounter = (layoutCounter + 1) % 5
end



-- function arrangeWorkWindows()
--    local slack = hs.application.find("Slack")
--    local chrome = hs.application.find("Google Chrome")
--
--    if slack then
--        local slackWin = slack:mainWindow()
--        slackWin:setFrame(hs.screen.mainScreen():frame():toUnitRect():left(0.5):toAbsolute())
--    end
--
--    if chrome then
--        local chromeWin = chrome:mainWindow()
--        chromeWin:setFrame(hs.screen.mainScreen():frame():toUnitRect():right(0.5):toAbsolute())
--    end
--end
--
--hs.hotkey.bind(hammer, "w", arrangeWorkWindows)  -- hammer w -- Arrange Slack and Chrome


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
hs.hotkey.bind(_hyper, "p", function() hs.application.launchOrFocus("cursor") end)                               -- _hyper P     -- scrcpy
--hs.hotkey.bind(hammer, "p", showWindowTitles)  -- setTargetWindow)                                               -- _hyper P     -- Set target window
hs.hotkey.bind(hammer, "b", function() hs.application.launchOrFocus("Arc") end)                                  -- hammer B     -- Arc
hs.hotkey.bind(_hyper, "b", function() hs.application.launchOrFocus("Google Chrome") end)                        -- _hyper B     -- Chrome
hs.hotkey.bind(hammer, "d", function() hs.application.launchOrFocus("AnythingLLM") end)                          -- hammer D     -- AnythingLLM
hs.hotkey.bind(_hyper, "d", function() hs.application.launchOrFocus("MongoDB Compass") end)                      -- _hyper D     -- MongoDB Compass
hs.hotkey.bind(hammer, "y", function() CountDown:startFor(3) end)                                                -- hammer Y     -- Countdown Timer
--hs.hotkey.bind(_hyper, "y", function() hs.application.launchOrFocus("Raycast") end)                             -- _hyper Y     -- Raycast
-- hotkey to open slack

hs.hotkey.bind(hammer, "l", function() hs.application.launchOrFocus("logioptionsplus") end)                      -- hammer L     -- Logi Options+
hs.hotkey.bind(_hyper, "l", function() hs.application.launchOrFocus("System Preferences") end)                   -- _hyper L     -- System Preferences
hs.hotkey.bind(hammer, "f", function() hs.execute("open -a '/opt/homebrew/bin/scrcpy -S'") end)                                                -- hammer F     -- scrcpy
hs.hotkey.bind(hammer, "m", function() hs.eventtap.event.newSystemKeyEvent('PLAY', true):post() end)             -- hammer M     -- Play/Pause
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                    -- _hyper M     -- Edit zshrc
hs.hotkey.bind(hammer, "s", function() hs.application.launchOrFocus("Slack") end)                                -- hammer S     -- Slack
hs.hotkey.bind(hammer, "g", function() hs.application.launchOrFocus("GitHub Desktop") end)                       -- hammer G     -- GitHub Desktop
--hs.hotkey.bind(hammer, "e", function() hs.execute("open -a '" .. editor .. "' ~/.zshenv") end)                   -- hammer E     -- Edit zshenv
hs.hotkey.bind(hammer, "e", function() showFileMenu() end)                                                       -- hammer E     -- Edit file menu
hs.hotkey.bind(_hyper, "e", function() showEditorMenu() end)                                                     -- _hyper E     -- editor menu
--hs.hotkey.bind(_hyper, "e", function() hs.execute("open -a '" .. editor .. "' ~/.hammerspoon/hotkeys.lua") end)  -- _hyper E     -- Edit hotkeys.lua
hs.hotkey.bind(hammer, "t", function() hs.execute("open -a '" .. editor .. "' ~/lab/tasks.py") end)              -- hammer z open $Jobdir/tasks.py
hs.hotkey.bind(hammer, "z", function() hs.execute("open -a '" .. editor .. "' ~/.bash_aliases") end)             -- hammer Z     -- Edit bash_aliases
hs.hotkey.bind(_hyper, "z", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                    -- _hyper Z     -- Edit zshrc
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)                                                  -- hammer F1    -- Toggle HammerSpoon Console
hs.hotkey.bind(_hyper, "F1", function() hs.application.launchOrFocus("Console") end)                             -- _hyper F1    -- Open Console.app
hs.hotkey.bind(hammer, "F2", function() hs.execute("open -a 'post S22 var=:=Task nexus_cycle_character'") end)   -- hammer F2    -- Post S22
--hs.hotkey.bind(hammer, "F2", function() hs.application.launchOrFocus("Marta") end)                              -- hammer F2    -- Open Marta
hs.hotkey.bind(_hyper, "F2", function() hs.execute("marta ~/lab") end)                                           -- _hyper F2    -- Open ~/lab
hs.hotkey.bind(hammer, "F3", function() toggleUSBLogging() end)                                                  -- hammer F3    -- Toggle USB Logging
hs.hotkey.bind(_hyper, "F3", shuffleLayouts)                                                                     -- hammer s -- Shuffle window layouts
--hs.hotkey.bind(_hyper, "F3", function() tempFunction() end)                                                      -- _hyper F3    -- Temporary Function
hs.hotkey.bind(hammer, "F4", function() toggleKeyLogging() end)                                                  -- hammer F4    -- Toggle Key Logging
hs.hotkey.bind(_hyper, "F4", function() tempFunction() end)                                                      -- _hyper F4    -- Temporary Function
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)                                                         -- hammer F5    -- Reload HammerSpoon
hs.hotkey.bind(_hyper, "F5", function() tempFunction() end)                                                      -- _hyper F5    -- Temporary Function
hs.hotkey.bind(hammer, "F6", saveWindowPosition)                                                                 -- hammer F6    -- Save current window position
hs.hotkey.bind(_hyper, "F6", saveAllWindowPositions)                                                             -- Hyper F6     -- hyper + F6 to save the positions of all windows
hs.hotkey.bind(hammer, "F7", restoreWindowPosition)                                                              -- hammer F7    -- Restore last saved window position
hs.hotkey.bind(_hyper, "F7", restoreAllWindowPositions)                                                          -- hyper  F7    -- restore the positions of all windows
hs.hotkey.bind(hammer, "F8", function() setTargetWindow() end)                                                   -- hammer F8    -- Set target window
hs.hotkey.bind(_hyper, "F8", function() tempFunction() end)                                                  -- _hyper F8    -- Show window titles
hs.hotkey.bind(_hyper, "F11", nil, function() moveWindowOneSpace("left", false) end)                             -- _hyper F11   -- Move window one space left
hs.hotkey.bind(_hyper, "F12", nil, function() moveWindowOneSpace("right", false) end)                            -- _hyper F12   -- Move window one space right
hs.hotkey.bind("shift", "F13", function() hs.execute("open ~/Pictures/Greenshot") end)                           -- shift F13    -- Open Screenshots folder
hs.hotkey.bind(hammer, "0", function() halfShuffle(true, 3) end)   -- hammer 4  -- Mini Shuffle (8 vertical sections)hs.hotkey.bind(hammer, "1", function() leftTopCorner() end)                                                      -- hammer 1     -- Move window to Left Top Corner
hs.hotkey.bind(_hyper, "0", function() halfShuffle(false, 4) end)    -- _hyper 4  -- Mini Shuffle (6 horizontal sections)
-- hs.hotkey.bind(hammer, "1", function() leftTopCorner() end)                                                      -- hammer 1     -- Move window to Left Top Corner
-- hs.hotkey.bind(_hyper, "1", function() leftBottomCorner() end)                                                   -- _hyper 1     -- Move window to Bottom Left Corner
-- hs.hotkey.bind(hammer, "2", function() rightTopCorner() end)                                                     -- hammer 2     -- Move window to Right Top Corner
-- hs.hotkey.bind(_hyper, "2", function() rightBottomCorner() end)                                                  -- _hyper 2     -- Move window to Bottom Right Corner
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
hs.hotkey.bind(_hyper, "9", function() openSelectedFile() end)                                              -- _hyper 9     -- Move window to cursor as top-left corner
-- hs.hotkey.bind(hammer, "left", moveWindowLeft)  -- Move window left
-- hs.hotkey.bind(_hyper, "left", function() moveToNextScreenRight() end)                                           -- _hyper Left  -- Move to next screen right
-- hs.hotkey.bind(hammer, "right", moveWindowRight)  -- Move window right
-- hs.hotkey.bind(_hyper, "right", function() moveToPreviousScreenRight() end)                                      -- _hyper Right -- Move to previous screen right
-- hs.hotkey.bind(hammer, "up", moveWindowUp)                                                                       -- hammer Up    -- Move window up
-- hs.hotkey.bind(_hyper, "up", function() tempFunction() end)                                                      -- _hyper Up    -- Move to next screen up
-- hs.hotkey.bind(hammer, "down", moveWindowDown)                                                                   -- hammer Down  -- Move window down
-- hs.hotkey.bind(_hyper, "down", function() tempFunction() end)                                                    -- _hyper Down  -- Move to next screen down
hs.hotkey.bind(hammer, "-", function() showHammerList() end)                                                     -- hammer -     -- Flash list of hammer options
hs.hotkey.bind(_hyper, "-", function() showHyperList() end)                                                      -- _hyper -     -- Flash list of hyper options
hs.hotkey.bind(hammer, "`", function() hs.application.launchOrFocus("cursor") end)                   -- hammer `     -- Vscode
hs.hotkey.bind(_hyper, "`", function() hs.application.launchOrFocus("Visual Studio Code") end)                   -- hammer `     -- Vscode
hs.hotkey.bind(hammer, "Tab", function() hs.application.launchOrFocus("Mission Control.app") end)                -- hammer Tab   -- Mission Control
hs.hotkey.bind(_hyper, "Tab", function() hs.application.launchOrFocus("Launchpad") end)                          -- _hyper Tab   -- Launchpad
hs.hotkey.bind(hammer, "t", function() hs.execute("open -a 'Barrier'") end)                                      -- hammer T     -- Barrier
--hs.hotkey.bind(hammer, "H", function () showavailableHotkey() end)                                               -- hammer H     -- List setup hotkeys

-- Corner bindings
hs.hotkey.bind(hammer, "1", function() moveToCorner("topLeft") end)
hs.hotkey.bind(_hyper, "1", function() moveToCorner("bottomLeft") end)
hs.hotkey.bind(hammer, "2", function() moveToCorner("topRight") end)
hs.hotkey.bind(_hyper, "2", function() moveToCorner("bottomRight") end)

-- Side bindings
hs.hotkey.bind(hammer, "6", function() moveSide("left", true) end)
hs.hotkey.bind(_hyper, "6", function() moveSide("left", false) end)
hs.hotkey.bind(hammer, "7", function() moveSide("right", true) end)
hs.hotkey.bind(_hyper, "7", function() moveSide("right", false) end)

-- Screen movement bindings
-- hs.hotkey.bind(hammer, "right", function() moveToScreen("next", "left") end)
hs.hotkey.bind(_hyper, "right", function() moveToScreen("next", "right") end)
-- hs.hotkey.bind(hammer, "left", function() moveToScreen("previous", "left") end)
hs.hotkey.bind(_hyper, "left", function() moveToScreen("previous", "right") end)

-- Window movement bindings
hs.hotkey.bind(hammer, "left", function() moveWindow("left") end)
hs.hotkey.bind(hammer, "right", function() moveWindow("right") end)
hs.hotkey.bind(hammer, "up", function() moveWindow("up") end)
hs.hotkey.bind(hammer, "down", function() moveWindow("down") end)
-- @formatter:on
