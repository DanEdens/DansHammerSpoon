-- Use HyperLogger for clickable debugging logs
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('DragonGrid', 'debug')
log:i('Initializing DragonGrid module')

local DragonGrid = {}

local dragonGridCanvas = nil
local currentLevel = 0
local maxLayers = 4         -- Default number of layers
local selectionHistory = {} -- Will store all selections at each level
local gridSize = 3
local modalKey = nil -- Will hold the modal key instance
local dragMode = false
local dragStart = nil
local windowMode = false -- Full screen or window-only mode
local gridHotkeys = {}   -- Table to hold hotkey bindings
local menubar = nil      -- Menubar object for settings

-- Initialize with default configuration
local config = {
    gridSize = 3,
    maxLayers = 2, -- Default to 2 layers, 1st for rough positioning, 2nd for fine positioning
    colors = {
        background = { red = 0, green = 0, blue = 0, alpha = 0.3 },
        cellBorder = { white = 1, alpha = 0.8 },
        cellText = { white = 1 },
        selectedCell = { red = 0.2, green = 0.3, blue = 0.4, alpha = 0.4 },
        outsideArea = { red = 0, green = 0, blue = 0, alpha = 0.5 }
    }
}

function DragonGrid.createDragonGrid()
    -- Clean up any existing grid
    if dragonGridCanvas then
        DragonGrid.destroyDragonGrid()
    end

    currentLevel = 1
    selectionHistory = {}
    dragMode = false
    dragStart = nil

    -- Get the screen where the mouse cursor is currently located
    local mousePos = hs.mouse.absolutePosition()
    local currentScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()

    log:d("Mouse position: x=" .. mousePos.x .. ", y=" .. mousePos.y)
    log:d("Using screen: " .. (currentScreen:name() or "unnamed"))
    local frame
    if windowMode then
        local win = hs.window.focusedWindow()
        if not win then
            log:w("No focused window found, using current screen")
            frame = currentScreen:frame()
        else
            frame = win:frame()
        end
    else
        frame = currentScreen:frame()
    end

    log:d("Creating level 1 grid at x=" .. frame.x .. ", y=" .. frame.y ..
        ", w=" .. frame.w .. ", h=" .. frame.h)
    dragonGridCanvas = hs.canvas.new(frame)
    dragonGridCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    dragonGridCanvas:level(hs.canvas.windowLevels.overlay)

    -- Add semi-transparent background
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.background,
        frame = { x = 0, y = 0, w = frame.w, h = frame.h }
    })

    -- Add status indicator at the top
    local modeText = windowMode and "WINDOW MODE" or "SCREEN MODE"
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 10, w = 300, h = 30 },
        text = modeText .. " | LEVEL 1 OF " .. maxLayers .. " | POS=" ..
            math.floor(frame.x) .. "," .. math.floor(frame.y),
        textSize = 16,
        textColor = { white = 1, alpha = 0.8 },
        textAlignment = "left"
    })

    -- Create the grid cells
    local cellWidth = frame.w / gridSize
    local cellHeight = frame.h / gridSize

    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = col * cellWidth
            local y = row * cellHeight

            -- Add cell border
            dragonGridCanvas:appendElements({
                type = "rectangle",
                action = "stroke",
                strokeColor = config.colors.cellBorder,
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
                textColor = config.colors.cellText,
                textAlignment = "center"
            })
        end
    end
    -- Add help text at the bottom for keyboard commands
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = frame.h - 30, w = frame.w - 20, h = 20 },
        text = "Use keys: ⌘1-9 (cells 1-9) | ⌘⇧1-9 (cells 10-18) | ⌘⇧⌥1-9 (cells 19-27) | ⌘Space=Click | ⌘Esc=Cancel",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- Add second line of help text
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = frame.h - 50, w = frame.w - 20, h = 20 },
        text = "⌘U=Undo | ⌘W=Toggle Mode | ⌘M=Start Drag | ⌘D=Complete Drag | Or click cells directly",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- Show the grid
    dragonGridCanvas:show()

    -- Set up click handler for the entire canvas
    dragonGridCanvas:mouseCallback(function(canvas, event, id, x, y)
        if event == "mouseUp" then
            DragonGrid.handleGridClick(x, y)
        end
    end)
    -- Set up keyboard hotkeys with hammer modifier
    -- We'll use the hammer modifiers (cmd+ctrl+alt) for all grid operations
    -- This ensures they won't conflict with normal keyboard input

    -- Clean up any existing hotkeys
    DragonGrid.unbindHotkeys()

    -- Use our helper function to bind grid selection hotkeys
    DragonGrid.bindGridHotkeys()

    -- Define our modifiers for action keys
    local mods = { "cmd" }

    -- Action keys
    local escapeKey = hs.hotkey.bind(mods, "escape", function()
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, escapeKey)

    local returnKey = hs.hotkey.bind(mods, "return", function()
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, returnKey)

    local undoKey = hs.hotkey.bind(mods, "u", function()
        if currentLevel > 1 then
            currentLevel = currentLevel - 1
            selectionHistory[currentLevel] = nil
            -- If we go back to level 1, recreate the initial grid
            if currentLevel == 1 then
                DragonGrid.createDragonGrid()
            else
                DragonGrid.createNextLevelGrid()
            end
        else
            DragonGrid.destroyDragonGrid()
        end
    end)
    table.insert(gridHotkeys, undoKey)

    -- Mouse actions
    local spaceKey = hs.hotkey.bind(mods, "space", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.leftClick(pos)
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, spaceKey)

    local rightClickKey = hs.hotkey.bind(mods, "r", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.rightClick(pos)
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, rightClickKey)

    -- Mode toggle
    local modeKey = hs.hotkey.bind(mods, "w", function()
        windowMode = not windowMode
        if windowMode then
            hs.alert.show("Window mode")
        else
            hs.alert.show("Screen mode")
        end

        DragonGrid.createDragonGrid()
    end)
    table.insert(gridHotkeys, modeKey)

    -- Mark for drag
    local markKey = hs.hotkey.bind(mods, "m", function()
        dragMode = true
        dragStart = nil
        hs.alert.show("Drag mode activated")
    end)
    table.insert(gridHotkeys, markKey)

    -- Complete drag
    local dragKey = hs.hotkey.bind(mods, "d", function()
        if dragStart then
            local pos = hs.mouse.absolutePosition()
            hs.eventtap.leftMouseDown(dragStart)
            hs.timer.doAfter(0.1, function()
                hs.mouse.absolutePosition(pos)
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.leftMouseUp()
                    dragMode = false
                    dragStart = nil
                    DragonGrid.destroyDragonGrid()
                end)
            end)
        else
            hs.alert.show("Set mark position first with ⌘M")
        end
    end)
    table.insert(gridHotkeys, dragKey)
