--- === DragonGrid ===
---
--- Precision mouse movement and control using a multi-level grid system
--- Allows for precise mouse positioning, clicking, and dragging with keyboard or mouse
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "DragonGrid"
obj.version = "1.0"
obj.author = "D. Edens"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- DragonGrid.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the
-- messages coming from the Spoon.
obj.logger = hs.logger.new('DragonGrid')
obj.logger.setLogLevel('info')

-- Private variables
local dragonGridCanvas = nil
local currentLevel = 0
local maxLayers = 4         -- Default number of layers
local selectionHistory = {} -- Will store all selections at each level
local gridSize = 3
local modalKey = nil        -- Will hold the modal key instance
local dragMode = false
local dragStart = nil
local windowMode = false -- Full screen or window-only mode
local gridHotkeys = {}   -- Table to hold hotkey bindings
local menubar = nil      -- Menubar object for settings

-- Initialize with default configuration
obj.config = {
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

function obj:createDragonGrid()
    -- Clean up any existing grid
    if dragonGridCanvas then
        self:destroyDragonGrid()
    end

    currentLevel = 1
    selectionHistory = {}
    dragMode = false
    dragStart = nil

    -- Get the screen where the mouse cursor is currently located
    local mousePos = hs.mouse.absolutePosition()
    local currentScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()

    self.logger.d("Mouse position: x=" .. mousePos.x .. ", y=" .. mousePos.y)
    self.logger.d("Using screen: " .. (currentScreen:name() or "unnamed"))
    local frame
    if windowMode then
        local win = hs.window.focusedWindow()
        if not win then
            self.logger.w("No focused window found, using current screen")
            frame = currentScreen:frame()
        else
            frame = win:frame()
        end
    else
        frame = currentScreen:frame()
    end

    self.logger.d("Creating level 1 grid at x=" .. frame.x .. ", y=" .. frame.y ..
        ", w=" .. frame.w .. ", h=" .. frame.h)
    dragonGridCanvas = hs.canvas.new(frame)
    dragonGridCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    dragonGridCanvas:level(hs.canvas.windowLevels.overlay)

    -- Add semi-transparent background
    dragonGridCanvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = self.config.colors.background,
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
                strokeColor = self.config.colors.cellBorder,
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
                textColor = self.config.colors.cellText,
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
            self:handleGridClick(x, y)
        end
    end)

    -- Clean up any existing hotkeys
    self:unbindHotkeys()

    -- Use our helper function to bind grid selection hotkeys
    self:bindGridHotkeys()

    -- Define our modifiers for action keys
    local mods = { "cmd" }

    -- Action keys
    local escapeKey = hs.hotkey.bind(mods, "escape", function()
        self:destroyDragonGrid()
    end)
    table.insert(gridHotkeys, escapeKey)

    local returnKey = hs.hotkey.bind(mods, "return", function()
        self:destroyDragonGrid()
    end)
    table.insert(gridHotkeys, returnKey)

    local undoKey = hs.hotkey.bind(mods, "u", function()
        if currentLevel > 1 then
            currentLevel = currentLevel - 1
            selectionHistory[currentLevel] = nil
            -- If we go back to level 1, recreate the initial grid
            if currentLevel == 1 then
                self:createDragonGrid()
            else
                self:createNextLevelGrid()
            end
        else
            self:destroyDragonGrid()
        end
    end)
    table.insert(gridHotkeys, undoKey)

    -- Mouse actions
    local spaceKey = hs.hotkey.bind(mods, "space", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.leftClick(pos)
        self:destroyDragonGrid()
    end)
    table.insert(gridHotkeys, spaceKey)

    local rightClickKey = hs.hotkey.bind(mods, "r", function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.rightClick(pos)
        self:destroyDragonGrid()
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

        self:createDragonGrid()
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
                    self:destroyDragonGrid()
                end)
            end)
        else
            hs.alert.show("Set mark position first with ⌘M")
        end
    end)
    table.insert(gridHotkeys, dragKey)
end

