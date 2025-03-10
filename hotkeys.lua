---@diagnostic disable: lowercase-global, undefined-global
local log = hs.logger.new('WindowManager','debug')
log.i('Initializing window management system')

local window = require "hs.window"
local spaces = require "hs.spaces"
--local countdown = require "hs.countdown"
-- hammer = "fn"
hammer = { "cmd", "ctrl", "alt" }
_hyper = { "cmd", "shift", "ctrl", "alt" }
-- _hyper = table.insert(table.shallow_copy(hammer), "shift")  -- Dynamically adds shift to hammer's modifiers
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
    { name = "goosehints",     path = "~/.config/goose/.goosehints" },
    { name = "tasks", path = "~/lab/regressiontestkit/tasks.py"},
    { name = "ssh config", path = "~/.ssh/config"},
    { name = "RTK_rules",      path = "~/lab/regressiontestkit/regressiontest/.cursorrules" },
    { name = "mad_rules",      path = "~/lab/madness_interactive/.cursorrules" },
    { name = "swarmonomicon",  path = "~/lab/madness_interactive/projects/common/swarmonomicon/.cursorrules" },
    -- { name = "pycharm keybindings", path = "~/Library/Application Support/JetBrains/PyCharmCE2024.2/keymaps/JetSetStudio.xml"},
    -- { name = "pycharm templates", path = "~/Library/Application Support/JetBrains/PyCharmCE2024.2/templates/Python.xml"},
}
local selectedFile = nil
local fileChooser = nil

local projects_list = {
    { name = "lab", path = "~/lab" },
    { name = "regressiontestkit", path = "~/lab/regressiontestkit"},
    { name = "OculusTestKit", path = "~/lab/regressiontestkit/OculusTestKit" },
    { name = "hs", path = "~/.hammerspoon" },
    { name = "madness_interactive", path = "~/lab/madness_interactive" },
    { name = "swarmonomicon",       path = "~/lab/madness_interactive/projects/common/swarmonomicon" },
    { name = "Cogwyrm",             path = "~/lab/madness_interactive/projects/mobile/Cogwyrm" },
}

    -- { name = "pycharm settings", path = "~/Library/Application Support/JetBrains/PyCharmCE2024.2/options/"},

local scripts_dir = os.getenv("HOME") .. "/.hammerspoon/scripts"

-- Helper function to create a shallow copy of a table
function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

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
                local cmd = string.format("%s/launch_scrcpy.sh samsung &> /dev/null &", scripts_dir)
                log.d('Executing command:', cmd)
                local success, output, error = os.execute(cmd)
                if success then
                    log.i('Successfully launched scrcpy script')
                else
                    log.e('Error launching scrcpy script:', error)
                end
            else
                log.w('Unknown Samsung device ID:', data["productID"])
            end

        elseif data["vendorName"] == "Google" then
            log.i('Google device connected:', data["productName"])
            local cmd = string.format("nohup %s/launch_scrcpy.sh google &> /dev/null &", scripts_dir)
            log.d('Executing command:', cmd)
            local success, output, error = os.execute(cmd)
            if success then
                log.i('Successfully launched scrcpy script')
            else
                log.e('Error launching scrcpy script:', error)
            end
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
toggleUSBLogging()

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

-- Define layouts table outside the function
local miniLayouts = {
    {  -- Layout 1
        x = function(max) return max.x + (max.w * 0.72) end,
        y = function(max) return max.y + (max.h * 0.01) + 25 end,
        w = function(max) return max.w * 0.26 end,
        h = function(max) return max.h * 0.97 end
    },
    {  -- Layout 2
        x = function(max) return max.x + (max.w * 0.76) end,
        y = function(max) return max.y + (max.h * 0.01) - 25 end,
        w = function(max) return max.w * 0.24 end,
        h = function(max) return max.h * 0.97 end
    },
    {  -- Layout 3
        x = function(max) return max.x + (max.w * 0.7) end,
        y = function(max) return max.y + (max.h * 0.01) - 30 end,
        w = function(max) return max.w * 0.5 end,
        h = function(max) return max.h * 0.9 end
    },
    {  -- Layout 4
        x = function(max) return max.x + (max.w * 0.5) end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.5 end,
        h = function(max) return max.h * 0.9 end
    }
}