end

function DragonGrid.handleGridClick(x, y)
    log:d("Grid click at x:" .. x .. ", y:" .. y)

    if currentLevel > 1 then
        -- We're in a higher level grid
        local currentSelection = selectionHistory[currentLevel - 1]

        -- Check if the click is within the current selection
        if x < currentSelection.x or x > (currentSelection.x + currentSelection.w) or
            y < currentSelection.y or y > (currentSelection.y + currentSelection.h) then
            -- Click is outside the current selection area
            log:d("Click outside current grid area - ignoring")
            return
        end

        -- Calculate which cell was clicked within the current selection
        local cellWidth = currentSelection.w / gridSize
        local cellHeight = currentSelection.h / gridSize

        local col = math.floor((x - currentSelection.x) / cellWidth)
        local row = math.floor((y - currentSelection.y) / cellHeight)
        local cellNum = row * gridSize + col + 1

        log:d("Clicked on level " .. currentLevel .. " cell " .. cellNum ..
            " at row " .. row .. ", col " .. col)
        DragonGrid.handleNumberKey(cellNum)
    else
        -- First level grid
        local frame
        if windowMode then
            local win = hs.window.focusedWindow()
            if not win then
                -- First find which screen the click is on
                local clickScreen = nil
                for _, screen in pairs(hs.screen.allScreens()) do
                    local screenFrame = screen:frame()
                    if x >= screenFrame.x and x <= screenFrame.x + screenFrame.w and
                        y >= screenFrame.y and y <= screenFrame.y + screenFrame.h then
                        clickScreen = screen
                        break
                    end
                end

                if not clickScreen then
                    clickScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
                end

                frame = clickScreen:frame()
                log:d("Click on screen: " .. (clickScreen:name() or "unnamed"))
            else
                frame = win:frame()
            end
        else
            -- First find which screen the click is on
            local clickScreen = nil
            for _, screen in pairs(hs.screen.allScreens()) do
                local screenFrame = screen:frame()
                if x >= screenFrame.x and x <= screenFrame.x + screenFrame.w and
                    y >= screenFrame.y and y <= screenFrame.y + screenFrame.h then
                    clickScreen = screen
                    break
                end
            end

            if not clickScreen then
                clickScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
            end

            frame = clickScreen:frame()
            log:d("Click on screen: " .. (clickScreen:name() or "unnamed"))
        end

        -- Calculate which cell was clicked
        local relX = x - frame.x
        local relY = y - frame.y
        local cellWidth = frame.w / gridSize
        local cellHeight = frame.h / gridSize

        local col = math.floor(relX / cellWidth)
        local row = math.floor(relY / cellHeight)
        local cellNum = row * gridSize + col + 1

        log:d("Clicked on level 1 cell " .. cellNum .. " at row " .. row .. ", col " .. col)
        DragonGrid.handleNumberKey(cellNum)
    end
