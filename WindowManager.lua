-- WindowManager.lua - Window management utilities
-- Using singleton pattern to avoid multiple initializations
local __FILE__ = 'WindowManager.lua'
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()
-- Check if the module is already initialized
if _G.WindowManager then
    return _G.WindowManager
end
log:d('Initializing window management system', __FILE__, 22)

hs.window.animationDuration = 0.0
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
    sectionHeight = 0,

    -- Multi-window layout management
    savedLayouts = {},

    -- Toggle layout state tracking
    rightLayoutState = { isSmall = true },
    leftLayoutState = { isSmall = true },
    fullLayoutState = { currentState = 0 }, -- 0: fullScreen, 1: nearlyFull, 2: trueFull

    -- Monitor configuration tracking
    currentMonitorConfig = "unknown",
    detectedScreens = {},
    layoutSets = {}
}

-- Monitor Configuration Detection
function WindowManager.detectMonitorConfiguration()
    local screens = hs.screen.allScreens()
    local screenCount = #screens
    local config = {
        count = screenCount,
        primary = hs.screen.mainScreen():name(),
        screens = {}
    }

    -- Collect screen information
    for i, screen in ipairs(screens) do
        local frame = screen:frame()
        table.insert(config.screens, {
            name = screen:name(),
            uuid = screen:getUUID(),
            frame = frame,
            size = string.format("%dx%d", frame.w, frame.h),
            position = string.format("%.0f,%.0f", frame.x, frame.y)
        })
    end

    -- Determine configuration type
    local configType
    if screenCount == 1 then
        configType = "laptop"
    elseif screenCount == 2 then
        configType = "dual_monitor"
    elseif screenCount == 3 then
        configType = "triple_monitor"
    else
        configType = "multi_monitor"
    end

    config.type = configType
    WindowManager.currentMonitorConfig = configType
    WindowManager.detectedScreens = config.screens

    log:i('Detected monitor configuration:', configType, 'with', screenCount, 'screens')
    log:d('Screen configuration details:', hs.inspect(config))

    return config
end

