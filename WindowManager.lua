local log = hs.logger.new('WindowManager', 'debug')
log.i('Initializing window management system')

local window = require "hs.window"
local spaces = require "hs.spaces"

local WindowManager = {
    -- State variables
    gap = 5,
    cols = 4,
    counter = 0,
    layoutCounter = 0,
    rowCounter = 0,
    colCounter = 0,
    moveStep = 150,
    lastWindowPosition = {},
    lastWindowPositions = {},

    -- Current state tracking
    currentWindow = nil,
    currentScreen = nil,
    currentFrame = nil,

    -- Layout state
    row = 0,
    sectionWidth = 0,
    sectionHeight = 0
}

-- Layouts
local miniLayouts = {
    { -- Layout 1
        x = function(max) return max.x + (max.w * 0.72) end,
        y = function(max) return max.y + (max.h * 0.01) + 25 end,
        w = function(max) return max.w * 0.26 end,
        h = function(max) return max.h * 0.97 end
    },
    { -- Layout 2
        x = function(max) return max.x + (max.w * 0.76) end,
        y = function(max) return max.y + (max.h * 0.01) - 25 end,
        w = function(max) return max.w * 0.24 end,
        h = function(max) return max.h * 0.97 end
    },
    { -- Layout 3
        x = function(max) return max.x + (max.w * 0.7) end,
        y = function(max) return max.y + (max.h * 0.01) - 30 end,
        w = function(max) return max.w * 0.5 end,
        h = function(max) return max.h * 0.9 end
    },
    { -- Layout 4
        x = function(max) return max.x + (max.w * 0.5) end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.5 end,
        h = function(max) return max.h * 0.9 end
    }
}

