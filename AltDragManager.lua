-- AltDragManager.lua - Alt-Drag Window Management
-- Implements alt+drag to move windows and alt+right-click+drag to resize windows
-- Similar to functionality found in Linux window managers and Windows utilities like "alt-drag"

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.AltDragManager then
    log:d('Returning existing AltDragManager module')
    return _G.AltDragManager
end

log:i('Initializing Alt-Drag Window Management system')

local AltDragManager = {
    -- State tracking
    isDragging = false,
    isResizing = false,
    draggedWindow = nil,
    initialWindowFrame = nil,
    initialMousePos = nil,

    -- Configuration
    config = {
        moveModifier = { "alt" },
        resizeModifier = { "alt" },
        moveButton = "left",
        resizeButton = "right",
        enabled = true,
        sensitivity = 1.0,                 -- Multiplier for drag sensitivity
        minWindowSize = { w = 100, h = 100 }, -- Minimum window size when resizing
        debug = true                          -- Enable debug logging
    },

    -- Event taps
    dragTap = nil,
    flagsTap = nil
}

-- Helper function to check if modifiers are pressed
local function modifiersPressed(modifiers, eventFlags)
    if not modifiers or #modifiers == 0 then return false end

    for _, mod in ipairs(modifiers) do
        if mod == "alt" and not eventFlags.alt then return false end
        if mod == "cmd" and not eventFlags.cmd then return false end
        if mod == "ctrl" and not eventFlags.ctrl then return false end
        if mod == "shift" and not eventFlags.shift then return false end
    end
    return true
end