-- Layout Sets for Different Monitor Configurations
local function initializeLayoutSets()
    WindowManager.layoutSets = {
        laptop = {
            miniLayouts = {
                { -- Layout 1 - More compact for laptop screen
                    x = function(max) return max.x + (max.w * 0.75) end,
                    y = function(max) return max.y + (max.h * 0.02) end,
                    w = function(max) return max.w * 0.24 end,
                    h = function(max) return max.h * 0.96 end
                },
                { -- Layout 2 - Small window mode
                    x = function(max) return max.x + (max.w * 0.6) end,
                    y = function(max) return max.y + (max.h * 0.1) end,
                    w = function(max) return max.w * 0.38 end,
                    h = function(max) return max.h * 0.8 end
                },
                { -- Layout 3 - Half screen
                    x = function(max) return max.x + (max.w * 0.5) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w * 0.5 end,
                    h = function(max) return max.h end
                }
            },
            standardLayouts = {
                fullScreen = {
                    x = function(max) return max.x + 20 end,
                    y = function(max) return max.y + 20 end,
                    w = function(max) return max.w - 40 end,
                    h = function(max) return max.h - 40 end
                },
                leftHalf = {
                    x = function(max) return max.x end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w / 2 end,
                    h = function(max) return max.h end
                },
                rightHalf = {
                    x = function(max) return max.x + (max.w / 2) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w / 2 end,
                    h = function(max) return max.h end
                },
                leftSmall = {
                    x = function(max) return max.x end,
                    y = function(max) return max.y + (max.h * 0.1) end,
                    w = function(max) return max.w * 0.4 end,
                    h = function(max) return max.h * 0.8 end
                },
                rightSmall = {
                    x = function(max) return max.x + (max.w * 0.6) end,
                    y = function(max) return max.y + (max.h * 0.1) end,
                    w = function(max) return max.w * 0.4 end,
                    h = function(max) return max.h * 0.8 end
                }
            }
        },

        dual_monitor = {
            miniLayouts = {
                { -- Layout 1 - Right side of primary
                    x = function(max) return max.x + (max.w * 0.72) end,
                    y = function(max) return max.y + (max.h * 0.01) + 25 end,
                    w = function(max) return max.w * 0.26 end,
                    h = function(max) return max.h * 0.97 end
                },
                { -- Layout 2 - Narrow right side
                    x = function(max) return max.x + (max.w * 0.76) end,
                    y = function(max) return max.y + (max.h * 0.01) - 25 end,
                    w = function(max) return max.w * 0.24 end,
                    h = function(max) return max.h * 0.97 end
                },
                { -- Layout 3 - Wide right side
                    x = function(max) return max.x + (max.w * 0.7) end,
                    y = function(max) return max.y + (max.h * 0.01) - 30 end,
                    w = function(max) return max.w * 0.5 end,
                    h = function(max) return max.h * 0.9 end
                },
                { -- Layout 4 - Half screen
                    x = function(max) return max.x + (max.w * 0.5) end,
                    y = function(max) return max.y + (max.h * 0.01) end,
                    w = function(max) return max.w * 0.5 end,
                    h = function(max) return max.h * 0.9 end
                }
            },
            standardLayouts = {
                fullScreen = {
                    x = function(max) return max.x + 35 end,
                    y = function(max) return max.y + 35 end,
                    w = function(max) return max.w - 70 end,
                    h = function(max) return max.h - 70 end
                },
                leftWide = {
                    x = function(max) return max.x + 30 end,
                    y = function(max) return max.y + (max.h * 0.01) end,
                    w = function(max) return max.w * 0.72 - 30 end,
                    h = function(max) return max.h * 0.98 end
                },
                rightNarrow = {
                    x = function(max) return max.x + (max.w * 0.73) end,
                    y = function(max) return max.y + (max.h * 0.01) end,
                    w = function(max) return max.w * 0.27 end,
                    h = function(max) return max.h * 0.98 end
                }
            }
        },

        triple_monitor = {
            miniLayouts = {
                { -- Layout 1 - Far right monitor small
                    x = function(max) return max.x + (max.w * 0.85) end,
                    y = function(max) return max.y + (max.h * 0.05) end,
                    w = function(max) return max.w * 0.14 end,
                    h = function(max) return max.h * 0.9 end
                },
                { -- Layout 2 - Center monitor right side
                    x = function(max) return max.x + (max.w * 0.75) end,
                    y = function(max) return max.y + (max.h * 0.02) end,
                    w = function(max) return max.w * 0.24 end,
                    h = function(max) return max.h * 0.96 end
                },
                { -- Layout 3 - Full right monitor
                    x = function(max) return max.x + (max.w * 0.67) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w * 0.33 end,
                    h = function(max) return max.h end
                }
            },
            standardLayouts = {
                fullScreen = {
                    x = function(max) return max.x + 50 end,
                    y = function(max) return max.y + 50 end,
                    w = function(max) return max.w - 100 end,
                    h = function(max) return max.h - 100 end
                },
                leftThird = {
                    x = function(max) return max.x end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w / 3 end,
                    h = function(max) return max.h end
                },
                centerThird = {
                    x = function(max) return max.x + (max.w / 3) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w / 3 end,
                    h = function(max) return max.h end
                },
                rightThird = {
                    x = function(max) return max.x + (max.w * 2 / 3) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w / 3 end,
                    h = function(max) return max.h end
                },
                leftTwoThirds = {
                    x = function(max) return max.x end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w * 2 / 3 end,
                    h = function(max) return max.h end
                },
                rightTwoThirds = {
                    x = function(max) return max.x + (max.w / 3) end,
                    y = function(max) return max.y end,
                    w = function(max) return max.w * 2 / 3 end,
                    h = function(max) return max.h end
                }
            }
        }
    }

    -- Add common layouts to all configurations
    for _, layoutSet in pairs(WindowManager.layoutSets) do
        local commonLayouts = {
            trueFull = {
                x = function(max) return max.x end,
                y = function(max) return max.y end,
                w = function(max) return max.w end,
                h = function(max) return max.h end
            },
            nearlyFull = {
                x = function(max) return max.x + (max.w * 0.05) end,
                y = function(max) return max.y + (max.h * 0.05) end,
                w = function(max) return max.w - (max.w * 0.1) end,
                h = function(max) return max.h - (max.h * 0.1) end
            },
            topHalf = {
                x = function(max) return max.x end,
                y = function(max) return max.y end,
                w = function(max) return max.w end,
                h = function(max) return max.h / 2 end
            },
            bottomHalf = {
                x = function(max) return max.x end,
                y = function(max) return max.y + (max.h / 2) end,
                w = function(max) return max.w end,
                h = function(max) return max.h / 2 end
            },
            topLeft = {
                x = function(max) return max.x end,
                y = function(max) return max.y end,
                w = function(max) return max.w / 2 end,
                h = function(max) return max.h / 2 end
            },
            topRight = {
                x = function(max) return max.x + (max.w / 2) end,
                y = function(max) return max.y end,
                w = function(max) return max.w / 2 end,
                h = function(max) return max.h / 2 end
            },
            bottomLeft = {
                x = function(max) return max.x end,
                y = function(max) return max.y + (max.h / 2) end,
                w = function(max) return max.w / 2 end,
                h = function(max) return max.h / 2 end
            },
            bottomRight = {
                x = function(max) return max.x + (max.w / 2) end,
                y = function(max) return max.y + (max.h / 2) end,
                w = function(max) return max.w / 2 end,
                h = function(max) return max.h / 2 end
            },
            centerScreen = {
                x = function(max) return max.x + (max.w * 0.1) end,
                y = function(max) return max.y + (max.h * 0.1) end,
                w = function(max) return max.w - (max.w * 0.2) end,
                h = function(max) return max.h - (max.h * 0.2) end
            }
        }

        -- Merge common layouts into each configuration
        for name, layout in pairs(commonLayouts) do
            if not layoutSet.standardLayouts[name] then
                layoutSet.standardLayouts[name] = layout
            end
        end
    end
