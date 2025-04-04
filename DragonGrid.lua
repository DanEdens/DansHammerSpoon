local log = hs.logger.new('DragonGrid', 'debug')
log.i('Initializing DragonGrid module')

local DragonGrid = {}

local dragonGridCanvas = nil
local isSecondLevel = false
local firstLevelSelection = nil
local gridSize = 3

function DragonGrid.createDragonGrid()
    -- Clean up any existing grid
    if dragonGridCanvas then
        DragonGrid.destroyDragonGrid()
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
            DragonGrid.handleGridClick(x, y, screenFrame)
        end
    end)
end

function DragonGrid.handleGridClick(x, y, screenFrame)
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

        local secondCol = math.floor((x - firstX) / secondCellWidth)
        local secondRow = math.floor((y - firstY) / secondCellHeight)

        -- Calculate the exact position to move the mouse to
        local finalX = firstX + secondCol * secondCellWidth + secondCellWidth / 2
        local finalY = firstY + secondRow * secondCellHeight + secondCellHeight / 2

        -- Move the mouse cursor to the selected position
        hs.mouse.absolutePosition({ x = finalX, y = finalY })

        -- Destroy the grid
        DragonGrid.destroyDragonGrid()
    end
end

function DragonGrid.createSecondLevelGrid(cell)
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

function DragonGrid.destroyDragonGrid()
    if dragonGridCanvas then
        dragonGridCanvas:delete()
        dragonGridCanvas = nil
    end
    isSecondLevel = false
    firstLevelSelection = nil
end

function DragonGrid.toggleDragonGrid()
    if dragonGridCanvas then
        DragonGrid.destroyDragonGrid()
    else
        DragonGrid.createDragonGrid()
    end
end

return DragonGrid