end

function DragonGrid.handleNumberKey(number)
    log:d("Handling number key: " .. number)
    if number < 1 or number > (gridSize * gridSize) then
        log:w("Invalid cell number: " .. number)
        return
    end

    if dragMode and not dragStart then
        -- In drag mode, first mark position
        dragStart = hs.mouse.absolutePosition()
        log:d("Setting drag start to " .. dragStart.x .. "," .. dragStart.y)
        hs.alert.show("Start position marked")
        return
    end

    -- Calculate row and column from the cell number
    local row = math.floor((number - 1) / gridSize)
    local col = (number - 1) % gridSize

    -- Move mouse to cell position
    if currentLevel == 1 then
        -- First level grid - need absolute screen coordinates
        local frame
        if windowMode then
            local win = hs.window.focusedWindow()
            if not win then
                frame = hs.mouse.getCurrentScreen():frame()
            else
                frame = win:frame()
            end
        else
            frame = hs.mouse.getCurrentScreen():frame()
        end

        local cellWidth = frame.w / gridSize
        local cellHeight = frame.h / gridSize

        -- Center of the selected cell
        local x = frame.x + (col * cellWidth) + (cellWidth / 2)
        local y = frame.y + (row * cellHeight) + (cellHeight / 2)

        -- Store the selection for the next level
        selectionHistory[currentLevel] = {
            x = frame.x + (col * cellWidth),
            y = frame.y + (row * cellHeight),
            w = cellWidth,
            h = cellHeight
        }

        log:d("Selected level 1 cell at " .. x .. "," .. y)

        -- If at max layers, perform a click and exit
        if currentLevel >= maxLayers then
            hs.mouse.absolutePosition({ x = x, y = y })
            log:d("Reached max layers (" .. maxLayers .. "), positioning mouse and exiting")

            if dragMode and dragStart then
                -- In drag mode with start position, complete the drag
                hs.eventtap.leftMouseDown(dragStart)
                hs.timer.doAfter(0.1, function()
                    hs.mouse.absolutePosition({ x = x, y = y })
                    hs.timer.doAfter(0.1, function()
                        hs.eventtap.leftMouseUp()
                        log:d("Drag completed from " .. dragStart.x .. "," .. dragStart.y .. " to " .. x .. "," .. y)
                        dragMode = false
                        dragStart = nil
                        DragonGrid.destroyDragonGrid()
                    end)
                end)
            else
                -- Normal mode, just position mouse
                hs.mouse.absolutePosition({ x = x, y = y })
                DragonGrid.destroyDragonGrid()
            end
        else
            -- Position mouse and go deeper
            hs.mouse.absolutePosition({ x = x, y = y })
            currentLevel = currentLevel + 1
            log:d("Going to level " .. currentLevel)
            DragonGrid.createNextLevelGrid()
        end
    else
        -- Higher level grid - calculate relative to previous selection
        local currentSelection = selectionHistory[currentLevel - 1]
        local cellWidth = currentSelection.w / gridSize
        local cellHeight = currentSelection.h / gridSize

        -- Center of the selected cell
        local x = currentSelection.x + (col * cellWidth) + (cellWidth / 2)
        local y = currentSelection.y + (row * cellHeight) + (cellHeight / 2)

        -- Store the selection for the next level
        selectionHistory[currentLevel] = {
            x = currentSelection.x + (col * cellWidth),
            y = currentSelection.y + (row * cellHeight),
            w = cellWidth,
            h = cellHeight
        }

        log:d("Selected level " .. currentLevel .. " cell at " .. x .. "," .. y)

        -- If at max layers, perform a click and exit
        if currentLevel >= maxLayers then
            log:d("Reached max layers (" .. maxLayers .. "), positioning mouse and exiting")

            if dragMode and dragStart then
                -- In drag mode with start position, complete the drag
                hs.eventtap.leftMouseDown(dragStart)
                hs.timer.doAfter(0.1, function()
                    hs.mouse.absolutePosition({ x = x, y = y })
                    hs.timer.doAfter(0.1, function()
                        hs.eventtap.leftMouseUp()
                        log:d("Drag completed from " .. dragStart.x .. "," .. dragStart.y .. " to " .. x .. "," .. y)
                        dragMode = false
                        dragStart = nil
                        DragonGrid.destroyDragonGrid()
                    end)
                end)
            else
                -- Normal mode, just position mouse
                hs.mouse.absolutePosition({ x = x, y = y })
                DragonGrid.destroyDragonGrid()
            end
        else
            -- Position mouse and go deeper
            hs.mouse.absolutePosition({ x = x, y = y })
            currentLevel = currentLevel + 1
            log:d("Going to level " .. currentLevel)
            DragonGrid.createNextLevelGrid()
        end
    end
