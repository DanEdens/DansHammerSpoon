--- === KineticLatch ===
---
--- **The Mad Tinker's Window Manipulation Contraption** 🔧⚡
---
--- A kinetic window latching system that allows you to grab and manipulate windows
--- from anywhere on their surface using modifier keys - just like those fancy
--- Linux window managers and Windows utilities, but with more MADNESS!
---
--- **Features:**
--- * Alt + Left-Click + Drag: Latch onto windows and drag them around
--- * Alt + Right-Click + Drag: Resize windows from any point
--- * Configurable modifier keys and sensitivity
--- * Smooth, lag-free operation optimized for mad tinkering
--- * Auto-focusing and kinetic feedback
---
--- **Mad Science:** Uses Hammerspoon's event taps to intercept mouse events
--- and apply kinetic transformations to window geometry in real-time!
---
--- Download: https://github.com/hammerspoon/Spoons/raw/master/Spoons/KineticLatch.spoon.zip

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "KineticLatch"
obj.version = "1.0.0"
obj.author = "Mad Tinker Labs <d.edens@madness.interactive>"
obj.homepage = "https://github.com/hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.logger = hs.logger.new('KineticLatch')

--- KineticLatch.defaultConfig
--- Variable
--- Default configuration for the kinetic latching system
obj.defaultConfig = {
    moveModifier = { "alt" },           -- Keys for kinetic window latching
    resizeModifier = { "alt" },         -- Keys for kinetic window reshaping
    moveButton = "left",                -- Primary latch button
    resizeButton = "right",             -- Reshape button
    enabled = true,                     -- Enable the kinetic contraption
    sensitivity = 1.0,                  -- Kinetic sensitivity multiplier
    minWindowSize = { w = 100, h = 100 }, -- Minimum window dimensions
    debug = false,                      -- Mad scientist debug mode
    autoStart = true                    -- Auto-engage the contraption on load
}

--- KineticLatch.config
--- Variable
--- Current configuration - starts with defaults
obj.config = {}

-- Internal state variables
obj.isDragging = false
obj.isResizing = false
obj.draggedWindow = nil
obj.initialWindowFrame = nil
obj.initialMousePos = nil
obj.dragTap = nil
obj.flagsTap = nil

--- === Internal Functions ===

-- Helper function to check if kinetic modifiers are engaged
local function modifiersEngaged(modifiers, eventFlags)
    if not modifiers or #modifiers == 0 then return false end

    for _, mod in ipairs(modifiers) do
        if mod == "alt" and not eventFlags.alt then return false end
        if mod == "cmd" and not eventFlags.cmd then return false end
        if mod == "ctrl" and not eventFlags.ctrl then return false end
        if mod == "shift" and not eventFlags.shift then return false end
    end
    return true
end

-- Locate window under kinetic cursor
local function getWindowUnderCursor(mousePos)
    if not mousePos then
        mousePos = hs.mouse.absolutePosition()
    end

    local windows = hs.window.orderedWindows()

    for i, win in ipairs(windows) do
        if win:isVisible() and not win:isMinimized() then
            local frame = win:frame()
            if mousePos.x >= frame.x and mousePos.x <= frame.x + frame.w and
                mousePos.y >= frame.y and mousePos.y <= frame.y + frame.h then
                if obj.config.debug then
                    obj.logger.d('Kinetic latch detected window:', win:title())
                end
                return win
            end
        end
    end

    return nil
end

-- Engage kinetic window latching
local function engageKineticDrag(window, mousePos)
    if not window then return false end

    obj.isDragging = true
    obj.draggedWindow = window
    obj.initialWindowFrame = window:frame()
    obj.initialMousePos = mousePos

    -- Bring window to the foreground for kinetic manipulation
    window:focus()

    if obj.config.debug then
        obj.logger.d('Kinetic drag engaged on window:', window:title())
    end
    return true
end

-- Engage kinetic window reshaping
local function engageKineticResize(window, mousePos)
    if not window then return false end

    obj.isResizing = true
    obj.draggedWindow = window
    obj.initialWindowFrame = window:frame()
    obj.initialMousePos = mousePos

    -- Bring window to the foreground for kinetic manipulation
    window:focus()

    if obj.config.debug then
        obj.logger.d('Kinetic resize engaged on window:', window:title())
    end
    return true
end

-- Apply kinetic position transformation
local function applyKineticPosition(mousePos)
    if not obj.isDragging or not obj.draggedWindow then return end

    local deltaX = (mousePos.x - obj.initialMousePos.x) * obj.config.sensitivity
    local deltaY = (mousePos.y - obj.initialMousePos.y) * obj.config.sensitivity

    local newFrame = {
        x = obj.initialWindowFrame.x + deltaX,
        y = obj.initialWindowFrame.y + deltaY,
        w = obj.initialWindowFrame.w,
        h = obj.initialWindowFrame.h
    }

    -- Disable animations for smooth kinetic motion
    hs.window.animationDuration = 0
    obj.draggedWindow:setFrame(newFrame, 0)
