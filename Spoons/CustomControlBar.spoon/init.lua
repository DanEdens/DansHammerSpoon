--- === CustomControlBar ===
---
--- A TouchBar-like control panel for Mac Pro and other Macs without TouchBar
--- Provides customizable floating control panels with context-aware buttons and widgets
---
--- Download: [GitHub Releases](https://github.com/user/CustomControlBar/releases)
--- 
--- @author Your Name <your.email@example.com>
--- @license MIT - https://opensource.org/licenses/MIT

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "CustomControlBar"
obj.version = "1.0.0"
obj.author = "Hammerspoon Community"
obj.homepage = "https://github.com/user/CustomControlBar"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- CustomControlBar.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('CustomControlBar')

--- CustomControlBar.position
--- Variable
--- Position of the control bar. Can be "top", "bottom", "left", "right", or a table with {x=, y=} coordinates
obj.position = "bottom"

--- CustomControlBar.size
--- Variable  
--- Size of the control bar as a table with {w=width, h=height}
obj.size = {w = 800, h = 60}

--- CustomControlBar.theme
--- Variable
--- Theme configuration table with colors and styling
obj.theme = {
    background = {red = 0.1, green = 0.1, blue = 0.1, alpha = 0.9},
    buttonNormal = {red = 0.3, green = 0.3, blue = 0.3, alpha = 1.0},
    buttonHover = {red = 0.5, green = 0.5, blue = 0.5, alpha = 1.0},
    buttonActive = {red = 0.7, green = 0.7, blue = 0.7, alpha = 1.0},
    text = {red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0},
    cornerRadius = 8
}

-- Internal variables
obj._canvas = nil
obj._appProfiles = {}
obj._globalControls = {}
obj._currentProfile = nil
obj._appWatcher = nil
obj._hotkey = nil
obj._visible = true

--- CustomControlBar:init()
--- Method
--- Initializes the CustomControlBar spoon
---
--- Returns:
---  * The CustomControlBar object
function obj:init()
    self.logger.i("Initializing CustomControlBar")
    
    -- Set up default global controls
    self._globalControls = {
        {
            type = "button",
            icon = "⏸",
            title = "Media",
            action = function() hs.spotify.playpause() end,
            tooltip = "Play/Pause Spotify"
        },
        {
            type = "button", 
            icon = "🔇",
            title = "Mute",
            action = function() 
                local device = hs.audiodevice.defaultOutputDevice()
                device:setMuted(not device:muted())
            end,
            tooltip = "Toggle Mute"
        },
        {
            type = "text",
            title = "Time",
            value = function() return os.date("%H:%M") end,
            tooltip = "Current Time"
        }
    }
    
    return self
end

--- CustomControlBar:start()  
--- Method
--- Starts the CustomControlBar, creating the UI and watchers
---
--- Returns:
---  * The CustomControlBar object
function obj:start()
    self.logger.i("Starting CustomControlBar")
    
    self:_createCanvas()
    self:_setupAppWatcher()
    self:_setupHotkey()
    self:_updateControls()
    
    return self
end

--- CustomControlBar:stop()
--- Method  
--- Stops the CustomControlBar, cleaning up UI and watchers
---
--- Returns:
---  * The CustomControlBar object
function obj:stop()
    self.logger.i("Stopping CustomControlBar")
    
    if self._canvas then
        self._canvas:delete()
        self._canvas = nil
    end
    
    if self._appWatcher then
        self._appWatcher:stop()
        self._appWatcher = nil
    end
    
    if self._hotkey then
        self._hotkey:delete()
        self._hotkey = nil
    end
    
    return self
end

--- CustomControlBar:toggle()
--- Method
--- Toggles the visibility of the control bar
---
--- Returns:
---  * The CustomControlBar object
function obj:toggle()
    if self._visible then
        self:hide()
    else
        self:show()
    end
    return self
end

--- CustomControlBar:show()
--- Method
--- Shows the control bar
---
--- Returns:
---  * The CustomControlBar object  
function obj:show()
    if self._canvas then
        self._canvas:show()
        self._visible = true
    end
    return self
end

--- CustomControlBar:hide()
--- Method
--- Hides the control bar
---
--- Returns:
---  * The CustomControlBar object
function obj:hide()
    if self._canvas then
        self._canvas:hide()
        self._visible = false
    end
    return self
end

--- CustomControlBar:addAppProfile(bundleID, profile)
--- Method
--- Adds or updates an application profile with custom controls
---
--- Parameters:
---  * bundleID - String: The application bundle identifier (e.g., "com.apple.Safari")
---  * profile - Table: Profile configuration with controls
---
--- Returns:
---  * The CustomControlBar object
---
--- Example:
--- ```lua
--- spoon.CustomControlBar:addAppProfile("com.apple.Safari", {
---     buttons = {
---         {icon = "⬅", action = "cmd+[", tooltip = "Back"},
---         {icon = "➡", action = "cmd+]", tooltip = "Forward"},
---         {icon = "🔄", action = "cmd+r", tooltip = "Reload"}
---     }
--- })
--- ```
function obj:addAppProfile(bundleID, profile)
    self.logger.i("Adding app profile for: " .. bundleID)
    self._appProfiles[bundleID] = profile
    
    -- Update controls if this is the current app
    local currentApp = hs.application.frontmostApplication()
    if currentApp and currentApp:bundleID() == bundleID then
        self:_updateControls()
    end
    
    return self
end

-- Internal methods

function obj:_createCanvas()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    
    -- Calculate position based on settings
    local x, y = self:_calculatePosition(screenFrame)
    
    self._canvas = hs.canvas.new({x = x, y = y, w = self.size.w, h = self.size.h})
    
    -- Background
    self._canvas:appendElements({
        type = "rectangle",
        fillColor = self.theme.background,
        strokeWidth = 0,
        roundedRectRadii = {xRadius = self.theme.cornerRadius, yRadius = self.theme.cornerRadius}
    })
    
    self._canvas:level(hs.canvas.windowLevels.floating)
    self._canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    self._canvas:clickActivating(false)
    
    return self._canvas
end

function obj:_calculatePosition(screenFrame)
    if type(self.position) == "table" then
        return self.position.x or 0, self.position.y or 0
    end
    
    local x, y
    
    if self.position == "bottom" then
        x = (screenFrame.w - self.size.w) / 2
        y = screenFrame.h - self.size.h - 10
    elseif self.position == "top" then
        x = (screenFrame.w - self.size.w) / 2  
        y = 30 -- Below menu bar
    elseif self.position == "left" then
        x = 10
        y = (screenFrame.h - self.size.h) / 2
    elseif self.position == "right" then
        x = screenFrame.w - self.size.w - 10
        y = (screenFrame.h - self.size.h) / 2
    else
        -- Default to bottom
        x = (screenFrame.w - self.size.w) / 2
        y = screenFrame.h - self.size.h - 10
    end
    
    return x, y
end

function obj:_setupAppWatcher()
    self._appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if eventType == hs.application.watcher.activated then
            self:_updateControls()
        end
    end)
    self._appWatcher:start()