end

function DragonGrid.createNextLevelGrid()
    -- Delete the current canvas and create a new one
    if dragonGridCanvas then
        dragonGridCanvas:delete()
    end

    -- Unbind existing hotkeys
    DragonGrid.unbindHotkeys()

    -- Get the current selection (which represents our grid area)
    local currentSelection = selectionHistory[currentLevel - 1]
    -- Find the screen containing the selection center point
    local selectionCenter = {
        x = currentSelection.x + currentSelection.w / 2,
        y = currentSelection.y + currentSelection.h / 2
    }

    local currentScreen = nil
    for _, screen in pairs(hs.screen.allScreens()) do
        local screenFrame = screen:frame()
        if selectionCenter.x >= screenFrame.x and
            selectionCenter.x <= screenFrame.x + screenFrame.w and
            selectionCenter.y >= screenFrame.y and
            selectionCenter.y <= screenFrame.y + screenFrame.h then
            currentScreen = screen
            break
        end
    end

    -- Fallback to the screen with the mouse if we couldn't determine the screen
    if not currentScreen then
        currentScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
    end

    log:d("Using screen: " .. (currentScreen:name() or "unnamed") ..
        " for level " .. currentLevel .. " grid")

    log:d("Creating level " .. currentLevel .. " grid at x=" ..
        currentSelection.x .. ", y=" .. currentSelection.y ..
        ", w=" .. currentSelection.w .. ", h=" .. currentSelection.h)

    -- Create a new canvas with the exact dimensions of the selection area
    -- This is the key change - use the selection bounds directly instead of the full screen
    dragonGridCanvas = hs.canvas.new({
        x = currentSelection.x,
        y = currentSelection.y,
        w = currentSelection.w,
        h = currentSelection.h
    })
    dragonGridCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    dragonGridCanvas:level(hs.canvas.windowLevels.overlay)

    -- Add semi-transparent background
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.2, green = 0.5, blue = 0.8, alpha = 0.6 },
        frame = { x = 0, y = 0, w = currentSelection.w, h = currentSelection.h }
    })

    -- Add a distinctive border for the current grid
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { red = 1, green = 1, blue = 0.2, alpha = 0.9 },
        strokeWidth = 4,
        frame = { x = 0, y = 0, w = currentSelection.w, h = currentSelection.h }
    })

    -- Add status indicators at the top
    local modeText = windowMode and "WINDOW MODE" or "SCREEN MODE"
    local stateText = dragMode and "DRAG MODE - Select Target" or "PRECISION MODE"
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 10, w = currentSelection.w - 20, h = 30 },
        text = modeText .. " | " .. stateText .. " | POS=" ..
            math.floor(currentSelection.x) .. "," .. math.floor(currentSelection.y),
        textSize = 16,
        textColor = dragMode and { red = 1, green = 0.6, blue = 0.2, alpha = 0.9 }
            or { white = 1, alpha = 0.8 },
        textAlignment = "left"
    })

    -- Add a level indicator text
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 40, w = currentSelection.w - 20, h = 30 },
        text = "LEVEL " .. currentLevel .. " OF " .. maxLayers .. " - Make selection",
        textSize = 16,
        textColor = { red = 1, green = 0.8, blue = 0.2, alpha = 1.0 },
        textAlignment = "left"
    })
    -- Calculate cell dimensions for this level
    local cellWidth = currentSelection.w / gridSize
    local cellHeight = currentSelection.h / gridSize

    -- Draw grid cells
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = col * cellWidth
            local y = row * cellHeight

            log:d("Level " .. currentLevel .. " cell " .. cellNum ..
                " at x:" .. x .. ", y:" .. y .. ", w:" .. cellWidth .. ", h:" .. cellHeight)

            -- Add cell border
            dragonGridCanvas:appendElements({
                type = "rectangle",
                action = "stroke",
                strokeColor = config.colors.cellBorder,
                strokeWidth = 1,
                frame = { x = x, y = y, w = cellWidth, h = cellHeight }
            })

            -- Add cell number
            dragonGridCanvas:appendElements({
                type = "text",
                action = "fill",
                frame = {
                    x = x + cellWidth / 2 - 15,
                    y = y + cellHeight / 2 - 15,
                    w = 30,
                    h = 30
                },
                text = tostring(cellNum),
                textSize = 20,
                textColor = config.colors.cellText,
                textAlignment = "center"
            })
        end
    end

    -- Add help text at the bottom
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = currentSelection.h - 30, w = currentSelection.w - 20, h = 20 },
        text = "Keys: ⌘1-9 (1-9) | ⌘⇧1-9 (10-18) | ⌘⇧⌥1-9 (19-27) | ⌘Space=Click | ⌘Esc=Cancel | ⌘U=Back",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- If in drag mode and we have a start point, show it
    if dragMode and dragStart then
        -- Convert from absolute coordinates to canvas-relative coordinates
        local dragStartRelative = {
            x = dragStart.x - currentSelection.x,
            y = dragStart.y - currentSelection.y
        }

        -- Only show the drag start point if it's within our canvas area
        if dragStartRelative.x >= 0 and dragStartRelative.x <= currentSelection.w and
            dragStartRelative.y >= 0 and dragStartRelative.y <= currentSelection.h then
            dragonGridCanvas:appendElements({
                type = "circle",
                action = "fill",
                fillColor = { red = 1, green = 0.4, blue = 0.1, alpha = 0.7 },
                frame = { x = dragStartRelative.x - 10, y = dragStartRelative.y - 10, w = 20, h = 20 }
            })
        end
    end

    -- Show the grid
    dragonGridCanvas:show()

    -- Fix for click handling - we need to adjust the mouse callback to handle coordinates
    -- relative to the canvas position
    dragonGridCanvas:mouseCallback(function(canvas, event, id, x, y)
        if event == "mouseUp" then
            -- Convert canvas-relative coordinates to absolute screen coordinates
            local absX = x + currentSelection.x
            local absY = y + currentSelection.y
            DragonGrid.handleGridClick(absX, absY)
        end
    end)

    -- Set up keyboard hotkeys with modifier keys
    -- Define our modifiers
    local mods = { "cmd" }

    -- Use our helper function to bind grid selection hotkeys
    DragonGrid.bindGridHotkeys()

    -- Action keys
    local escapeKey = hs.hotkey.bind(mods, "escape", function()
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, escapeKey)

    local returnKey = hs.hotkey.bind(mods, "return", function()
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, returnKey)

    local undoKey = hs.hotkey.bind(mods, "u", function()
        if currentLevel > 1 then
            currentLevel = currentLevel - 1
            selectionHistory[currentLevel] = nil
            -- If we go back to level 1, recreate the initial grid
            if currentLevel == 1 then
                DragonGrid.createDragonGrid()
            else
                DragonGrid.createNextLevelGrid()
            end
        else
            DragonGrid.destroyDragonGrid()
        end
    end)
    table.insert(gridHotkeys, undoKey)

    -- Mouse actions
    local spaceKey = hs.hotkey.bind(mods, "space", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.leftClick(pos)
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, spaceKey)

    local rightClickKey = hs.hotkey.bind(mods, "r", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.rightClick(pos)
        DragonGrid.destroyDragonGrid()
    end)
    table.insert(gridHotkeys, rightClickKey)

    -- Complete drag
    local dragKey = hs.hotkey.bind(mods, "d", function()
        if dragStart then
            local pos = hs.mouse.absolutePosition()
            hs.eventtap.leftMouseDown(dragStart)
            hs.timer.doAfter(0.1, function()
                hs.mouse.absolutePosition(pos)
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.leftMouseUp()
                    dragMode = false
                    dragStart = nil
                    DragonGrid.destroyDragonGrid()
                end)
            end)
        else
            hs.alert.show("Set mark position first with ⌘M")
        end
    end)
    table.insert(gridHotkeys, dragKey)

    -- Mark for drag
    local markKey = hs.hotkey.bind(mods, "m", function()
        dragMode = true
        dragStart = nil
        hs.alert.show("Drag mode activated")
    end)
    table.insert(gridHotkeys, markKey)