-- Get window under mouse cursor (improved version)
local function getWindowUnderMouse(mousePos)
    if not mousePos then
        mousePos = hs.mouse.absolutePosition()
    end
    local windows = hs.window.orderedWindows()

    if AltDragManager.config.debug then
        log:d('Checking windows at mouse position:', mousePos.x, mousePos.y)
        log:d('Found', #windows, 'total windows')
    end

    for i, win in ipairs(windows) do
        if win:isVisible() and not win:isMinimized() then
            local frame = win:frame()
            if mousePos.x >= frame.x and mousePos.x <= frame.x + frame.w and
                mousePos.y >= frame.y and mousePos.y <= frame.y + frame.h then
                if AltDragManager.config.debug then
                    log:d('Found window under mouse:', win:title(), 'at index', i)
                end
                return win
            end
        end
    end
    if AltDragManager.config.debug then
        log:d('No window found under mouse at', mousePos.x, mousePos.y)
    end
    return nil
end

-- Start window drag operation
local function startWindowDrag(window, mousePos)
    if not window then return false end

    AltDragManager.isDragging = true
    AltDragManager.draggedWindow = window
    AltDragManager.initialWindowFrame = window:frame()
    AltDragManager.initialMousePos = mousePos

    -- Bring window to front
    window:focus()

    if AltDragManager.config.debug then
        log:d('Started dragging window:', window:title())
        log:d('Initial frame:', hs.inspect(AltDragManager.initialWindowFrame))
        log:d('Initial mouse pos:', hs.inspect(AltDragManager.initialMousePos))
    end
    return true
end

-- Start window resize operation
local function startWindowResize(window, mousePos)
    if not window then return false end

    AltDragManager.isResizing = true
    AltDragManager.draggedWindow = window
    AltDragManager.initialWindowFrame = window:frame()
    AltDragManager.initialMousePos = mousePos

    -- Bring window to front
    window:focus()

    if AltDragManager.config.debug then
        log:d('Started resizing window:', window:title())
        log:d('Initial frame:', hs.inspect(AltDragManager.initialWindowFrame))
        log:d('Initial mouse pos:', hs.inspect(AltDragManager.initialMousePos))
    end
    return true
end

-- Update window position during drag
local function updateWindowPosition(mousePos)
    if not AltDragManager.isDragging or not AltDragManager.draggedWindow then return end

    local deltaX = (mousePos.x - AltDragManager.initialMousePos.x) * AltDragManager.config.sensitivity
    local deltaY = (mousePos.y - AltDragManager.initialMousePos.y) * AltDragManager.config.sensitivity

    local newFrame = {
        x = AltDragManager.initialWindowFrame.x + deltaX,
        y = AltDragManager.initialWindowFrame.y + deltaY,
        w = AltDragManager.initialWindowFrame.w,
        h = AltDragManager.initialWindowFrame.h
    }

    if AltDragManager.config.debug then
        log:d('Updating window position. Delta:', deltaX, deltaY, 'New frame:', hs.inspect(newFrame))
    end
    -- Disable animations for smooth dragging
    hs.window.animationDuration = 0
    AltDragManager.draggedWindow:setFrame(newFrame, 0)
end

-- Update window size during resize
local function updateWindowSize(mousePos)
    if not AltDragManager.isResizing or not AltDragManager.draggedWindow then return end

    local deltaX = (mousePos.x - AltDragManager.initialMousePos.x) * AltDragManager.config.sensitivity
    local deltaY = (mousePos.y - AltDragManager.initialMousePos.y) * AltDragManager.config.sensitivity

    local newWidth = math.max(AltDragManager.initialWindowFrame.w + deltaX, AltDragManager.config.minWindowSize.w)
    local newHeight = math.max(AltDragManager.initialWindowFrame.h + deltaY, AltDragManager.config.minWindowSize.h)

    local newFrame = {
        x = AltDragManager.initialWindowFrame.x,
        y = AltDragManager.initialWindowFrame.y,
        w = newWidth,
        h = newHeight
    }

    if AltDragManager.config.debug then
        log:d('Updating window size. Delta:', deltaX, deltaY, 'New frame:', hs.inspect(newFrame))
    end
    -- Disable animations for smooth resizing
    hs.window.animationDuration = 0
    AltDragManager.draggedWindow:setFrame(newFrame, 0)
end

-- Stop drag/resize operation
local function stopDragResize()
    if AltDragManager.isDragging then
        if AltDragManager.config.debug then
            log:d('Stopped dragging window:',
                AltDragManager.draggedWindow and AltDragManager.draggedWindow:title() or 'unknown')
        end
    elseif AltDragManager.isResizing then
        if AltDragManager.config.debug then
            log:d('Stopped resizing window:',
                AltDragManager.draggedWindow and AltDragManager.draggedWindow:title() or 'unknown')
        end
    end

    AltDragManager.isDragging = false
    AltDragManager.isResizing = false
    AltDragManager.draggedWindow = nil
    AltDragManager.initialWindowFrame = nil
    AltDragManager.initialMousePos = nil
end

-- Main event handler for mouse events
local function handleMouseEvent(event)
    if not AltDragManager.config.enabled then return false end

    local eventType = event:getType()
    local eventFlags = event:getFlags()
    -- Get mouse position from event (more accurate than hs.mouse.absolutePosition())
    local eventLocation = event:location()
    local mousePos = { x = eventLocation.x, y = eventLocation.y }

    if AltDragManager.config.debug then
        log:d('Mouse event:', eventType, 'at', mousePos.x, mousePos.y, 'flags:', hs.inspect(eventFlags))
    end

    -- Handle mouse down events
    if eventType == hs.eventtap.event.types.leftMouseDown then
        if modifiersPressed(AltDragManager.config.moveModifier, eventFlags) then
            local window = getWindowUnderMouse(mousePos)
            if window and startWindowDrag(window, mousePos) then
                if AltDragManager.config.debug then
                    log:d('Consuming left mouse down event for drag')
                end
                return true -- Consume the event
            end
        end
    elseif eventType == hs.eventtap.event.types.rightMouseDown then
        if modifiersPressed(AltDragManager.config.resizeModifier, eventFlags) then
            local window = getWindowUnderMouse(mousePos)
            if window and startWindowResize(window, mousePos) then
                if AltDragManager.config.debug then
                    log:d('Consuming right mouse down event for resize')
                end
                return true -- Consume the event
            end
        end

        -- Handle mouse drag events
    elseif eventType == hs.eventtap.event.types.leftMouseDragged then
        if AltDragManager.isDragging then
            updateWindowPosition(mousePos)
            return true -- Consume the event
        end
    elseif eventType == hs.eventtap.event.types.rightMouseDragged then
        if AltDragManager.isResizing then
            updateWindowSize(mousePos)
            return true -- Consume the event
        end

        -- Handle mouse up events
    elseif eventType == hs.eventtap.event.types.leftMouseUp then
        if AltDragManager.isDragging then
            stopDragResize()
            return true -- Consume the event
        end
    elseif eventType == hs.eventtap.event.types.rightMouseUp then
        if AltDragManager.isResizing then
            stopDragResize()
            return true -- Consume the event
        end
    end

    return false -- Don't consume the event
end

-- Handle modifier key changes (stop drag/resize when modifiers are released)
local function handleFlagsChanged(event)
    if not AltDragManager.config.enabled then return false end

    local eventFlags = event:getFlags()

    -- If we're dragging or resizing and the required modifiers are no longer pressed, stop
    if AltDragManager.isDragging then
        if not modifiersPressed(AltDragManager.config.moveModifier, eventFlags) then
            if AltDragManager.config.debug then
                log:d('Stopping drag due to modifier release')
            end
            stopDragResize()
        end
    elseif AltDragManager.isResizing then
        if not modifiersPressed(AltDragManager.config.resizeModifier, eventFlags) then
            if AltDragManager.config.debug then
                log:d('Stopping resize due to modifier release')
            end
            stopDragResize()
        end
    end

    return false -- Don't consume the event
end

-- Public API functions

function AltDragManager.start()
    if AltDragManager.dragTap or AltDragManager.flagsTap then
        log:w('Alt-Drag Manager already started')
        return
    end

    -- Create event tap for mouse events
    AltDragManager.dragTap = hs.eventtap.new({
        hs.eventtap.event.types.leftMouseDown,
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.leftMouseDragged,
        hs.eventtap.event.types.rightMouseDragged,
        hs.eventtap.event.types.leftMouseUp,
        hs.eventtap.event.types.rightMouseUp
    }, handleMouseEvent)

    -- Create event tap for modifier key changes
    AltDragManager.flagsTap = hs.eventtap.new({
        hs.eventtap.event.types.flagsChanged
    }, handleFlagsChanged)

    -- Start the event taps
    local success1 = AltDragManager.dragTap:start()
    local success2 = AltDragManager.flagsTap:start()

    if success1 and success2 then
        log:i('Alt-Drag Manager started successfully')
        hs.alert.show("Alt-Drag enabled: Alt+drag to move, Alt+right-drag to resize", 3)
    else
        log:e('Failed to start Alt-Drag Manager. Check accessibility permissions!')
        hs.alert.show("Alt-Drag failed to start! Check accessibility permissions.", 4)

        -- Clean up if only partially started
        if AltDragManager.dragTap then
            AltDragManager.dragTap:stop()
            AltDragManager.dragTap = nil
        end
        if AltDragManager.flagsTap then
            AltDragManager.flagsTap:stop()
            AltDragManager.flagsTap = nil
        end
    end
end

function AltDragManager.stop()
    if AltDragManager.dragTap then
        AltDragManager.dragTap:stop()
        AltDragManager.dragTap = nil
    end

    if AltDragManager.flagsTap then
        AltDragManager.flagsTap:stop()
        AltDragManager.flagsTap = nil
    end

    -- Stop any ongoing drag/resize
    stopDragResize()

    log:i('Alt-Drag Manager stopped')
    hs.alert.show("Alt-Drag disabled", 2)
end

function AltDragManager.toggle()
    if AltDragManager.dragTap and AltDragManager.flagsTap then
        AltDragManager.stop()
    else
        AltDragManager.start()
    end
end

function AltDragManager.isRunning()
    return AltDragManager.dragTap ~= nil and AltDragManager.flagsTap ~= nil
end

function AltDragManager.setConfig(newConfig)
    for key, value in pairs(newConfig) do
        if AltDragManager.config[key] ~= nil then
            AltDragManager.config[key] = value
            log:d('Updated config:', key, '=', value)
        end
    end
end

function AltDragManager.getConfig()
    return AltDragManager.config
end

function AltDragManager.getStatus()
    return {
        enabled = AltDragManager.config.enabled,
        running = AltDragManager.isRunning(),
        isDragging = AltDragManager.isDragging,
        isResizing = AltDragManager.isResizing,
        currentWindow = AltDragManager.draggedWindow and AltDragManager.draggedWindow:title() or nil,
        debug = AltDragManager.config.debug
    }
end

-- Test function to verify event taps are working
function AltDragManager.testEventTaps()
    log:i('Testing event taps...')
    local mousePos = hs.mouse.absolutePosition()
    log:i('Current mouse position:', mousePos.x, mousePos.y)

    local window = getWindowUnderMouse(mousePos)
    if window then
        log:i('Window under mouse:', window:title())
    else
        log:w('No window under mouse')
    end

    log:i('Event tap status - Drag tap:', AltDragManager.dragTap and 'running' or 'not running')
    log:i('Event tap status - Flags tap:', AltDragManager.flagsTap and 'running' or 'not running')
end
-- Auto-start by default
AltDragManager.start()

-- Store in global namespace
_G.AltDragManager = AltDragManager

log:i('Alt-Drag Manager module loaded successfully')
return AltDragManager