end

-- Get current layouts based on monitor configuration
function WindowManager.getCurrentLayouts()
    local config = WindowManager.currentMonitorConfig
    if config == "unknown" then
        WindowManager.detectMonitorConfiguration()
        config = WindowManager.currentMonitorConfig
    end

    local layoutSet = WindowManager.layoutSets[config]
    if not layoutSet then
        log:w('No layout set found for configuration:', config, 'using dual_monitor as fallback')
        layoutSet = WindowManager.layoutSets.dual_monitor
    end

    return layoutSet.miniLayouts, layoutSet.standardLayouts
end

-- Legacy layout definitions (now populated by current configuration)
local miniLayouts = {}
local standardLayouts = {}

-- Initialize the layout system
function WindowManager.initializeLayouts()
    initializeLayoutSets()
    WindowManager.detectMonitorConfiguration()

    -- Update legacy layout variables
    local currentMini, currentStandard = WindowManager.getCurrentLayouts()
    miniLayouts = currentMini
    standardLayouts = currentStandard

    log:i('Layout system initialized for configuration:', WindowManager.currentMonitorConfig)
end

-- Function to manually refresh layouts (useful when monitors are connected/disconnected)
function WindowManager.refreshLayouts()
    log:i('Refreshing layouts due to monitor configuration change')
    local oldConfig = WindowManager.currentMonitorConfig
    WindowManager.detectMonitorConfiguration()
    local newConfig = WindowManager.currentMonitorConfig

    if oldConfig ~= newConfig then
        log:i('Monitor configuration changed from', oldConfig, 'to', newConfig)
        local currentMini, currentStandard = WindowManager.getCurrentLayouts()
        miniLayouts = currentMini
        standardLayouts = currentStandard
        hs.alert.show(string.format("Layout updated for %s setup", newConfig:gsub("_", " ")))
    else
        log:d('Monitor configuration unchanged:', newConfig)
    end
end

-- Monitor configuration info function
function WindowManager.showMonitorInfo()
    local config = WindowManager.detectMonitorConfiguration()
    local info = string.format("Monitor Setup: %s (%d screens)\n",
        config.type:gsub("_", " "), config.count)

    for i, screen in ipairs(config.screens) do
        info = info .. string.format("Screen %d: %s (%s)\n",
            i, screen.name, screen.size)
    end

    hs.alert.show(info, 4)
    log:i('Monitor configuration info displayed')
    return config