end

-- Apply kinetic size transformation
local function applyKineticResize(mousePos)
    if not obj.isResizing or not obj.draggedWindow then return end

    local deltaX = (mousePos.x - obj.initialMousePos.x) * obj.config.sensitivity
    local deltaY = (mousePos.y - obj.initialMousePos.y) * obj.config.sensitivity

    local newWidth = math.max(obj.initialWindowFrame.w + deltaX, obj.config.minWindowSize.w)
    local newHeight = math.max(obj.initialWindowFrame.h + deltaY, obj.config.minWindowSize.h)

    local newFrame = {
        x = obj.initialWindowFrame.x,
        y = obj.initialWindowFrame.y,
        w = newWidth,
        h = newHeight
    }

    -- Disable animations for smooth kinetic motion
    hs.window.animationDuration = 0
    obj.draggedWindow:setFrame(newFrame, 0)
end

-- Disengage kinetic manipulation
local function disengageKinetics()
    if obj.isDragging then
        if obj.config.debug then
            obj.logger.d('Kinetic drag disengaged from window:',
                obj.draggedWindow and obj.draggedWindow:title() or 'unknown')
        end
    elseif obj.isResizing then
        if obj.config.debug then
            obj.logger.d('Kinetic resize disengaged from window:',
                obj.draggedWindow and obj.draggedWindow:title() or 'unknown')
        end
    end

    obj.isDragging = false
    obj.isResizing = false
    obj.draggedWindow = nil
    obj.initialWindowFrame = nil
    obj.initialMousePos = nil
end

-- Main kinetic event processor
local function processKineticEvent(event)
    if not obj.config.enabled then return false end

    local eventType = event:getType()
    local eventFlags = event:getFlags()

    -- Extract kinetic coordinates from event stream
    local eventLocation = event:location()
    local mousePos = { x = eventLocation.x, y = eventLocation.y }

    -- Process kinetic engagement events
    if eventType == hs.eventtap.event.types.leftMouseDown then
        if modifiersEngaged(obj.config.moveModifier, eventFlags) then
            local window = getWindowUnderCursor(mousePos)
            if window and engageKineticDrag(window, mousePos) then
                return true -- Consume the kinetic event
            end
        end
    elseif eventType == hs.eventtap.event.types.rightMouseDown then
        if modifiersEngaged(obj.config.resizeModifier, eventFlags) then
            local window = getWindowUnderCursor(mousePos)
            if window and engageKineticResize(window, mousePos) then
                return true -- Consume the kinetic event
            end
        end

        -- Process kinetic manipulation events
    elseif eventType == hs.eventtap.event.types.leftMouseDragged then
        if obj.isDragging then
            applyKineticPosition(mousePos)
            return true -- Consume the kinetic event
        end
    elseif eventType == hs.eventtap.event.types.rightMouseDragged then
        if obj.isResizing then
            applyKineticResize(mousePos)
            return true -- Consume the kinetic event
        end

        -- Process kinetic disengagement events
    elseif eventType == hs.eventtap.event.types.leftMouseUp then
        if obj.isDragging then
            disengageKinetics()
            return true -- Consume the kinetic event
        end
    elseif eventType == hs.eventtap.event.types.rightMouseUp then
        if obj.isResizing then
            disengageKinetics()
            return true -- Consume the kinetic event
        end
    end

    return false -- Release the event to the system
end

-- Monitor kinetic modifier state changes
local function processModifierChanges(event)
    if not obj.config.enabled then return false end

    local eventFlags = event:getFlags()

    -- Disengage kinetics if required modifiers are no longer active
    if obj.isDragging then
        if not modifiersEngaged(obj.config.moveModifier, eventFlags) then
            disengageKinetics()
        end
    elseif obj.isResizing then
        if not modifiersEngaged(obj.config.resizeModifier, eventFlags) then
            disengageKinetics()
        end
    end

    return false -- Don't consume modifier events
end

--- === Public API ===

--- KineticLatch:init()
--- Method
--- Initializes the KineticLatch Spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:init()
    obj.logger.i('Initializing KineticLatch - The Mad Tinker\'s Window Contraption!')

    -- Initialize configuration with defaults
    obj.config = {}
    for k, v in pairs(obj.defaultConfig) do
        obj.config[k] = v
    end

    return self
end

