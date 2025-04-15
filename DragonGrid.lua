local log = hs.logger.new('DragonGrid', 'debug')
log.i('Initializing DragonGrid module')

local DragonGrid = {}

local dragonGridCanvas = nil
local currentLevel = 0
local maxLayers = 3         -- Default number of layers
local selectionHistory = {} -- Will store all selections at each level
local gridSize = 3
local modalKey = nil -- Will hold the modal key instance
local dragMode = false
local dragStart = nil
local windowMode = false -- Full screen or window-only mode
local gridHotkeys = {}   -- Table to hold hotkey bindings

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

    local frame
    if windowMode then
        local win = hs.window.focusedWindow()
        if not win then
            log.w("No focused window found, using full screen")
            frame = hs.screen.mainScreen():frame()
        else
            frame = win:frame()
        end
    else
        frame = hs.screen.mainScreen():frame()
    end

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
        text = "Use modifier keys: ⌘1-9=Select | ⌘Space=Click | ⌘Esc=Cancel | ⌘U=Undo | ⌘W=Toggle Mode",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- Add additional help text for mouse
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = frame.h - 50, w = frame.w - 20, h = 20 },
        text = "Or click directly on cells with your mouse",
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

    -- Define our hammer modifiers
    -- local mods = { "cmd", "shift", "alt" }
    -- local mods = { "shift" }
    local mods = { "cmd" }

    -- Number keys for grid selection
    for i = 1, 9 do
        local hotkey = hs.hotkey.bind(mods, tostring(i), function()
            DragonGrid.handleNumberKey(i)
        end)
        table.insert(gridHotkeys, hotkey)
    end

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
    log.d("Grid click at x:" .. x .. ", y:" .. y)
    
    if currentLevel > 1 then
        -- We're in a higher level grid
        local currentSelection = selectionHistory[currentLevel - 1]
        
        -- Check if the click is within the current selection
        if x < currentSelection.x or x > (currentSelection.x + currentSelection.w) or
            y < currentSelection.y or y > (currentSelection.y + currentSelection.h) then
            -- Click is outside the current selection area
            log.d("Click outside current grid area - ignoring")
            return
        end
        
        -- Calculate which cell was clicked within the current selection
        local cellWidth = currentSelection.w / gridSize
        local cellHeight = currentSelection.h / gridSize
        
        local col = math.floor((x - currentSelection.x) / cellWidth)
        local row = math.floor((y - currentSelection.y) / cellHeight)
        local cellNum = row * gridSize + col + 1
        
        log.d("Clicked on level " .. currentLevel .. " cell " .. cellNum ..
            " at row " .. row .. ", col " .. col)
        DragonGrid.handleNumberKey(cellNum)
    else
        -- First level grid
        local frame
        if windowMode then
            local win = hs.window.focusedWindow()
            if not win then
                frame = hs.screen.mainScreen():frame()
            else
                frame = win:frame()
            end
        else
            frame = hs.screen.mainScreen():frame()
        end
        local cellWidth = frame.w / gridSize
        local cellHeight = frame.h / gridSize
        
        -- Calculate which cell was clicked
        local col = math.floor((x - frame.x) / cellWidth)
        local row = math.floor((y - frame.y) / cellHeight)

        -- Check bounds
        if col < 0 or col >= gridSize or row < 0 or row >= gridSize then
            log.d("Click outside grid bounds - ignoring")
            return
        end
        local cellNum = row * gridSize + col + 1
        
        log.d("Clicked on first level cell " .. cellNum .. " at row " .. row .. ", col " .. col)
        DragonGrid.handleNumberKey(cellNum)
    end
end