function obj:handleGridClick(x, y)
    self.logger.d("Grid click at x:" .. x .. ", y:" .. y)

    if currentLevel > 1 then
        -- We're in a higher level grid
        local currentSelection = selectionHistory[currentLevel - 1]

        -- Check if the click is within the current selection
        if x < currentSelection.x or x > (currentSelection.x + currentSelection.w) or
            y < currentSelection.y or y > (currentSelection.y + currentSelection.h) then
            -- Click is outside the current selection area
            self.logger.d("Click outside current grid area - ignoring")
            return
        end

        -- Calculate which cell was clicked within the current selection
        local cellWidth = currentSelection.w / gridSize
        local cellHeight = currentSelection.h / gridSize

        local col = math.floor((x - currentSelection.x) / cellWidth)
        local row = math.floor((y - currentSelection.y) / cellHeight)
        local cellNum = row * gridSize + col + 1

        self.logger.d("Clicked on level " .. currentLevel .. " cell " .. cellNum ..
            " at row " .. row .. ", col " .. col)
        self:handleNumberKey(cellNum)
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
                self.logger.d("Click on screen: " .. (clickScreen:name() or "unnamed"))
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
            self.logger.d("Click on screen: " .. (clickScreen:name() or "unnamed"))
        end

        -- Calculate which cell was clicked
        local relX = x - frame.x
        local relY = y - frame.y
        local cellWidth = frame.w / gridSize
        local cellHeight = frame.h / gridSize

        local col = math.floor(relX / cellWidth)
        local row = math.floor(relY / cellHeight)
        -- Ensure we're within the grid bounds
        if col < 0 or col >= gridSize or row < 0 or row >= gridSize then
            self.logger.d("Click outside grid bounds - ignoring")
            return
        end
        local cellNum = row * gridSize + col + 1

        self.logger.d("Clicked on level 1 cell " .. cellNum .. " at row " .. row .. ", col " .. col)
        self:handleNumberKey(cellNum)
    end
end

function obj:handleNumberKey(number)
    self.logger.d("Handling number key: " .. number)
    if number < 1 or number > (gridSize * gridSize) then
        self.logger.w("Invalid cell number: " .. number)
        return
    end

    if dragMode and not dragStart then
        -- In drag mode, first mark position
        dragStart = hs.mouse.absolutePosition()
        self.logger.d("Setting drag start to " .. dragStart.x .. "," .. dragStart.y)
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

        self.logger.d("Selected level 1 cell at " .. x .. "," .. y)

        -- If at max layers, perform a click and exit
        if currentLevel >= maxLayers then
            hs.mouse.absolutePosition({ x = x, y = y })
            self.logger.d("Reached max layers (" .. maxLayers .. "), positioning mouse and exiting")

            if dragMode and dragStart then
                -- In drag mode with start position, complete the drag
                hs.eventtap.leftMouseDown(dragStart)
                hs.timer.doAfter(0.1, function()
                    hs.mouse.absolutePosition({ x = x, y = y })
                    hs.timer.doAfter(0.1, function()
                        hs.eventtap.leftMouseUp()
                        self.logger.d("Drag completed from " ..
                        dragStart.x .. "," .. dragStart.y .. " to " .. x .. "," .. y)
                        dragMode = false
                        dragStart = nil
                        self:destroyDragonGrid()
                    end)
                end)
            else
                self:destroyDragonGrid()
            end
        else
            -- Move to the next level
            currentLevel = currentLevel + 1
            hs.mouse.absolutePosition({ x = x, y = y })
            self:createNextLevelGrid()
        end
    else
        -- Higher level grid
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

        self.logger.d("Selected level " .. currentLevel .. " cell at " .. x .. "," .. y)

        -- If at max layers, perform a click and exit
        if currentLevel >= maxLayers then
            hs.mouse.absolutePosition({ x = x, y = y })
            self.logger.d("Reached max layers (" .. maxLayers .. "), positioning mouse and exiting")

            if dragMode and dragStart then
                -- In drag mode with start position, complete the drag
                hs.eventtap.leftMouseDown(dragStart)
                hs.timer.doAfter(0.1, function()
                    hs.mouse.absolutePosition({ x = x, y = y })
                    hs.timer.doAfter(0.1, function()
                        hs.eventtap.leftMouseUp()
                        self.logger.d("Drag completed from " ..
                        dragStart.x .. "," .. dragStart.y .. " to " .. x .. "," .. y)
                        dragMode = false
                        dragStart = nil
                        self:destroyDragonGrid()
                    end)
                end)
            else
                self:destroyDragonGrid()
            end
        else
            -- Move to the next level
            currentLevel = currentLevel + 1
            hs.mouse.absolutePosition({ x = x, y = y })
            self:createNextLevelGrid()
        end
    end