-- New standardLayouts table combining various window positions
local standardLayouts = {
    fullScreen = {  -- Full screen
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w end,
        h = function(max) return max.h end
    },
    nearlyFull = {  -- 80% centered
        x = function(max) return max.x + (max.w * 0.1) end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.8 end,
        h = function(max) return max.h * 0.8 end
    },
    leftHalf = {  -- Left half
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h end
    },
    rightHalf = {  -- Right half
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h end
    },
    leftSmall = {  -- Small left side
        x = function(max) return max.x end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.4 end,
        h = function(max) return max.h * 0.8 end
    },
    rightSmall = {  -- Small right side
        x = function(max) return max.x + (max.w * 0.6) end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.4 end,
        h = function(max) return max.h * 0.8 end
    },
    topLeft = {  -- Top left corner
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    topRight = {  -- Top right corner
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    bottomLeft = {  -- Bottom left corner
        x = function(max) return max.x end,
        y = function(max) return max.y + (max.h / 2) end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    bottomRight = {  -- Bottom right corner
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y + (max.h / 2) end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    leftWide = {  -- 72% left side
        x = function(max) return max.x + 30 end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.72 - 30 end,
        h = function(max) return max.h * 0.98 end
    },
    rightNarrow = {  -- 27% right side
        x = function(max) return max.x + (max.w * 0.73) end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.27 end,
        h = function(max) return max.h * 0.98 end
    }
}

function miniShuffle()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local max = screen:frame()

    -- Get current layout based on counter
    local layout = miniLayouts[(counter % #miniLayouts) + 1]

    -- Create new frame using layout functions
    local newFrame = {
        x = layout.x(max),
        y = layout.y(max),
        w = layout.w(max),
        h = layout.h(max)
    }

    -- Apply the frame
    win:setFrame(newFrame)

    -- Increment counter
    counter = (counter + 1) % #miniLayouts
end

local colCounter = 0
local rowCounter = 0

function halfShuffle(numRows, numCols)
    log.i('Half shuffle called:', { rows = numRows, cols = numCols })

    numRows = numRows or 3
    numCols = numCols or 2

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

    local sectionWidth = max.w / numCols
    local sectionHeight = max.h / numRows

    local x = max.x + (colCounter * sectionWidth)
    local y = max.y + (rowCounter * sectionHeight)

    f.x = x
    f.y = y
    f.w = sectionWidth
    f.h = sectionHeight

    log.d('New window frame:', hs.inspect(f))
    win:setFrame(f)

    rowCounter = (rowCounter + 1) % numRows
    if rowCounter == 0 then
        colCounter = (colCounter + 1) % numCols
    end
    log.d('Row counter:', rowCounter, 'Col counter:', colCounter)
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
    applyLayout(position)
end

function moveSide(side, isSmall)
    if side == "left" then
        if isSmall then
            applyLayout('leftSmall')
        else
            applyLayout('leftHalf')
        end
    else
        if isSmall then
            applyLayout('rightSmall')
        else
            applyLayout('rightHalf')
        end
    end
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
    applyLayout('fullScreen')
end                                                                                      -- hammer 3     -- full screen

function nearlyFullScreen()
    applyLayout('nearlyFull')
end                                                                                -- _hyper 3     -- 80% full screen centered

function moveWindow95By72FromLeftSide()
    applyLayout('leftWide')
end

function moveWindow95By30FromRightSide()
    applyLayout('rightNarrow')
end                                                                   -- hammer 4     -- Move window 95 by 72 left side

function leftSideSmall()
    applyLayout('leftSmall')
end                                                                                   -- hammer 6     -- smaller left side

function leftSide()
    applyLayout('leftHalf')
end                                                                                        -- _hyper 6     -- left half

function rightSideSmall()
    applyLayout('rightSmall')
end                                                                                  -- hammer 7     -- smaller right side

function rightSide()
    applyLayout('rightHalf')
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
    P     -- PyCharm                                         B     -- Arc Browser  \
    D     -- AnythingLLM                                Y     -- Countdown Timer  \
    L     -- Logi Options+                                F     -- Scrcpy  \
    M     -- Media Play/Pause                        S     -- Slack  \
    G     -- GitHub Desktop                           E     -- Edit File Menu  \
    T     -- Barrier                                              F1    -- Toggle HS Console  \
    F2    -- Post S22                                        F3    -- Toggle USB Logging  \
    F4    -- Toggle Key Logging                   F5    -- Reload HS  \
    F6    -- Save Window Position              F7    -- Restore Window Position  \
    F8    -- Set Target Window                    0     -- Horizontal Shuffle  \
    1     -- Move Top-Left Corner                2     -- Move Top-Right Corner  \
    3     -- Full Screen                                     4     -- Move Window 95/72 Left Side  \
    6     -- Small Left Side                             7     -- Small Right Side  \
    8     -- Layouts Menu                              9     -- Move Window to Mouse Center  \
    Left  -- Move Window Left                   Right -- Move Window Right  \
    Up    -- Move Window Up                     Down  -- Move Window Down  \
    -     -- Show This List                               `     -- Cursor  \
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


function applyLayout(layoutName)
    local win = hs.window.focusedWindow()
    if not win then
        log.w('No focused window found')
        return
    end

    local layout = standardLayouts[layoutName]
    if not layout then
        log.e('Invalid layout name:', layoutName)
        return
    end

    local screen = win:screen()
    local max = screen:frame()
    local f = win:frame()

    -- Apply the layout functions
    f.x = layout.x(max)
    f.y = layout.y(max)
    f.w = layout.w(max)
    f.h = layout.h(max)

    win:setFrame(f)
    log.i('Applied layout:', layoutName)
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
function open_github()
    hs.application.launchOrFocus("GitHub Desktop")
end

function open_slack()
    hs.application.launchOrFocus("Slack")
end

function open_arc()
    hs.application.launchOrFocus("Arc")
end

function open_chrome()
    hs.application.launchOrFocus("Google Chrome")
end

function open_pycharm()
    hs.application.launchOrFocus("PyCharm Community Edition")
end

function open_anythingllm()
    hs.application.launchOrFocus("AnythingLLM")
end

function open_mongodb()
    hs.application.launchOrFocus("MongoDB Compass")
end

function open_logi()
    hs.application.launchOrFocus("logioptionsplus")
end

function open_system()
    hs.application.launchOrFocus("System Preferences")
end

function open_vscode()
    hs.application.launchOrFocus("Visual Studio Code")
end

function open_cursor()
    hs.application.launchOrFocus("cursor")
end

function open_barrier()
    hs.execute("open -a 'Barrier'")
end

function open_mission_control()
    hs.application.launchOrFocus("Mission Control.app")
end

function open_launchpad()
    hs.application.launchOrFocus("Launchpad")
end

-- @formatter:off

function clock()
    spoon.AClock:toggleShow()
end

function top_left()
    moveToCorner("topLeft")
end

function top_right()
    moveToCorner("topRight")
end

function bottom_left()
    moveToCorner("bottomLeft")
end

function bottom_right()
    moveToCorner("bottomRight")
end


hs.hotkey.bind(hammer, "i", openMostRecentImage)
hs.hotkey.bind(_hyper, "w", clock)
hs.hotkey.bind(hammer, "p", open_pycharm)
hs.hotkey.bind(_hyper, "p", open_cursor)
hs.hotkey.bind(hammer, "b", open_arc)
hs.hotkey.bind(_hyper, "b", open_chrome)
hs.hotkey.bind(hammer, "d", open_anythingllm)
hs.hotkey.bind(_hyper, "d", open_mongodb)
hs.hotkey.bind(hammer, "y", tempFunction)
hs.hotkey.bind(hammer, "l", open_logi)
hs.hotkey.bind(_hyper, "l", open_system)
hs.hotkey.bind(hammer, "f", function() hs.execute("open -a '/opt/homebrew/bin/scrcpy -S'") end)
-- hs.hotkey.bind(hammer, "m", function() hs.eventtap.event.newSystemKeyEvent('PLAY', true):post() end)
hs.hotkey.bind(_hyper, "m", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)
hs.hotkey.bind(hammer, "s", open_slack)
hs.hotkey.bind(hammer, "g", open_github)
hs.hotkey.bind("cmd", "F3", open_github)
--hs.hotkey.bind(hammer, "e", function() hs.execute("open -a '" .. editor .. "' ~/.zshenv") end)
hs.hotkey.bind(hammer, "e", function() showFileMenu() end)
hs.hotkey.bind(_hyper, "e", function() showEditorMenu() end)
--hs.hotkey.bind(_hyper, "e", function() hs.execute("open -a '" .. editor .. "' ~/.hammerspoon/hotke
hs.hotkey.bind(hammer, "t", function() hs.execute("open -a '" .. editor .. "' ~/lab/tasks.py") end)
hs.hotkey.bind(hammer, "z", function() hs.execute("open -a '" .. editor .. "' ~/.bash_aliases") end)
hs.hotkey.bind(_hyper, "z", function() hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)
hs.hotkey.bind(_hyper, "F1", function() hs.application.launchOrFocus("Console") end)
hs.hotkey.bind(hammer, "F2", function() hs.execute("open -a 'post P9 var=:=Task beep'") end)
--hs.hotkey.bind(hammer, "F2", function() hs.application.launchOrFocus("Marta") end)
hs.hotkey.bind(_hyper, "F2", function() hs.execute("marta ~/lab") end)
hs.hotkey.bind(hammer, "F3", function() toggleUSBLogging() end)
hs.hotkey.bind(_hyper, "F3", shuffleLayouts)
--hs.hotkey.bind(_hyper, "F3", function() tempFunction() end)
hs.hotkey.bind(hammer, "F4", function() toggleKeyLogging() end)
hs.hotkey.bind(_hyper, "F4", function() tempFunction() end)
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)
hs.hotkey.bind(_hyper, "F5", function() tempFunction() end)
hs.hotkey.bind(hammer, "F6", saveWindowPosition)
hs.hotkey.bind(_hyper, "F6", saveAllWindowPositions)
hs.hotkey.bind(hammer, "F7", restoreWindowPosition)
hs.hotkey.bind(_hyper, "F7", restoreAllWindowPositions)
hs.hotkey.bind(hammer, "F8", function() setTargetWindow() end)
hs.hotkey.bind(_hyper, "F8", function() tempFunction() end)
hs.hotkey.bind(_hyper, "F11", nil, function() moveWindowOneSpace("left", false) end)
hs.hotkey.bind(_hyper, "F12", nil, function() moveWindowOneSpace("right", false) end)
hs.hotkey.bind("shift", "F13", function() hs.execute("open ~/Pictures/Greenshot") end)
hs.hotkey.bind(hammer, "0", function() halfShuffle(4, 3) end)
hs.hotkey.bind(_hyper, "0", function() halfShuffle(12, 3) end)
hs.hotkey.bind(hammer, "3", function() fullScreen() end)
hs.hotkey.bind(_hyper, "3", function() nearlyFullScreen() end)
hs.hotkey.bind(hammer, "4", function() moveWindow95By72FromLeftSide() end)
hs.hotkey.bind(_hyper, "4", function() miniShuffle() end)
hs.hotkey.bind(hammer, "5", function() tempFunction() end)
hs.hotkey.bind(_hyper, "5", function() tempFunction() end)
spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()
hs.hotkey.bind(_hyper, "8", function() tempFunction() end)
hs.hotkey.bind(hammer, "9", function() moveWindowMouseCenter() end)
hs.hotkey.bind(_hyper, "9", function() openSelectedFile() end)
hs.hotkey.bind(hammer, "Space", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", function() showHyperList() end)
hs.hotkey.bind(hammer, "`", open_cursor)
hs.hotkey.bind(_hyper, "`", open_vscode)
hs.hotkey.bind(hammer, "Tab", open_mission_control)
hs.hotkey.bind(_hyper, "Tab", open_launchpad)
hs.hotkey.bind(hammer, "t", open_barrier)
--hs.hotkey.bind(hammer, "H", function () showavailableHotkey() end)



-- Corner bindings
hs.hotkey.bind(hammer, "1", top_left)
hs.hotkey.bind(_hyper, "1", bottom_left)
hs.hotkey.bind(hammer, "2", top_right)
hs.hotkey.bind(_hyper, "2", bottom_right)

function move_left()
    moveSide("left", true)
end

function move_right()
    moveSide("right", true)
end


-- Side bindings
hs.hotkey.bind(hammer, "6", function() moveSide("left", true) end)
hs.hotkey.bind(_hyper, "6", function() moveSide("left", false) end)
hs.hotkey.bind(hammer, "7", function() moveSide("right", true) end)
hs.hotkey.bind(_hyper, "7", function() moveSide("right", false) end)

-- Window movement bindings
hs.hotkey.bind(hammer, "left", function() moveWindow("left") end)
hs.hotkey.bind(_hyper, "left", function() moveToScreen("previous", "right") end)
hs.hotkey.bind(hammer, "right", function() moveWindow("right") end)
hs.hotkey.bind(_hyper, "right", function() moveToScreen("next", "right") end)
hs.hotkey.bind(hammer, "up", function() moveWindow("up") end)
hs.hotkey.bind(_hyper, "up", function() tempFunction() end)
hs.hotkey.bind(hammer, "down", function() moveWindow("down") end)
hs.hotkey.bind(_hyper, "down", function() tempFunction() end)

-- Add bindings for remaining keys
-- hs.hotkey.bind(hammer, "a", tempFunction) -- hammer A
-- hs.hotkey.bind(hammer, "s", tempFunction) -- hammer S
-- hs.hotkey.bind(hammer, "d", tempFunction) -- hammer D
-- hs.hotkey.bind(hammer, "f", tempFunction) -- hammer F
-- hs.hotkey.bind(hammer, "g", tempFunction) -- hammer G
-- hs.hotkey.bind(hammer, "h", tempFunction) -- hammer H
-- hs.hotkey.bind(hammer, "j", tempFunction) -- hammer J
-- hs.hotkey.bind(hammer, "k", tempFunction) -- hammer K
-- hs.hotkey.bind(hammer, "l", tempFunction) -- hammer L
-- hs.hotkey.bind(hammer, ";", tempFunction) -- hammer ;
-- hs.hotkey.bind(hammer, "'", tempFunction) -- hammer '
-- hs.hotkey.bind(hammer, "z", tempFunction) -- hammer Z
-- hs.hotkey.bind(hammer, "x", tempFunction) -- hammer X
-- hs.hotkey.bind(hammer, "c", tempFunction) -- hammer C
-- hs.hotkey.bind(hammer, "v", tempFunction) -- hammer V
-- hs.hotkey.bind(hammer, "b", tempFunction) -- hammer B
-- hs.hotkey.bind(hammer, "n", tempFunction) -- hammer N
-- hs.hotkey.bind(hammer, "m", tempFunction) -- hammer M
-- hs.hotkey.bind(hammer, ",", tempFunction) -- hammer ,
-- hs.hotkey.bind(hammer, ".", tempFunction) -- hammer .
-- hs.hotkey.bind(hammer, "/", tempFunction) -- hammer /
-- hs.hotkey.bind(hammer, "0", tempFunction) -- hammer 0
-- hs.hotkey.bind(hammer, "1", tempFunction) -- hammer 1
-- hs.hotkey.bind(hammer, "2", tempFunction) -- hammer 2
-- hs.hotkey.bind(hammer, "3", tempFunction) -- hammer 3
-- hs.hotkey.bind(hammer, "4", tempFunction) -- hammer 4
-- hs.hotkey.bind(hammer, "5", tempFunction) -- hammer 5
-- hs.hotkey.bind(hammer, "6", tempFunction) -- hammer 6
-- hs.hotkey.bind(hammer, "7", tempFunction) -- hammer 7
-- hs.hotkey.bind(hammer, "8", tempFunction) -- hammer 8
-- hs.hotkey.bind(hammer, "9", tempFunction) -- hammer 9

-- Dragon Grid implementation
local dragonGridCanvas = nil
local isSecondLevel = false
local firstLevelSelection = nil
local gridSize = 3

function createDragonGrid()
    -- Clean up any existing grid
    if dragonGridCanvas then
        destroyDragonGrid()
    end

    isSecondLevel = false
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()

    dragonGridCanvas = hs.canvas.new(screenFrame)
    dragonGridCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    dragonGridCanvas:level(hs.canvas.windowLevels.overlay)

    -- Add semi-transparent background
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.3 },
        frame = { x = 0, y = 0, w = screenFrame.w, h = screenFrame.h }
    })

    -- Create the grid cells
    local cellWidth = screenFrame.w / gridSize
    local cellHeight = screenFrame.h / gridSize

    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = col * cellWidth
            local y = row * cellHeight

            -- Add cell border
            dragonGridCanvas:appendElements({
                type = "rectangle",
                action = "stroke",
                strokeColor = { white = 1, alpha = 0.8 },
                strokeWidth = 2,
                frame = { x = x, y = y, w = cellWidth, h = cellHeight }
            })

            -- Add cell number
            dragonGridCanvas:appendElements({
                type = "text",
                action = "fill",
                frame = { x = x + cellWidth / 2 - 20, y = y + cellHeight / 2 - 20, w = 40, h = 40 },
                text = tostring(cellNum),
                textSize = 30,
                textColor = { white = 1 },
                textAlignment = "center"
            })
        end
    end

    -- Show the grid
    dragonGridCanvas:show()

    -- Set up click handler for the entire canvas
    dragonGridCanvas:clickCallback(function(canvas, event, id, x, y)
        if event == "mouseUp" then
            handleGridClick(x, y, screenFrame)
        end
    end)
end

function handleGridClick(x, y, screenFrame)
    local cellWidth = screenFrame.w / gridSize
    local cellHeight = screenFrame.h / gridSize

    -- Calculate which cell was clicked
    local col = math.floor(x / cellWidth)
    local row = math.floor(y / cellHeight)
    local cellNum = row * gridSize + col + 1

    if not isSecondLevel then
        -- First level selection
        firstLevelSelection = {
            row = row,
            col = col,
            x = col * cellWidth,
            y = row * cellHeight,
            w = cellWidth,
            h = cellHeight
        }
        createSecondLevelGrid(firstLevelSelection)
    else
        -- Second level selection (final)
        local firstX = firstLevelSelection.x
        local firstY = firstLevelSelection.y
        local firstW = firstLevelSelection.w
        local firstH = firstLevelSelection.h

        -- Calculate precise position within the cell
        local secondCellWidth = firstW / gridSize
        local secondCellHeight = firstH / gridSize

        local secondCol = math.floor((x - firstX) / secondCellWidth)
        local secondRow = math.floor((y - firstY) / secondCellHeight)

        -- Calculate the exact position to move the mouse to
        local finalX = firstX + secondCol * secondCellWidth + secondCellWidth / 2
        local finalY = firstY + secondRow * secondCellHeight + secondCellHeight / 2

        -- Move the mouse cursor to the selected position
        hs.mouse.absolutePosition({ x = finalX, y = finalY })

        -- Destroy the grid
        destroyDragonGrid()
    end
end

function createSecondLevelGrid(cell)
    -- Switch to second level mode
    isSecondLevel = true

    -- Clear the canvas
    dragonGridCanvas:deleteSections()

    -- Add semi-transparent overlay for areas outside the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
        frame = { x = 0, y = 0, w = cell.x, h = cell.y + cell.h }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
        frame = { x = cell.x + cell.w, y = 0, w = hs.screen.mainScreen():frame().w - (cell.x + cell.w), h = cell.y + cell.h }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
        frame = { x = 0, y = cell.y + cell.h, w = hs.screen.mainScreen():frame().w, h = hs.screen.mainScreen():frame().h - (cell.y + cell.h) }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0, green = 0, blue = 0, alpha = 0.5 },
        frame = { x = 0, y = 0, w = hs.screen.mainScreen():frame().w, h = cell.y }
    })

    -- Create a second level grid inside the selected cell
    local secondCellWidth = cell.w / gridSize
    local secondCellHeight = cell.h / gridSize

    -- Add highlight for the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.2, green = 0.3, blue = 0.4, alpha = 0.4 },
        frame = { x = cell.x, y = cell.y, w = cell.w, h = cell.h }
    })

    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = cell.x + col * secondCellWidth
            local y = cell.y + row * secondCellHeight

            -- Add cell border
            dragonGridCanvas:appendElements({
                type = "rectangle",
                action = "stroke",
                strokeColor = { red = 1, green = 1, blue = 1, alpha = 0.8 },
                strokeWidth = 1,
                frame = { x = x, y = y, w = secondCellWidth, h = secondCellHeight }
            })

            -- Add cell number
            dragonGridCanvas:appendElements({
                type = "text",
                action = "fill",
                frame = { x = x + secondCellWidth / 2 - 15, y = y + secondCellHeight / 2 - 15, w = 30, h = 30 },
                text = tostring(cellNum),
                textSize = 20,
                textColor = { white = 1 },
                textAlignment = "center"
            })
        end
    end
end

function destroyDragonGrid()
    if dragonGridCanvas then
        dragonGridCanvas:delete()
        dragonGridCanvas = nil
    end
    isSecondLevel = false
    firstLevelSelection = nil
end

function toggleDragonGrid()
    if dragonGridCanvas then
        destroyDragonGrid()
    else
        createDragonGrid()
    end
end

-- Bind Dragon Grid to a hotkey
hs.hotkey.bind(hammer, "d", toggleDragonGrid)