function DragonGrid.handleNumberKey(num)
    if num < 1 or num > (gridSize * gridSize) then
        log.w("Invalid grid number: " .. tostring(num))
        return
    end

    log.d("Grid number selected: " .. num .. ", currentLevel: " .. currentLevel)
    local row = math.floor((num - 1) / gridSize)
    local col = (num - 1) % gridSize

    -- Get the correct frame based on current context
    local frame
    if currentLevel == 1 then
        -- For level 1, we use the whole screen or window
        if windowMode then
            local win = hs.window.focusedWindow()
            if not win then
                log.w("No focused window found, using full screen")
                frame = hs.screen.mainScreen():frame()
            else
                frame = win:frame()
            end
        else
            frame = hs.screen.mainScreen():frame()
        end
    else
        -- For higher levels, we use the previous selection's dimensions
        local prevSelection = selectionHistory[currentLevel - 1]
        frame = {
            x = prevSelection.x,
            y = prevSelection.y,
            w = prevSelection.w,
            h = prevSelection.h
        }
    end

    log.d("Current frame: x=" .. frame.x .. ", y=" .. frame.y .. ", w=" .. frame.w .. ", h=" .. frame.h)

    -- Calculate the cell dimensions for this level
    local cellWidth = frame.w / gridSize
    local cellHeight = frame.h / gridSize
    -- Calculate absolute position of the selected cell
    local cellX = frame.x + col * cellWidth
    local cellY = frame.y + row * cellHeight

    log.d("Selected cell: row=" .. row .. ", col=" .. col)
    log.d("Cell position: x=" .. cellX .. ", y=" .. cellY .. ", w=" .. cellWidth .. ", h=" .. cellHeight)
    if currentLevel < maxLayers then
        -- Store this selection in history
        local selection = {
            row = row,
            col = col,
            x = cellX,
            y = cellY,
            w = cellWidth,
            h = cellHeight
        }

        selectionHistory[currentLevel] = selection
        log.d("Storing selection at level " .. currentLevel)

        -- Move to next level
        currentLevel = currentLevel + 1
        DragonGrid.createNextLevelGrid()
    else
        -- Final level selection (perform action)
        local finalX = cellX + (cellWidth / 2)
        local finalY = cellY + (cellHeight / 2)

        log.d("Final position: x=" .. finalX .. ", y=" .. finalY)

        if dragMode and dragStart == nil then
            -- We're in drag mode and this is the first point
            dragStart = { x = finalX, y = finalY }
            hs.mouse.absolutePosition(dragStart)
            -- Show a message to indicate we're in drag mode
            hs.alert.show("Drag start point set. Select destination.")
        elseif dragMode and dragStart ~= nil then
            -- We're in drag mode and this is the second point
            hs.mouse.absolutePosition(dragStart)
            hs.eventtap.leftMouseDown()
            hs.timer.doAfter(0.1, function()
                hs.mouse.absolutePosition({ x = finalX, y = finalY })
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.leftMouseUp()
                    dragMode = false
                    dragStart = nil
                    DragonGrid.destroyDragonGrid()
                end)
            end)
        else
            -- Just move the mouse cursor to the selected position
            hs.mouse.absolutePosition({ x = finalX, y = finalY })
            -- Destroy the grid
            DragonGrid.destroyDragonGrid()
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

    -- Get the screen frame for absolute positioning
    local screenFrame = hs.screen.mainScreen():frame()

    -- Get the currently selected region from history
    local currentSelection = selectionHistory[currentLevel - 1]

    log.d("Creating level " .. currentLevel .. " grid at x=" ..
        currentSelection.x .. ", y=" .. currentSelection.y ..
        ", w=" .. currentSelection.w .. ", h=" .. currentSelection.h)

    -- Create a new canvas covering the entire screen
    dragonGridCanvas = hs.canvas.new(screenFrame)
    dragonGridCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    dragonGridCanvas:level(hs.canvas.windowLevels.overlay)
    
    -- Add semi-transparent overlay for areas outside the selected cell
    -- Top area (everything above selection)
    if currentSelection.y > screenFrame.y then
        dragonGridCanvas:appendElements({
            type = "rectangle",
            action = "fill",
            fillColor = config.colors.outsideArea,
            frame = {
                x = screenFrame.x,
                y = screenFrame.y,
                w = screenFrame.w,
                h = currentSelection.y - screenFrame.y
            }
        })
    end
    
    -- Bottom area (everything below selection)
    local bottomY = currentSelection.y + currentSelection.h
    if bottomY < (screenFrame.y + screenFrame.h) then
        dragonGridCanvas:appendElements({
            type = "rectangle",
            action = "fill",
            fillColor = config.colors.outsideArea,
            frame = {
                x = screenFrame.x,
                y = bottomY,
                w = screenFrame.w,
                h = (screenFrame.y + screenFrame.h) - bottomY
            }
        })
    end
    
    -- Left area (to the left of selection at its height)
    if currentSelection.x > screenFrame.x then
        dragonGridCanvas:appendElements({
            type = "rectangle",
            action = "fill",
            fillColor = config.colors.outsideArea,
            frame = {
                x = screenFrame.x,
                y = currentSelection.y,
                w = currentSelection.x - screenFrame.x,
                h = currentSelection.h
            }
        })
    end
    
    -- Right area (to the right of selection at its height)
    local rightX = currentSelection.x + currentSelection.w
    if rightX < (screenFrame.x + screenFrame.w) then
        dragonGridCanvas:appendElements({
            type = "rectangle",
            action = "fill",
            fillColor = config.colors.outsideArea,
            frame = {
                x = rightX,
                y = currentSelection.y,
                w = (screenFrame.x + screenFrame.w) - rightX,
                h = currentSelection.h
            }
        })
    end
    
    -- Calculate cell dimensions for this level
    local cellWidth = currentSelection.w / gridSize
    local cellHeight = currentSelection.h / gridSize

    -- Add highlight for the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { red = 0.2, green = 0.5, blue = 0.8, alpha = 0.6 },
        frame = {
            x = currentSelection.x,
            y = currentSelection.y,
            w = currentSelection.w,
            h = currentSelection.h
        }
    })
    
    -- Add a distinctive border for the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { red = 1, green = 1, blue = 0.2, alpha = 0.9 },
        strokeWidth = 4,
        frame = {
            x = currentSelection.x,
            y = currentSelection.y,
            w = currentSelection.w,
            h = currentSelection.h
        }
    })
    
    -- Add a level indicator text
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 40, w = 300, h = 30 },
        text = "LEVEL " .. currentLevel .. " OF " .. maxLayers .. " - Make selection",
        textSize = 16,
        textColor = { red = 1, green = 0.8, blue = 0.2, alpha = 1.0 },
        textAlignment = "left"
    })

    -- Add status indicators
    local modeText = windowMode and "WINDOW MODE" or "SCREEN MODE"
    local stateText = dragMode and "DRAG MODE - Select Target" or "PRECISION MODE"

    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 10, w = 300, h = 30 },
        text = modeText .. " | " .. stateText .. " | POS=" ..
            math.floor(currentSelection.x) .. "," .. math.floor(currentSelection.y),
        textSize = 16,
        textColor = dragMode and { red = 1, green = 0.6, blue = 0.2, alpha = 0.9 }
            or { white = 1, alpha = 0.8 },
        textAlignment = "left"
    })
    -- Draw grid cells inside the current selection
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = currentSelection.x + col * cellWidth
            local y = currentSelection.y + row * cellHeight
            
            log.d("Level " .. currentLevel .. " cell " .. cellNum ..
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
        frame = { x = 10, y = screenFrame.h - 30, w = screenFrame.w - 20, h = 20 },
        text = "Keys: ⌘1-9=Select | ⌘Space=Click | ⌘Esc=Cancel | ⌘U=Back | ⌘D=Complete Drag",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- If in drag mode and we have a start point, show it
    if dragMode and dragStart then
        dragonGridCanvas:appendElements({
            type = "circle",
            action = "fill",
            fillColor = { red = 1, green = 0.4, blue = 0.1, alpha = 0.7 },
            frame = { x = dragStart.x - 10, y = dragStart.y - 10, w = 20, h = 20 }
        })
    end
    
    -- Show the grid
    dragonGridCanvas:show()

    -- Set up click handler for the grid
    dragonGridCanvas:mouseCallback(function(canvas, event, id, x, y)
        if event == "mouseUp" then
            DragonGrid.handleGridClick(x, y)
        end
    end)

    -- Set up keyboard hotkeys with modifier keys
    -- Define our modifiers
    local mods = { "cmd" }

    -- Number keys for grid selection
    for i = 1, 9 do
        local hotkey = hs.hotkey.bind(mods, tostring(i), function()
            DragonGrid.handleNumberKey(i)
        end)
        table.insert(gridHotkeys, hotkey)
    end

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

-- Bind to hotkey directly (you can change this as needed)
function DragonGrid.bindHotkeys(mapping)
    local spec = {
        toggle = DragonGrid.toggleDragonGrid,
        window = function()
            windowMode = true; DragonGrid.createDragonGrid()
        end,
        screen = function()
            windowMode = false; DragonGrid.createDragonGrid()
        end
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
return DragonGrid