end

function obj:createNextLevelGrid()
    -- Create a new grid based on the selected cell from the previous level
    self.logger.d("Creating level " .. currentLevel .. " grid")
    -- Delete the current canvas and create a new one
    if dragonGridCanvas then
        dragonGridCanvas:delete()
    end

    -- Get the current selection (which represents our grid area)
    local currentSelection = selectionHistory[currentLevel - 1]
    if not currentSelection then
        self.logger.e("No previous selection found for level " .. (currentLevel - 1))
        return
    end

    -- Find the screen containing the selection center point
    local selectionCenter = {
        x = currentSelection.x + currentSelection.w / 2,
        y = currentSelection.y + currentSelection.h / 2
    }

    local currentScreen = nil
    for _, screen in pairs(hs.screen.allScreens()) do
        local screenFrame = screen:frame()
        if selectionCenter.x >= screenFrame.x and selectionCenter.x <= screenFrame.x + screenFrame.w and
            selectionCenter.y >= screenFrame.y and selectionCenter.y <= screenFrame.y + screenFrame.h then
            currentScreen = screen
            break
        end
    end

    -- Fallback to the screen with the mouse if we couldn't determine the screen
    if not currentScreen then
        currentScreen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
    end

    self.logger.d("Using screen: " .. (currentScreen:name() or "unnamed") ..
        " for level " .. currentLevel .. " grid")

    -- Create a new canvas with the exact dimensions of the selection area
    -- This is the key change - use the selection bounds directly instead of
    -- creating a canvas for the whole screen and darkening the outside area
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
        fillColor = self.config.colors.background,
        frame = { x = 0, y = 0, w = currentSelection.w, h = currentSelection.h }
    })

    -- Add status indicator at the top
    local modeText = windowMode and "WINDOW MODE" or "SCREEN MODE"
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = 10, w = 300, h = 30 },
        text = modeText .. " | LEVEL " .. currentLevel .. " OF " .. maxLayers .. " | POS=" ..
            math.floor(currentSelection.x) .. "," .. math.floor(currentSelection.y),
        textSize = 16,
        textColor = { white = 1, alpha = 0.8 },
        textAlignment = "left"
    })

    -- Create the grid cells
    local cellWidth = currentSelection.w / gridSize
    local cellHeight = currentSelection.h / gridSize
    for row = 0, gridSize - 1 do
        for col = 0, gridSize - 1 do
            local cellNum = row * gridSize + col + 1
            local x = col * cellWidth
            local y = row * cellHeight
            -- Add cell border
            dragonGridCanvas:appendElements({
                type = "rectangle",
                action = "stroke",
                strokeColor = self.config.colors.cellBorder,
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
                textColor = self.config.colors.cellText,
                textAlignment = "center"
            })
        end
    end

    -- Add help text at the bottom
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = currentSelection.h - 30, w = currentSelection.w - 20, h = 20 },
        text = "Use keys: ⌘1-9 (cells 1-9) | ⌘⇧1-9 (cells 10-18) | ⌘⇧⌥1-9 (cells 19-27) | ⌘Space=Click | ⌘Esc=Cancel",
        textSize = 12,
        textColor = { white = 1, alpha = 0.7 },
        textAlignment = "center"
    })

    -- Add second line of help text
    dragonGridCanvas:appendElements({
        type = "text",
        action = "fill",
        frame = { x = 10, y = currentSelection.h - 50, w = currentSelection.w - 20, h = 20 },
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
            -- We need to convert the canvas-relative coordinates to absolute screen coordinates
            local absX = x + currentSelection.x
            local absY = y + currentSelection.y
            self:handleGridClick(absX, absY)
        end
    end)
    -- Bind grid hotkeys
    self:bindGridHotkeys()
end

function obj:bindGridHotkeys()
    -- Bind hotkeys for selecting grid cells (1-9, 10-18, 19-27)
    local cmdMod = { "cmd" }
    local cmdShiftMod = { "cmd", "shift" }
    local cmdShiftAltMod = { "cmd", "shift", "alt" }

    -- For cells 1-9 (cmd + number)
    for i = 1, 9 do
        local numKey = tostring(i)
        local hotkey = hs.hotkey.bind(cmdMod, numKey, function()
            self:handleNumberKey(i)
        end)
        table.insert(gridHotkeys, hotkey)
    end

    -- For cells 10-18 (cmd + shift + number)
    for i = 1, 9 do
        local numKey = tostring(i)
        local hotkey = hs.hotkey.bind(cmdShiftMod, numKey, function()
            self:handleNumberKey(i + 9)
        end)
        table.insert(gridHotkeys, hotkey)
    end

    -- For cells 19-27 (cmd + shift + alt + number)
    for i = 1, 9 do
        local numKey = tostring(i)
        local hotkey = hs.hotkey.bind(cmdShiftAltMod, numKey, function()
            self:handleNumberKey(i + 18)
        end)
        table.insert(gridHotkeys, hotkey)
    end
end

function obj:unbindHotkeys()
    -- Unbind all hotkeys
    for _, hotkey in ipairs(gridHotkeys) do
        hotkey:delete()
    end
    gridHotkeys = {}
end

function obj:destroyDragonGrid()
    self.logger.d("Destroying DragonGrid")

    -- Unbind all hotkeys
    self:unbindHotkeys()

    -- Remove the canvas
    if dragonGridCanvas then
        dragonGridCanvas:delete()
        dragonGridCanvas = nil
    end

    -- Reset variables
    currentLevel = 0
    selectionHistory = {}
    dragMode = false
    dragStart = nil
end

function obj:toggleGridDisplay()
    if dragonGridCanvas then
        self:destroyDragonGrid()
    else
        self:createDragonGrid()
    end
end

-- Show settings menu for DragonGrid
function obj:showSettingsMenu()
    -- Check if menubar has been lost and recreate it if needed
    if not menubar then
        self:start()
    end
    local gridSizeDesc = "Current grid size: " .. gridSize .. "x" .. gridSize
    local layersDesc = "Current max layers: " .. maxLayers

    -- Use a temporary menubar for the popup menu to avoid interfering with the permanent one
    -- return hs.menubar.new(false):setMenu(choices):popupMenu(hs.mouse.absolutePosition())
end

function obj:init()
    -- Initialize the spoon
    self.logger.i("Initializing DragonGrid Spoon")
    gridSize = self.config.gridSize or 3
    maxLayers = self.config.maxLayers or 2
    return self
end

function obj:start()
    -- Start the spoon
    self.logger.i("Starting DragonGrid Spoon")

    -- Create menubar item
    if menubar then
        menubar:delete()
    end

    menubar = hs.menubar.new()
    if menubar then
        -- Use a more reliable system icon
        local icon = hs.image.imageFromName("NSTouchBarGridTemplate") or
            hs.image.imageFromName("NSGridTemplate") or
            hs.image.imageFromName("NSActionTemplate")

        -- Ensure icon size is appropriate for menubar
        if icon then
            local iconSize = 18
            icon = icon:setSize({ w = iconSize, h = iconSize })
        end

        local choices = {
        { title = "-" },
        { title = "DragonGrid Settings", disabled = true },
        { title = "-" },
        { title = gridSizeDesc,          disabled = true },
        {
            title = "Set Grid Size: 2x2",
            fn = function()
                gridSize = 2
                self.config.gridSize = 2
                hs.alert.show("Grid size set to 2x2")
            end
        },
        {
            title = "Set Grid Size: 3x3",
            fn = function()
                gridSize = 3
                self.config.gridSize = 3
                hs.alert.show("Grid size set to 3x3")
            end
        },
        {
            title = "Set Grid Size: 4x4",
            fn = function()
                gridSize = 4
                self.config.gridSize = 4
                hs.alert.show("Grid size set to 4x4")
            end
        },
        {
            title = "Set Grid Size: 5x5",
            fn = function()
                gridSize = 5
                self.config.gridSize = 5
                hs.alert.show("Grid size set to 5x5")
            end
        },
        { title = "-" },
        { title = layersDesc, disabled = true },
        {
            title = "Set Layers to 1",
            fn = function()
                maxLayers = 1
                self.config.maxLayers = 1
                hs.alert.show("Max layers set to 1")
            end
        },
        {
            title = "Set Layers to 2",
            fn = function()
                maxLayers = 2
                self.config.maxLayers = 2
                hs.alert.show("Max layers set to 2")
            end
        },
        {
            title = "Set Layers to 3",
            fn = function()
                maxLayers = 3
                self.config.maxLayers = 3
                hs.alert.show("Max layers set to 3")
            end
        },
        {
            title = "Set Layers to 4",
            fn = function()
                maxLayers = 4
                self.config.maxLayers = 4
                hs.alert.show("Max layers set to 4")
            end
        },
        { title = "-" },
        { title = "Launch DragonGrid", fn = function() self:toggleGridDisplay() end }
    }
        
        menubar:setIcon(icon)

        -- Set the tooltip for clarity
        menubar:setTooltip("DragonGrid")
        menubar:setMenu(function()
            return {
                { title = "Show DragonGrid",         fn = function() self:toggleGridDisplay() end },
                {
                    title = "Toggle Window/Screen Mode",
                    fn = function()
                        windowMode = not windowMode
                        if windowMode then
                            hs.alert.show("Window mode")
                        else
                            hs.alert.show("Screen mode")
                        end
                    end
                },
                { title = "-" },
                { title = "Grid Size: " .. gridSize, disabled = true },
                { title = "Set Grid Size 2x2",       fn = function()
                    gridSize = 2; self.config.gridSize = 2
                end },
                { title = "Set Grid Size 3x3",       fn = function()
                    gridSize = 3; self.config.gridSize = 3
                end },
                { title = "Set Grid Size 4x4",       fn = function()
                    gridSize = 4; self.config.gridSize = 4
                end },
                { title = "Set Grid Size 5x5",       fn = function()
                    gridSize = 5; self.config.gridSize = 5
                end },
                { title = "-" },
                { title = "Layers: " .. maxLayers,   disabled = true },
                { title = "Set Layers to 1",         fn = function()
                    maxLayers = 1; self.config.maxLayers = 1
                end },
                { title = "Set Layers to 2",         fn = function()
                    maxLayers = 2; self.config.maxLayers = 2
                end },
                { title = "Set Layers to 3",         fn = function()
                    maxLayers = 3; self.config.maxLayers = 3
                end },
                { title = "Set Layers to 4",         fn = function()
                    maxLayers = 4; self.config.maxLayers = 4
                end },
                { title = "-" },
                { title = "Settings Menu", fn = function() hs.menubar.new(false):setMenu(choices):popupMenu(hs.mouse.absolutePosition()) end }
            }
        end)
    else
        self.logger.e("Failed to create menubar item")
    end

    return self
end

--- DragonGrid:bindHotKeys(mapping)
--- Method
--- Binds hotkeys for DragonGrid
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * show - Show the DragonGrid
---   * settings - Show the DragonGrid settings menu
---
--- Returns:
---  * The DragonGrid object
function obj:bindHotKeys(mapping)
    local spec = {
        show = function() self:toggleGridDisplay() end,
        settings = function() self:showSettingsMenu() end
    }

    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function obj:stop()
    -- Stop the spoon
    self.logger.i("Stopping DragonGrid Spoon")
    self:destroyDragonGrid()

    -- Remove menubar
    if menubar then
        menubar:delete()
        menubar = nil
    end

    return self
end

return obj