end

function obj:_setupHotkey()
    -- Default hotkey: Cmd+Ctrl+T to toggle
    self._hotkey = hs.hotkey.bind({"cmd", "ctrl"}, "t", function()
        self:toggle()
    end)
end

function obj:_updateControls()
    if not self._canvas then return end
    
    -- Clear existing control elements (keep background)
    local elementCount = self._canvas:elementCount()
    for i = elementCount, 2, -1 do
        self._canvas:removeElement(i)
    end
    
    -- Get current app profile
    local currentApp = hs.application.frontmostApplication()
    local profile = nil
    
    if currentApp then
        local bundleID = currentApp:bundleID()
        profile = self._appProfiles[bundleID]
        self._currentProfile = profile
    end
    
    -- Combine global controls with app-specific controls
    local controls = {}
    
    -- Add global controls first
    for _, control in ipairs(self._globalControls) do
        table.insert(controls, control)
    end
    
    -- Add app-specific controls
    if profile and profile.buttons then
        for _, button in ipairs(profile.buttons) do
            table.insert(controls, button)
        end
    end
    
    -- Render controls
    self:_renderControls(controls)
    
    if self._visible then
        self._canvas:show()
    end
end

function obj:_renderControls(controls)
    local padding = 10
    local buttonWidth = 60
    local buttonHeight = 40
    local spacing = 5
    local x = padding
    local y = (self.size.h - buttonHeight) / 2
    
    for i, control in ipairs(controls) do
        if control.type == "button" or not control.type then
            self:_renderButton(control, x, y, buttonWidth, buttonHeight, i)
        elseif control.type == "text" then
            self:_renderText(control, x, y, buttonWidth, buttonHeight)
        end
        
        x = x + buttonWidth + spacing
        
        -- Wrap to next row if needed (future enhancement)
        if x + buttonWidth > self.size.w - padding then
            break
        end
    end
end

function obj:_renderButton(button, x, y, width, height, index)
    -- Button background
    self._canvas:appendElements({
        type = "rectangle",
        frame = {x = x, y = y, w = width, h = height},
        fillColor = self.theme.buttonNormal,
        strokeWidth = 1,
        strokeColor = self.theme.text,
        roundedRectRadii = {xRadius = 4, yRadius = 4},
        trackMouseUp = true,
        id = "button_" .. index
    })
    
    -- Button icon/text
    local displayText = button.icon or button.title or "?"
    self._canvas:appendElements({
        type = "text",
        frame = {x = x, y = y, w = width, h = height},
        text = displayText,
        textAlignment = "center",
        textColor = self.theme.text,
        textSize = 16,
        id = "text_" .. index
    })
    
    -- Set up click handler
    self._canvas:mouseCallback(function(canvas, message, id, x, y)
        if message == "mouseUp" and id == "button_" .. index then
            self:_executeAction(button.action)
        end
    end)
end

function obj:_renderText(textControl, x, y, width, height)
    local value = textControl.value
    if type(value) == "function" then
        value = value()
    end
    
    self._canvas:appendElements({
        type = "text",
        frame = {x = x, y = y, w = width, h = height},
        text = tostring(value),
        textAlignment = "center", 
        textColor = self.theme.text,
        textSize = 12
    })
end

function obj:_executeAction(action)
    if type(action) == "function" then
        action()
    elseif type(action) == "string" then
        -- Parse keyboard shortcut
        self:_sendKeystroke(action)
    end
end

function obj:_sendKeystroke(keystroke)
    -- Parse keystroke like "cmd+r" into modifiers and key
    local parts = {}
    for part in keystroke:gmatch("[^+]+") do
        table.insert(parts, part)
    end
    
    if #parts < 2 then return end
    
    local key = parts[#parts]
    local modifiers = {}
    for i = 1, #parts - 1 do
        table.insert(modifiers, parts[i])
    end
    
    hs.eventtap.keyStroke(modifiers, key)
end

return obj 