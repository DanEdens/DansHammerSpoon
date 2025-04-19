local log = hs.logger.new('WindowToggler', 'debug')
log.i('Initializing window toggler system')

local WindowManager = require('WindowManager')

local WindowToggler = {
    -- Store positions by window title
    savedPositions = {}
}

-- Toggle a window between its current position and nearly full
function WindowToggler.toggleWindowPosition()
    local win = hs.window.focusedWindow()
    if not win then
        log.w('No focused window found')
        return
    end

    local windowTitle = win:title()
    local currentFrame = win:frame()

    -- If we have a saved position for this window title
    if WindowToggler.savedPositions[windowTitle] then
        -- Check if current position is roughly the "nearlyFull" layout
        local screen = win:screen()
        local max = screen:frame()
        local nearlyFullX = max.x + (max.w * 0.1)
        local nearlyFullY = max.y + (max.h * 0.1)
        local nearlyFullW = max.w * 0.8
        local nearlyFullH = max.h * 0.8

        -- Check if current position is similar to nearlyFull layout
        local isNearlyFull = math.abs(currentFrame.x - nearlyFullX) < 10 and
            math.abs(currentFrame.y - nearlyFullY) < 10 and
            math.abs(currentFrame.w - nearlyFullW) < 10 and
            math.abs(currentFrame.h - nearlyFullH) < 10

        if isNearlyFull then
            -- Restore the saved position
            win:setFrame(WindowToggler.savedPositions[windowTitle])
            log.i('Restored saved position for window:', windowTitle)
            hs.alert.show("Restored window position")
        else
            -- Save current position and move to nearlyFull
            WindowToggler.savedPositions[windowTitle] = currentFrame
            WindowManager.applyLayout('nearlyFull')
            log.i('Saved position and applied nearlyFull layout for window:', windowTitle)
            hs.alert.show("Applied nearly full layout")
        end
    else
        -- First time seeing this window title, save position and apply nearlyFull
        WindowToggler.savedPositions[windowTitle] = currentFrame
        WindowManager.applyLayout('nearlyFull')
        log.i('First time: saved position and applied nearlyFull layout for window:', windowTitle)
        hs.alert.show("Applied nearly full layout")
    end
end

-- Clear all saved positions
function WindowToggler.clearSavedPositions()
    WindowToggler.savedPositions = {}
    log.i('Cleared all saved window positions')
    hs.alert.show("Cleared all saved window positions")
end

-- List all saved window titles
function WindowToggler.listSavedWindows()
    local result = "Saved window positions:\n"
    local count = 0

    for title, _ in pairs(WindowToggler.savedPositions) do
        result = result .. "- " .. title .. "\n"
        count = count + 1
    end

    if count == 0 then
        result = "No saved window positions"
    end

    log.i('Listed saved windows:', count)
    hs.alert.show(result, 3)
end

return WindowToggler