end

-- Initialize layout system on module load
WindowManager.initializeLayouts()
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

    -- Get current layout set
    local currentMini, _ = WindowManager.getCurrentLayouts()
    -- Get current layout based on counter
    local layout = currentMini[(WindowManager.counter % #currentMini) + 1]

    -- Create new frame using layout functions
    local newFrame = hs.geometry.rect(
        layout.x(max),
        layout.y(max),
        layout.w(max),
        layout.h(max)
    )

    -- Apply the frame using the robust helper
    WindowManager.setFrameInScreenWithRetry(win, newFrame)
    WindowManager.currentFrame = newFrame

    -- Increment counter
    WindowManager.counter = (WindowManager.counter + 1) % #currentMini
end

function WindowManager.halfShuffle(numRows, numCols)
    numRows = numRows or 3
    numCols = numCols or 2

    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local max = screen:frame()

    local sectionWidth = max.w / numCols
    local sectionHeight = max.h / numRows

    local colCounter = WindowManager.colCounter
    local rowCounter = WindowManager.rowCounter

    local x = max.x + (colCounter * sectionWidth)
    local y = max.y + (rowCounter * sectionHeight)

    -- Create a geometry object for the new frame
    local newFrame = hs.geometry.rect(x, y, sectionWidth, sectionHeight)
    log.i('Half shuffle w/ position: ', rowCounter, colCounter)

    -- Apply the frame using the robust helper
    WindowManager.setFrameInScreenWithRetry(win, newFrame)
    WindowManager.currentFrame = newFrame

    -- Update counters
    WindowManager.rowCounter = (WindowManager.rowCounter + 1) % numRows
    if WindowManager.rowCounter == 0 then
        WindowManager.colCounter = (WindowManager.colCounter + 1) % numCols
    end
end

function WindowManager.applyLayout(layoutName)
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show('No focused window found')
        return
    end

    -- Get current layout set
    local _, currentStandard = WindowManager.getCurrentLayouts()
    local layout = currentStandard[layoutName]
    if not layout then
        hs.alert.show('Invalid layout name: ' .. layoutName)
        log:w('Invalid layout requested:', layoutName, 'for configuration:', WindowManager.currentMonitorConfig)
        return
    end

    local screen = win:screen()
    local max = screen:frame()

    -- Calculate new frame using layout functions
    local newFrame = hs.geometry.rect(
        layout.x(max),
        layout.y(max),
        layout.w(max),
        layout.h(max)
    )

    -- Save original frame for logging
    local originalFrame = win:frame()

    -- Use our robust helper function to set the frame
    local success = WindowManager.setFrameInScreenWithRetry(win, newFrame)

    -- Log the result
    if success then
        log.i('Successfully applied layout:', layoutName, 'for', WindowManager.currentMonitorConfig)
    else
        log.w('Applied layout with potential issues:', layoutName)
    end

    log.d('Layout change details:', layoutName, 'from', hs.inspect(originalFrame), 'to', hs.inspect(newFrame))
end

function WindowManager.moveToScreen(direction, position)
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local nextScreen = (direction == "next") and screen:next() or screen:previous()
    local max = nextScreen:frame()

    -- Create a geometry object for the new frame
    local newFrame
    if position == "left" then
        newFrame = hs.geometry.rect(max.x, max.y, max.w / 2, max.h)
    else
        newFrame = hs.geometry.rect(max.x + (max.w / 2), max.y, max.w / 2, max.h / 2)
    end

    -- First move to screen
    win:moveToScreen(nextScreen)
    -- Then apply the frame using the robust helper
    hs.timer.doAfter(0.1, function()
        WindowManager.setFrameInScreenWithRetry(win, newFrame)
    end)
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
    hs.window.animationDuration = 0.0
    win:setFrame(f, 0.0)
    -- WindowManager.currentFrame = f
end

function WindowManager.moveWindowMouseCenter()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    hs.window.animationDuration = 0.0
    win:setFrame(f, 0.0)
    -- WindowManager.currentFrame = f
end

function WindowManager.moveWindowMouseCorner()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    f.x = mouse.x
    f.y = mouse.y
    hs.window.animationDuration = 0.0
    win:setFrame(f, 0.0)
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

-- Helper function to set window frame with verification and retry
function WindowManager.setFrameInScreenWithRetry(win, newFrame, retryCount)
    retryCount = retryCount or 5


    -- Ensure animations are always disabled for reliable positioning
    hs.window.animationDuration = 0

    -- Try to set the frame
    win:setFrame(newFrame, 0)
    hs.timer.usleep(300000)

    -- Verify the frame was set correctly by comparing with a small tolerance
    local resultFrame = win:frame()
    local frameCorrect =
        math.abs(resultFrame.x - newFrame.x) < 10 and
        math.abs(resultFrame.y - newFrame.y) < 10 and
        math.abs(resultFrame.w - newFrame.w) < 10 and
        math.abs(resultFrame.h - newFrame.h) < 10

    -- If frame wasn't applied correctly and we have retries left, try alternative methods
    if not frameCorrect and retryCount > 0 then
        log.w('Frame set attempt failed, trying alternative method. Attempts left:', retryCount)

        -- Try with workarounds method
        win:setFrameWithWorkarounds(newFrame)

        -- Add a small delay
        hs.timer.usleep(300000)

        -- Recursive call with one fewer retry
        return WindowManager.setFrameInScreenWithRetry(win, newFrame, retryCount - 1)
    end

    return frameCorrect
end
function WindowManager.restoreWindowPosition()
    log.i('Restoring window position')
    local win = hs.window.focusedWindow()
    if win and WindowManager.lastWindowPosition[win:id()] then
        log.d('Restoring position for window:', win:id(), hs.inspect(WindowManager.lastWindowPosition[win:id()]))
        WindowManager.setFrameInScreenWithRetry(win, WindowManager.lastWindowPosition[win:id()])
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
            win:setFrame(savedPosition, 0)
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
-- Toggle layout functions
function WindowManager.toggleRightLayout()
    WindowManager.rightLayoutState.isSmall = not WindowManager.rightLayoutState.isSmall
    if WindowManager.rightLayoutState.isSmall then
        WindowManager.applyLayout('rightSmall')
        log:d("Right Small Layout", __FILE__, 485)
    else
        WindowManager.applyLayout('rightHalf')
        log:d("Right Half Layout", __FILE__, 488)
    end
end

function WindowManager.toggleLeftLayout()
    WindowManager.leftLayoutState.isSmall = not WindowManager.leftLayoutState.isSmall
    if WindowManager.leftLayoutState.isSmall then
        WindowManager.applyLayout('leftSmall')
        log:d("Left Small Layout", __FILE__, 495)
    else
        WindowManager.applyLayout('leftHalf')
        log:d("Left Half Layout", __FILE__, 498)
    end
end

function WindowManager.toggleFullLayout()
    WindowManager.fullLayoutState.currentState = (WindowManager.fullLayoutState.currentState + 1) % 3
    if WindowManager.fullLayoutState.currentState == 0 then
        WindowManager.applyLayout('fullScreen')
        log:d("Full Screen Layout", __FILE__, 505)
    elseif WindowManager.fullLayoutState.currentState == 1 then
        WindowManager.applyLayout('nearlyFull')
        log:d("Nearly Full Layout", __FILE__, 508)
    else
        WindowManager.applyLayout('trueFull')
        log:d("True Full Layout", __FILE__, 511)
    end
end
-- Multi-window layout management
function WindowManager.saveCurrentLayout(layoutName)
    log.i('Saving multi-window layout:', layoutName)

    -- Get all visible windows
    local allVisibleWindows = hs.window.visibleWindows()
    local savedWindows = {}

    for _, win in ipairs(allVisibleWindows) do
        -- Only include standard, non-minimized windows
        if win:isStandard() and not win:isMinimized() then
            -- Get information about each window
            local app = win:application()
            local appName = app and app:name() or "Unknown"
            local windowTitle = win:title() or "Untitled Window"
            local frame = win:frame()
            local screen = win:screen():getUUID()

            -- Store window information
            table.insert(savedWindows, {
                appName = appName,
                appBundleID = app and app:bundleID() or nil,
                windowTitle = windowTitle,
                frame = frame,
                screenUUID = screen,
                windowID = win:id()
            })

            log.d('Saved window in layout:', appName, windowTitle, hs.inspect(frame))
        end
    end

    -- Save layout
    WindowManager.savedLayouts[layoutName] = {
        windows = savedWindows,
        timestamp = os.time(),
        description = "Layout saved on " .. os.date("%Y-%m-%d %H:%M:%S")
    }

    hs.alert.show(string.format("Saved layout '%s' with %d windows", layoutName, #savedWindows))
    return #savedWindows
end

function WindowManager.restoreLayout(layoutName)
    log.i('Restoring layout:', layoutName)

    local layout = WindowManager.savedLayouts[layoutName]
    if not layout then
        hs.alert.show(string.format("No layout found with name '%s'", layoutName))
        return 0
    end

    local restoredCount = 0

    -- Get screens by UUID
    local screens = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        screens[screen:getUUID()] = screen
    end

    -- First focus all apps that need to be part of this layout
    -- This gives apps time to launch before trying to position windows
    for _, winInfo in ipairs(layout.windows) do
        if winInfo.appBundleID then
            hs.application.launchOrFocusByBundleID(winInfo.appBundleID)
        end
    end

    -- Wait a moment for apps to launch
    hs.timer.doAfter(0.5, function()
        -- Now try to restore each window
        for _, winInfo in ipairs(layout.windows) do
            -- Find the window - first try direct ID matching
            local win = hs.window.get(winInfo.windowID)

            -- If window not found by ID, try to find by app and title
            if not win and winInfo.appBundleID then
                local app = hs.application.get(winInfo.appBundleID)
                if app then
                    -- Try to find by title
                    for _, appWindow in ipairs(app:allWindows()) do
                        if appWindow:title() == winInfo.windowTitle then
                            win = appWindow
                            break
                        end
                    end

                    -- If still not found, just use the first window of the app
                    if not win and #app:allWindows() > 0 then
                        win = app:allWindows()[1]
                    end
                end
            end

            -- If we found a window to work with, set its position
            if win then
                local screen = screens[winInfo.screenUUID] or win:screen()
                local newFrame = hs.geometry.rect(winInfo.frame)

                -- Move to correct screen first if needed
                if screen and screen:id() ~= win:screen():id() then
                    win:moveToScreen(screen)
                end

                -- Apply the frame
                local success = WindowManager.setFrameInScreenWithRetry(win, newFrame)
                if success then
                    restoredCount = restoredCount + 1
                    log.d('Restored window position:', winInfo.appName, winInfo.windowTitle)
                else
                    log.w('Failed to restore window position:', winInfo.appName, winInfo.windowTitle)
                end
            else
                log.w('Could not find window to restore:', winInfo.appName, winInfo.windowTitle)
            end
        end

        hs.alert.show(string.format("Restored %d/%d windows from layout '%s'",
            restoredCount, #layout.windows, layoutName))
    end)

    return true
end

function WindowManager.listSavedLayouts()
    log.i('Listing all saved layouts')

    local layouts = {}
    for name, layout in pairs(WindowManager.savedLayouts) do
        table.insert(layouts, {
            name = name,
            windowCount = #layout.windows,
            timestamp = layout.timestamp,
            description = layout.description
        })
    end

    -- Sort by timestamp, most recent first
    table.sort(layouts, function(a, b) return a.timestamp > b.timestamp end)

    return layouts
end

function WindowManager.deleteLayout(layoutName)
    if WindowManager.savedLayouts[layoutName] then
        WindowManager.savedLayouts[layoutName] = nil
        hs.alert.show(string.format("Deleted layout '%s'", layoutName))
        return true
    else
        hs.alert.show(string.format("No layout found with name '%s'", layoutName))
        return false
    end
end
-- Save in global environment for module reuse
_G.WindowManager = WindowManager
return WindowManager