--- KineticLatch:start()
--- Method
--- Starts the kinetic latching system
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:start()
    if obj.dragTap or obj.flagsTap then
        obj.logger.w('KineticLatch already engaged!')
        return self
    end

    -- Create kinetic event interceptors
    obj.dragTap = hs.eventtap.new({
        hs.eventtap.event.types.leftMouseDown,
        hs.eventtap.event.types.rightMouseDown,
        hs.eventtap.event.types.leftMouseDragged,
        hs.eventtap.event.types.rightMouseDragged,
        hs.eventtap.event.types.leftMouseUp,
        hs.eventtap.event.types.rightMouseUp
    }, processKineticEvent)

    obj.flagsTap = hs.eventtap.new({
        hs.eventtap.event.types.flagsChanged
    }, processModifierChanges)

    -- Engage the kinetic contraption
    local success1 = obj.dragTap:start()
    local success2 = obj.flagsTap:start()

    if success1 and success2 then
        obj.logger.i('KineticLatch engaged! Alt+drag to latch, Alt+right-drag to reshape!')
        hs.alert.show("⚡ KineticLatch ENGAGED! ⚡\nAlt+drag to latch windows, Alt+right-drag to reshape!", 3)
    else
        obj.logger.e('KineticLatch engagement failed! Check accessibility permissions!')
        hs.alert.show("⚠️ KineticLatch FAILED! Check accessibility permissions.", 4)

        -- Emergency cleanup
        if obj.dragTap then
            obj.dragTap:stop(); obj.dragTap = nil
        end
        if obj.flagsTap then
            obj.flagsTap:stop(); obj.flagsTap = nil
        end
    end

    return self
end

--- KineticLatch:stop()
--- Method
--- Stops the kinetic latching system
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:stop()
    if obj.dragTap then
        obj.dragTap:stop()
        obj.dragTap = nil
    end

    if obj.flagsTap then
        obj.flagsTap:stop()
        obj.flagsTap = nil
    end

    -- Emergency disengage any active kinetics
    disengageKinetics()

    obj.logger.i('KineticLatch disengaged')
    hs.alert.show("🔧 KineticLatch disengaged", 2)

    return self
end

--- KineticLatch:toggle()
--- Method
--- Toggles the kinetic latching system on/off
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:toggle()
    if obj:isRunning() then
        obj:stop()
    else
        obj:start()
    end
    return self
end

--- KineticLatch:isRunning()
--- Method
--- Checks if the kinetic latching system is currently active
---
--- Parameters:
---  * None
---
--- Returns:
---  * Boolean - true if running, false otherwise
function obj:isRunning()
    return obj.dragTap ~= nil and obj.flagsTap ~= nil
end

--- KineticLatch:configure(config)
--- Method
--- Configures the kinetic latching system
---
--- Parameters:
---  * config - A table of configuration options
---
--- Returns:
---  * The KineticLatch object
function obj:configure(config)
    for key, value in pairs(config) do
        if obj.config[key] ~= nil then
            obj.config[key] = value
            obj.logger.d('Updated kinetic parameter:', key, '=', value)
        else
            obj.logger.w('Unknown kinetic parameter:', key)
        end
    end
    return self
end

--- KineticLatch:getConfig()
--- Method
--- Gets the current configuration
---
--- Parameters:
---  * None
---
--- Returns:
---  * A table containing the current configuration
function obj:getConfig()
    return obj.config
end

--- KineticLatch:getStatus()
--- Method
--- Gets the current status of the kinetic system
---
--- Parameters:
---  * None
---
--- Returns:
---  * A table containing status information
function obj:getStatus()
    return {
        enabled = obj.config.enabled,
        running = obj:isRunning(),
        isDragging = obj.isDragging,
        isResizing = obj.isResizing,
        currentWindow = obj.draggedWindow and obj.draggedWindow:title() or nil,
        debug = obj.config.debug,
        kineticState = obj.isDragging and "LATCHED" or obj.isResizing and "RESHAPING" or "IDLE"
    }
end

--- KineticLatch:showStatus()
--- Method
--- Shows a detailed status alert
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:showStatus()
    local status = obj:getStatus()
    local message = string.format("🔧 KineticLatch Status 🔧\nEnabled: %s | Running: %s | State: %s",
        status.enabled and "YES" or "NO",
        status.running and "YES" or "NO",
        status.kineticState)

    if status.currentWindow then
        message = message .. "\nActive: " .. status.currentWindow
    end

    hs.alert.show(message, 4)
    return self
end

--- KineticLatch:diagnose()
--- Method
--- Runs diagnostic tests on the kinetic system
---
--- Parameters:
---  * None
---
--- Returns:
---  * The KineticLatch object
function obj:diagnose()
    obj.logger.i('🔬 Running KineticLatch diagnostics...')

    local mousePos = hs.mouse.absolutePosition()
    obj.logger.i('Kinetic cursor position:', mousePos.x, mousePos.y)

    local window = getWindowUnderCursor(mousePos)
    if window then
        obj.logger.i('Window under kinetic cursor:', window:title())
    else
        obj.logger.w('No window detected under kinetic cursor')
    end

    obj.logger.i('Kinetic event tap status - Drag:', obj.dragTap and 'ACTIVE' or 'INACTIVE')
    obj.logger.i('Kinetic event tap status - Flags:', obj.flagsTap and 'ACTIVE' or 'INACTIVE')

    hs.alert.show("🔬 KineticLatch diagnostics complete!\nCheck console for details.", 3)
    return self
end

-- Auto-start if configured
if obj.defaultConfig.autoStart then
    obj:init()
    -- Note: We don't auto-start here, let the user decide when to engage
end

return obj
