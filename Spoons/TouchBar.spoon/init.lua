--- === TouchBar ===
---
--- Real TouchBar control for MacBooks with physical TouchBar hardware
--- Uses hs._asm.undocumented.touchbar extension for native TouchBar manipulation
---
--- Download: [GitHub Releases](https://github.com/user/TouchBar/releases)
---
--- @author Hammerspoon Community
--- @license MIT - https://opensource.org/licenses/MIT

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "TouchBar"
obj.version = "1.0.0"
obj.author = "Hammerspoon Community"
obj.homepage = "https://github.com/user/TouchBar"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- TouchBar.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('TouchBar')

-- Internal variables
obj._touchbar = nil
obj._bar = nil
obj._appProfiles = {}
obj._defaultItems = {}
obj._appWatcher = nil
obj._initialized = false

--- TouchBar:init()
--- Method
--- Initializes the TouchBar spoon
---
--- Returns:
---  * The TouchBar object
function obj:init()
    self.logger.i("Initializing TouchBar spoon")
    
    -- Check if TouchBar extension is available
    local success, touchbar = pcall(require, "hs._asm.undocumented.touchbar")
    if not success then
        self.logger.e("TouchBar extension not found. Please install hs._asm.undocumented.touchbar")
        return self
    end
    
    self._touchbar = touchbar
    
    -- Check if machine supports TouchBar
    if not self._touchbar.supported() then
        self.logger.w("TouchBar not supported on this machine")
        return self
    end
    
    -- Check if machine has physical TouchBar
    if not self._touchbar.physical() then
        self.logger.w("No physical TouchBar detected. Consider using CustomControlBar.spoon instead")
        return self
    end
    
    self.logger.i("TouchBar support detected and available")
    return self
end

--- TouchBar:start()
--- Method
--- Starts the TouchBar, creating the bar and setting up watchers
---
--- Returns:
---  * The TouchBar object
function obj:start()
    if not self._touchbar then
        self.logger.e("TouchBar extension not available - cannot start")
        return self
    end
    
    self.logger.i("Starting TouchBar")
    
    self:_createDefaultBar()
    self:_setupAppWatcher()
    
    self._initialized = true
    return self
end

--- TouchBar:stop()
--- Method
--- Stops the TouchBar, cleaning up bars and watchers
---
--- Returns:
---  * The TouchBar object
function obj:stop()
    self.logger.i("Stopping TouchBar")
    
    if self._bar then
        -- Note: Based on the GitHub issue discussion, proper cleanup can be tricky
        -- We'll attempt basic cleanup but avoid operations that might crash
        pcall(function()
            if self._bar.dismiss then
                self._bar:dismiss()
            end
        end)
        self._bar = nil
    end
    
    if self._appWatcher then
        self._appWatcher:stop()
        self._appWatcher = nil
    end
    
    self._initialized = false
    return self
end

--- TouchBar:addAppProfile(bundleID, profile)
--- Method
--- Adds or updates an application profile with custom TouchBar items
---
--- Parameters:
---  * bundleID - String: The application bundle identifier (e.g., "com.apple.Safari")
---  * profile - Table: Profile configuration with TouchBar items
---
--- Returns:
---  * The TouchBar object
---
--- Example:
--- ```lua
--- spoon.TouchBar:addAppProfile("com.apple.Safari", {
---     items = {
---         {id = "back", title = "←", callback = function() hs.eventtap.keyStroke({"cmd"}, "[") end},
---         {id = "forward", title = "→", callback = function() hs.eventtap.keyStroke({"cmd"}, "]") end},
---         {id = "reload", title = "⟳", callback = function() hs.eventtap.keyStroke({"cmd"}, "r") end}
---     }
--- })
--- ```
function obj:addAppProfile(bundleID, profile)
    self.logger.i("Adding TouchBar profile for: " .. bundleID)
    self._appProfiles[bundleID] = profile
    
    -- Update TouchBar if this is the current app
    if self._initialized then
        local currentApp = hs.application.frontmostApplication()
        if currentApp and currentApp:bundleID() == bundleID then
            self:_updateTouchBar()
        end
    end
    
    return self
end

--- TouchBar:setDefaultItems(items)
--- Method
--- Sets the default TouchBar items to show when no app profile is active
---
--- Parameters:
---  * items - Table: Array of item configurations
---
--- Returns:
---  * The TouchBar object
function obj:setDefaultItems(items)
    self.logger.i("Setting default TouchBar items")
    self._defaultItems = items or {}
    
    if self._initialized then
        self:_updateTouchBar()
    end
    
    return self
end

-- Internal methods

function obj:_createDefaultBar()
    if not self._touchbar or not self._touchbar.bar then
        self.logger.e("TouchBar bar module not available")
        return
    end
    
    -- Create default items if none specified
    if #self._defaultItems == 0 then
        self._defaultItems = {
            {id = "time", title = os.date("%H:%M"), color = "white"},
            {id = "volume", title = "🔊", callback = function() 
                local device = hs.audiodevice.defaultOutputDevice()
                if device then
                    device:setMuted(not device:muted())
                end
            end},
            {id = "reload", title = "⟳", callback = function() 
                hs.reload() 
            end}
        }
    end
    
    -- Create the bar
    pcall(function()
        self._bar = self._touchbar.bar.new()
        self:_populateBar(self._defaultItems)
    end)
end

function obj:_populateBar(items)
    if not self._bar or not self._touchbar.item then
        return
    end
    
    local touchBarItems = {}
    local itemIdentifiers = {}
    
    for _, itemConfig in ipairs(items) do
        local identifier = itemConfig.id or ("item_" .. #touchBarItems + 1)
        table.insert(itemIdentifiers, identifier)
        
        pcall(function()
            local item = self._touchbar.item.newButton(identifier, itemConfig.title or "Button")
            
            if itemConfig.callback then
                item:callback(itemConfig.callback)
            end
            
            if itemConfig.color then
                -- Set color if supported
                pcall(function()
                    item:textColor(itemConfig.color)
                end)
            end
            
            touchBarItems[identifier] = item
        end)
    end
    
    -- Set the items on the bar
    pcall(function()
        if #itemIdentifiers > 0 then
            self._bar:templateItems(touchBarItems)
            self._bar:defaultIdentifiers(itemIdentifiers)
            self._bar:customizableIdentifiers(itemIdentifiers)
            
            -- Present the bar
            if self._bar.presentSystemModalFunctionBar then
                self._bar:presentSystemModalFunctionBar(false) -- false = don't escape
            end
        end
    end)
end

function obj:_setupAppWatcher()
    self._appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if eventType == hs.application.watcher.activated then
            self:_updateTouchBar()
        end
    end)
    self._appWatcher:start()
end

function obj:_updateTouchBar()
    if not self._initialized or not self._bar then
        return
    end
    
    local currentApp = hs.application.frontmostApplication()
    local items = self._defaultItems
    
    if currentApp then
        local bundleID = currentApp:bundleID()
        local profile = self._appProfiles[bundleID]
        
        if profile and profile.items then
            items = profile.items
            self.logger.d("Using TouchBar profile for: " .. (appName or bundleID))
        end
    end
    
    self:_populateBar(items)
end

return obj 