end

function DragonGrid.destroyDragonGrid()
    -- Unbind all hotkeys
    DragonGrid.unbindHotkeys()
    if modalKey then
        modalKey:exit()
    end

    if dragonGridCanvas then
        dragonGridCanvas:delete()
        dragonGridCanvas = nil
    end

    currentLevel = 0
    selectionHistory = {}
    dragMode = false
    dragStart = nil
end

function DragonGrid.unbindHotkeys()
    for _, hotkey in ipairs(gridHotkeys) do
        hotkey:delete()
    end
    gridHotkeys = {}
end

function DragonGrid.toggleDragonGrid()
    if dragonGridCanvas then
        DragonGrid.destroyDragonGrid()
    else
        DragonGrid.createDragonGrid()
    end
end

-- Show settings menu for DragonGrid
function DragonGrid.showSettingsMenu()
    if menubar then
        menubar:delete()
        menubar = nil
        return
    end

    menubar = hs.menubar.new()
    menubar:setTitle("⊞") -- Grid symbol

    local function updateMenu()
        local menu = {
            { title = "DragonGrid Settings", disabled = true },
            { title = "-" },
            {
                title = "Grid Size",
                menu = {
                    {
                        title = "2x2",
                        checked = gridSize == 2,
                        fn = function()
                            DragonGrid.setConfig({ gridSize = 2 }); updateMenu()
                        end
                    },
                    {
                        title = "3x3",
                        checked = gridSize == 3,
                        fn = function()
                            DragonGrid.setConfig({ gridSize = 3 }); updateMenu()
                        end
                    },
                    {
                        title = "4x4",
                        checked = gridSize == 4,
                        fn = function()
                            DragonGrid.setConfig({ gridSize = 4 }); updateMenu()
                        end
                    },
                    {
                        title = "5x5",
                        checked = gridSize == 5,
                        fn = function()
                            DragonGrid.setConfig({ gridSize = 5 }); updateMenu()
                        end
                    }
                }
            },
            {
                title = "Precision Layers",
                menu = {
                    {
                        title = "1 Layer",
                        checked = maxLayers == 1,
                        fn = function()
                            DragonGrid.setConfig({ maxLayers = 1 }); updateMenu()
                        end
                    },
                    {
                        title = "2 Layers",
                        checked = maxLayers == 2,
                        fn = function()
                            DragonGrid.setConfig({ maxLayers = 2 }); updateMenu()
                        end
                    },
                    {
                        title = "3 Layers",
                        checked = maxLayers == 3,
                        fn = function()
                            DragonGrid.setConfig({ maxLayers = 3 }); updateMenu()
                        end
                    },
                    {
                        title = "4 Layers",
                        checked = maxLayers == 4,
                        fn = function()
                            DragonGrid.setConfig({ maxLayers = 4 }); updateMenu()
                        end
                    }
                }
            },
            { title = "-" },
            {
                title = "Mode",
                menu = {
                    {
                        title = "Screen Mode",
                        checked = not windowMode,
                        fn = function()
                            windowMode = false; updateMenu()
                        end
                    },
                    {
                        title = "Window Mode",
                        checked = windowMode,
                        fn = function()
                            windowMode = true; updateMenu()
                        end
                    }
                }
            },
            { title = "-" },
            {
                title = "Background Opacity",
                menu = {
                    {
                        title = "10%",
                        checked = config.colors.background.alpha == 0.1,
                        fn = function()
                            config.colors.background.alpha = 0.1
                            updateMenu()
                        end
                    },
                    {
                        title = "20%",
                        checked = config.colors.background.alpha == 0.2,
                        fn = function()
                            config.colors.background.alpha = 0.2
                            updateMenu()
                        end
                    },
                    {
                        title = "30%",
                        checked = config.colors.background.alpha == 0.3,
                        fn = function()
                            config.colors.background.alpha = 0.3
                            updateMenu()
                        end
                    },
                    {
                        title = "50%",
                        checked = config.colors.background.alpha == 0.5,
                        fn = function()
                            config.colors.background.alpha = 0.5
                            updateMenu()
                        end
                    }
                }
            },
            { title = "-" },
            {
                title = "Launch Grid",
                fn = function()
                    DragonGrid.toggleDragonGrid()
                end
            },
            { title = "-" },
            {
                title = "Close Menu",
                fn = function()
                    if menubar then
                        menubar:delete()
                        menubar = nil
                    end
                end
            }
        }

        menubar:setMenu(menu)
    end

    updateMenu()
