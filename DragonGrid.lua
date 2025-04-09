local log = hs.logger.new('DragonGrid', 'debug')
log.i('Initializing DragonGrid module')

local DragonGrid = {}

local dragonGridCanvas = nil
local isSecondLevel = false
local firstLevelSelection = nil
local gridSize = 3
local modalKey = nil -- Will hold the modal key instance
local dragMode = false
local dragStart = nil
local windowMode = false -- Full screen or window-only mode

-- Initialize with default configuration
local config = {
    gridSize = 3,
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

    isSecondLevel = false
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
        frame = { x = 10, y = 10, w = 200, h = 30 },
        text = modeText,
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
    -- Add help text at the bottom
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = frame.h - 30, w = frame.w - 20, h = 20 },
        text = "Keys: 1-9=Select | Space=Click | Esc=Cancel | U=Undo | W=Toggle Mode | Shift+M=Mark for Drag",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- Show the grid
    dragonGridCanvas:show()

    -- Set up click handler for the entire canvas
    dragonGridCanvas:clickCallback(function(canvas, event, id, x, y)
        if event == "mouseUp" then
            DragonGrid.handleGridClick(x, y, frame)
        end
    end)
    -- Setup keyboard modal
    DragonGrid.setupKeyHandler()
end

function DragonGrid.handleGridClick(x, y, frame)
    local cellWidth = frame.w / gridSize
    local cellHeight = frame.h / gridSize

    -- Calculate which cell was clicked
    local col = math.floor(x / cellWidth)
    local row = math.floor(y / cellHeight)
    local cellNum = row * gridSize + col + 1

    DragonGrid.handleNumberKey(cellNum)
end

function DragonGrid.handleNumberKey(num)
    if num < 1 or num > (gridSize * gridSize) then
        log.w("Invalid grid number: " .. tostring(num))
        return
    end

    local row = math.floor((num - 1) / gridSize)
    local col = (num - 1) % gridSize

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
    if not isSecondLevel then
        -- First level selection
        firstLevelSelection = {
            row = row,
            col = col,
            x = frame.x + col * cellWidth,
            y = frame.y + row * cellHeight,
            w = cellWidth,
            h = cellHeight
        }
        DragonGrid.createSecondLevelGrid(firstLevelSelection)
    else
        -- Second level selection (final)
        local firstX = firstLevelSelection.x
        local firstY = firstLevelSelection.y
        local firstW = firstLevelSelection.w
        local firstH = firstLevelSelection.h

        -- Calculate precise position within the cell
        local secondCellWidth = firstW / gridSize
        local secondCellHeight = firstH / gridSize

        -- Calculate the exact position to move the mouse to
        local finalX = firstX + col * secondCellWidth + secondCellWidth / 2
        local finalY = firstY + row * secondCellHeight + secondCellHeight / 2

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

function DragonGrid.createSecondLevelGrid(cell)
    -- Switch to second level mode
    isSecondLevel = true

    -- Clear the canvas
    dragonGridCanvas:deleteSections()

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
    -- Add semi-transparent overlay for areas outside the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.outsideArea,
        frame = { x = 0, y = 0, w = cell.x, h = cell.y + cell.h }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.outsideArea,
        frame = { x = cell.x + cell.w, y = 0, w = frame.w - (cell.x + cell.w), h = cell.y + cell.h }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.outsideArea,
        frame = { x = 0, y = cell.y + cell.h, w = frame.w, h = frame.h - (cell.y + cell.h) }
    })
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.outsideArea,
        frame = { x = 0, y = 0, w = frame.w, h = cell.y }
    })

    -- Create a second level grid inside the selected cell
    local secondCellWidth = cell.w / gridSize
    local secondCellHeight = cell.h / gridSize

    -- Add highlight for the selected cell
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = config.colors.selectedCell,
        frame = { x = cell.x, y = cell.y, w = cell.w, h = cell.h }
    })
    
    -- Add status indicators
    local modeText = windowMode and "WINDOW MODE" or "SCREEN MODE"
    local stateText = dragMode and "DRAG MODE - Select Target" or "PRECISION MODE"

    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 10, w = 200, h = 30 },
        text = modeText .. " | " .. stateText,
        textSize = 16,
        textColor = dragMode and { red = 1, green = 0.6, blue = 0.2, alpha = 0.9 } or { white = 1, alpha = 0.8 },
        textAlignment = "left"
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
                strokeColor = config.colors.cellBorder,
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
                textColor = config.colors.cellText,
                textAlignment = "center"
            })
        end
    end
    -- Add help text at the bottom
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = frame.h - 30, w = frame.w - 20, h = 20 },
        text = "Keys: 1-9=Final Select | Space=Click | Esc=Cancel | U=Back | D=Complete Drag",
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
end

function DragonGrid.destroyDragonGrid()
    if modalKey then
        modalKey:exit()
    end
    if dragonGridCanvas then
        dragonGridCanvas:delete()
        dragonGridCanvas = nil
    end
    
    isSecondLevel = false
    firstLevelSelection = nil
    dragMode = false
    dragStart = nil
end

function DragonGrid.setupKeyHandler()
    if modalKey then
        modalKey:exit()
    end

    modalKey = hs.hotkey.modal.new()

    -- Number keys for grid selection
    for i = 1, 9 do
        modalKey:bind({}, tostring(i), function()
            DragonGrid.handleNumberKey(i)
        end)
    end

    -- Action keys
    modalKey:bind({}, 'escape', function()
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({}, 'return', function()
        -- "Go" command - just close the grid
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({}, 'u', function()
        -- Undo the last action
        if isSecondLevel then
            isSecondLevel = false
            DragonGrid.createDragonGrid()
        else
            -- If we're already at the first level, just cancel
            DragonGrid.destroyDragonGrid()
        end
    end)

    -- Mouse actions
    modalKey:bind({}, 'space', function()
        -- Left click
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.leftClick(pos)
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({ 'alt' }, 'space', function()
        -- Right click
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.rightClick(pos)
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({ 'shift' }, 'space', function()
        -- Middle click
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.middleClick(pos)
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({ 'ctrl' }, 'space', function()
        -- Double click
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.doubleClick(pos)
        DragonGrid.destroyDragonGrid()
    end)

    modalKey:bind({ 'shift' }, 'm', function()
        -- Mark for drag
        dragMode = true
        dragStart = nil
        hs.alert.show("Drag mode activated")
    end)

    modalKey:bind({}, 'd', function()
        -- Drag operation
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
            hs.alert.show("Set mark position first with Shift+M")
        end
    end)

    -- Window or screen mode toggle
    modalKey:bind({}, 'w', function()
        windowMode = not windowMode
        if windowMode then
            hs.alert.show("Window mode")
        else
            hs.alert.show("Screen mode")
        end

        if isSecondLevel then
            isSecondLevel = false
        end

        DragonGrid.createDragonGrid()
    end)

    modalKey:enter()
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

    return self
end
return DragonGrid