local standardLayouts = {
    fullScreen = { -- Full screen
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w end,
        h = function(max) return max.h end
    },
    nearlyFull = { -- 80% centered
        x = function(max) return max.x + (max.w * 0.1) end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.8 end,
        h = function(max) return max.h * 0.8 end
    },
    leftHalf = { -- Left half
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h end
    },
    rightHalf = { -- Right half
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h end
    },
    leftSmall = { -- Small left side
        x = function(max) return max.x end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.4 end,
        h = function(max) return max.h * 0.8 end
    },
    rightSmall = { -- Small right side
        x = function(max) return max.x + (max.w * 0.6) end,
        y = function(max) return max.y + (max.h * 0.1) end,
        w = function(max) return max.w * 0.4 end,
        h = function(max) return max.h * 0.8 end
    },
    topLeft = { -- Top left corner
        x = function(max) return max.x end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    topRight = { -- Top right corner
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    bottomLeft = { -- Bottom left corner
        x = function(max) return max.x end,
        y = function(max) return max.y + (max.h / 2) end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    bottomRight = { -- Bottom right corner
        x = function(max) return max.x + (max.w / 2) end,
        y = function(max) return max.y + (max.h / 2) end,
        w = function(max) return max.w / 2 end,
        h = function(max) return max.h / 2 end
    },
    leftWide = { -- 72% left side
        x = function(max) return max.x + 30 end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.72 - 30 end,
        h = function(max) return max.h * 0.98 end
    },
    rightNarrow = { -- 27% right side
        x = function(max) return max.x + (max.w * 0.73) end,
        y = function(max) return max.y + (max.h * 0.01) end,
        w = function(max) return max.w * 0.27 end,
        h = function(max) return max.h * 0.98 end
    }
}

local function calculatePosition(counter, max, rows)
    WindowManager.row = math.floor(counter / WindowManager.cols)
    local col = counter % WindowManager.cols
    local x = max.x + (col * (max.w / WindowManager.cols + WindowManager.gap))
    local y = max.y + (WindowManager.row * (max.h / rows + WindowManager.gap))
    return x, y
end

-- Window Management Functions
function WindowManager.miniShuffle()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local max = screen:frame()

    -- Get current layout based on counter
    local layout = miniLayouts[(WindowManager.counter % #miniLayouts) + 1]

    -- Create new frame using layout functions
    local newFrame = {
        x = layout.x(max),
        y = layout.y(max),
        w = layout.w(max),
        h = layout.h(max)
    }

    -- Apply the frame
    win:setFrame(newFrame)
    -- WindowManager.currentFrame = newFrame

    -- Increment counter
    WindowManager.counter = (WindowManager.counter + 1) % #miniLayouts
end

function WindowManager.halfShuffle(numRows, numCols)

    numRows = numRows or 3
    numCols = numCols or 2

    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local sectionWidth = max.w / numCols
    local sectionHeight = max.h / numRows

    local colCounter = WindowManager.colCounter
    local rowCounter = WindowManager.rowCounter

    -- log.d('Current counters:', { row = WindowManager.rowCounter, col = WindowManager.colCounter })
    local x = max.x + (colCounter * sectionWidth)
    local y = max.y + (rowCounter * sectionHeight)

    f.x = x
    f.y = y
    f.w = sectionWidth
    f.h = sectionHeight
    log.i('Half shuffle w/ position: ', rowCounter, colCounter)

    win:setFrame(f)
    -- WindowManager.currentFrame = f
    -- log.d('Set frame:', { x = f.x, y = f.y, w = f.w, h = f.h })

    -- Update counters
    WindowManager.rowCounter = (WindowManager.rowCounter + 1) % numRows
    if WindowManager.rowCounter == 0 then
        WindowManager.colCounter = (WindowManager.colCounter + 1) % numCols
    end
    -- log.d('Updated counters:', { row = WindowManager.rowCounter, col = WindowManager.colCounter })
end

function WindowManager.applyLayout(layoutName)
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

    -- Calculate new frame
    local newFrame = {
        x = layout.x(max),
        y = layout.y(max),
        w = layout.w(max),
        h = layout.h(max)
    }

    -- First move the window without changing size (maintaining current w/h)
    local moveFrame = {
        x = newFrame.x,
        y = newFrame.y,
        w = f.w,
        h = f.h
    }
    win:setFrame(moveFrame, 0.1)

    -- Small delay to let the move complete without blocking
    hs.timer.usleep(100000)

    -- Then resize the window at the new position
    win:setFrame(newFrame, 1)

    log.i('Applied layout:', layoutName)
end

-- found this to be alot slower and buggy. Better to directly apply the layout
-- function WindowManager.moveSide(side, isSmall)
--     if side == "left" then
--         if isSmall then
--             WindowManager.applyLayout('leftSmall')
--         else
--             WindowManager.applyLayout('leftHalf')
--         end
--     else
--         if isSmall then
--             WindowManager.applyLayout('rightSmall')
--         else
--             WindowManager.applyLayout('rightHalf')
--         end
--     end
-- end

function WindowManager.moveToScreen(direction, position)
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

function WindowManager.moveWindow(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()

    local movements = {
        left = { x = -WindowManager.moveStep, y = 0 },
        right = { x = WindowManager.moveStep, y = 0 },
        up = { x = 0, y = -WindowManager.moveStep },
        down = { x = 0, y = WindowManager.moveStep }
    }

    local move = movements[direction]
    f.x = f.x + move.x
    f.y = f.y + move.y

    win:setFrame(f)
    -- WindowManager.currentFrame = f
end

function WindowManager.moveWindowMouseCenter()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    win:setFrame(f)
    -- WindowManager.currentFrame = f
end

function WindowManager.moveWindowMouseCorner()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
    --  WindowManager.currentFrame = f
end

-- Window Position Save/Restore
function WindowManager.saveWindowPosition()
    log.i('Saving window position')
    local win = hs.window.focusedWindow()
    if win then
        WindowManager.lastWindowPosition[win:id()] = win:frame()
        log.d('Saved position for window:', win:id(), hs.inspect(win:frame()))
        hs.alert.show("Window position saved")
    else
        log.w('No focused window to save position')
    end
end

function WindowManager.restoreWindowPosition()
    log.i('Restoring window position')
    local win = hs.window.focusedWindow()
    if win and WindowManager.lastWindowPosition[win:id()] then
        log.d('Restoring position for window:', win:id(), hs.inspect(WindowManager.lastWindowPosition[win:id()]))
        win:setFrame(WindowManager.lastWindowPosition[win:id()])
        hs.alert.show("Window position restored")
    else
        log.w('No saved position found for window:', win and win:id() or 'no window focused')
    end
end

function WindowManager.saveAllWindowPositions()
    local wins = hs.window.allWindows()
    for _, win in ipairs(wins) do
        WindowManager.lastWindowPositions[win:id()] = win:frame()
    end
    hs.alert.show("All window positions saved")
end

function WindowManager.restoreAllWindowPositions()
    local wins = hs.window.allWindows()
    for _, win in ipairs(wins) do
        local savedPosition = WindowManager.lastWindowPositions[win:id()]
        if savedPosition then
            win:setFrame(savedPosition)
        end
    end
    hs.alert.show("All window positions restored")
end

function WindowManager.resetShuffleCounters()
    log.i('Resetting shuffle counters')
    WindowManager.rowCounter = 0
    WindowManager.colCounter = 0
    WindowManager.counter = 0
    WindowManager.layoutCounter = 0
    WindowManager.row = 0
    WindowManager.currentWindow = nil
    WindowManager.currentScreen = nil
    WindowManager.currentFrame = nil
    WindowManager.sectionWidth = 0
    WindowManager.sectionHeight = 0
end
return WindowManager