end
-- Bind to hotkey directly (you can change this as needed)
function DragonGrid.bindHotkeys(mapping)
    local spec = {
        toggle = DragonGrid.toggleDragonGrid,
        window = function()
            windowMode = true; DragonGrid.createDragonGrid()
        end,
        screen = function()
            windowMode = false; DragonGrid.createDragonGrid()
        end,
        settings = DragonGrid.showSettingsMenu
    }

    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

-- Set or update configuration
function DragonGrid.setConfig(newConfig)
    for k, v in pairs(newConfig) do
        if type(v) == "table" and type(config[k]) == "table" then
            for k2, v2 in pairs(v) do
                config[k][k2] = v2
            end
        else
            config[k] = v
        end
    end

    -- Update grid size if provided
    if newConfig.gridSize then
        gridSize = newConfig.gridSize
    end
    -- Update max layers if provided
    if newConfig.maxLayers then
        maxLayers = newConfig.maxLayers
    end

    return self
end
-- Helper function to bind hotkeys for different cell number ranges
function DragonGrid.bindGridHotkeys()
    -- The total number of cells in the grid
    local totalCells = gridSize * gridSize

    -- Clean up existing hotkeys
    DragonGrid.unbindHotkeys()

    -- Bind hotkeys for cells 1-9 with cmd only
    local mods1 = { "cmd" }
    for i = 1, math.min(9, totalCells) do
        local hotkey = hs.hotkey.bind(mods1, tostring(i), function()
            DragonGrid.handleNumberKey(i)
        end)
        table.insert(gridHotkeys, hotkey)
    end

    -- Bind hotkeys for cells 10-18 with cmd+shift
    if totalCells > 9 then
        local mods2 = { "cmd", "shift" }
        for i = 1, math.min(9, totalCells - 9) do
            local cellNum = i + 9
            local hotkey = hs.hotkey.bind(mods2, tostring(i), function()
                DragonGrid.handleNumberKey(cellNum)
            end)
            table.insert(gridHotkeys, hotkey)
        end
    end

    -- Bind hotkeys for cells 19-27 with cmd+shift+alt
    if totalCells > 18 then
        local mods3 = { "cmd", "shift", "alt" }
        for i = 1, math.min(9, totalCells - 18) do
            local cellNum = i + 18
            local hotkey = hs.hotkey.bind(mods3, tostring(i), function()
                DragonGrid.handleNumberKey(cellNum)
            end)
            table.insert(gridHotkeys, hotkey)
        end
    end
end
return DragonGrid
