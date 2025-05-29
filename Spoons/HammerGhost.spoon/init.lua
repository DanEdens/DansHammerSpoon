--- === HammerGhost ===
---
--- EventGhost-like macro editor for Hammerspoon
---
--- Features:
--- * Tree-based macro organization
--- * Visual macro editor
--- * Support for actions, sequences, and folders
--- * Dark theme matching EventGhost
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HammerGhost.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/HammerGhost.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HammerGhost"
obj.version = "1.1"
obj.author = "Dan Edens"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Load additional modules using dofile instead of require
local xmlparser = dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))
local config = dofile(hs.spoons.resourcePath("scripts/config.lua"))
local ui = dofile(hs.spoons.resourcePath("scripts/ui.lua"))
local treeHelpers = dofile(hs.spoons.resourcePath("scripts/tree_helpers.lua"))

-- Ensure config is initialized before use
if not config then
    hs.alert.show("HammerGhost: Failed to load config module")
    return
end

-- Initialize modules with dependencies
config = config.init({ xmlparser = xmlparser })
ui = ui.init({ xmlparser = xmlparser })

-- Internal variables
obj.window = nil
obj.webview = nil
obj.toolbar = nil
obj.configPath = hs.configdir .. "/hammerghost_config.xml"
obj.macroTree = {}
obj.currentSelection = nil
obj.lastId = 0

-- Initialize the spoon
function obj:init()
    -- Create a logger for better debugging
    local HyperLogger = require('HyperLogger')
    self.logger = HyperLogger.new()
    self.logger:setLogLevel('debug')
    self.logger:i("Initializing HammerGhost")

    -- Check resources first
    if not self:checkResources() then
        hs.alert.show("HammerGhost: Missing required resources")
        return self
    end

    -- Initialize URL event handling for JavaScript-to-Lua communication
    hs.urlevent.setCallback(function(scheme, host, params, fullURL)
        self.logger:d("URL event received: " .. tostring(fullURL))
        -- The navigation callback in the webview will handle the actual processing
    end)

    -- Register the hammerspoon URL scheme
    hs.urlevent.setDefaultHandler("hammerspoon")
    -- Load saved macros if they exist
    self.macroTree, self.lastId = config.loadMacros(self.configPath) -- Use config module

    -- Check if the loaded configuration is empty or nil
    if not self.macroTree or #self.macroTree == 0 then
        -- Set up a default configuration
        self.macroTree = {
            {
                id = "1",
                name = "Default Macro",
                type = "action",
                expanded = false,
                tag = "macro", -- Ensure the tag matches expected structure
                children = {}, -- Include children if necessary
                fn = function() hs.alert.show("Default Action Triggered") end,
                attributes = { -- Add attributes if needed
                    id = "1",
                    name = "Default Macro",
                    type = "action"
                }
            }
        }
        self.lastId = 1
        config.saveMacros(self.configPath, self.macroTree) -- Save the default configuration
    end

    -- Initialize UI
    self:createMainWindow()

    return self
end

-- Create the main window
function obj:createMainWindow()
    self.window = ui.createMainWindow(self)
    if self.window then
        self.window:show()
    else
        hs.logger.new("HammerGhost"):e("Failed to create main window")
    end
end

-- Function to check required resources
function obj:checkResources()
    local resources = {
        "scripts/xmlparser.lua",
        "scripts/action_system.lua",
        "scripts/action_manager.lua",
        "assets/index.html",
        "assets/action_editor.html"
    }

    for _, resource in ipairs(resources) do
        local path = hs.spoons.resourcePath(resource)
        if not hs.fs.attributes(path) then
            hs.logger.new("HammerGhost"):e("Missing required resource: " .. resource)
            return false
        end
    end

    return true
end

-- Function to toggle the main window
function obj:toggle()
    if not self.window then
        self:createMainWindow()
    else
        if self.window:isVisible() then
            self.window:hide()
        else
            self.window:show()
        end
    end
end

-- Bind hotkeys for the spoon
function obj:bindHotkeys(mapping)
    local spec = {
        toggle = hs.fnutils.partial(self.toggle, self)
        -- Add other hotkey bindings if necessary
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

-- Function to select an item
function obj:selectItem(id)
    self.currentSelection = treeHelpers.findItem(self.macroTree, id)
    self:refreshWindow()
end

-- Function to configure an item (alias for editItem for consistency)
function obj:configureItem(id)
    return self:editItem(id)
end

-- Function to move an item to a new position
function obj:moveItem(sourceId, targetId, position)
    local sourceItem = treeHelpers.findItem(self.macroTree, sourceId)
    local targetItem = treeHelpers.findItem(self.macroTree, targetId)

    if not sourceItem or not targetItem or sourceId == targetId then
        return false
    end

    -- Remove source item from its current location
    local function removeFromParent(items, itemId)
        for i, item in ipairs(items) do
            if item.id == itemId then
                table.remove(items, i)
                return true
            end
            if item.children and removeFromParent(item.children, itemId) then
                return true
            end
        end
        return false
    end

    -- Find target parent and position
    local function findParentAndPosition(items, targetId)
        for i, item in ipairs(items) do
            if item.id == targetId then
                return items, i
            end
            if item.children then
                local parent, pos = findParentAndPosition(item.children, targetId)
                if parent then return parent, pos end
            end
        end
        return nil, nil
    end

    -- Remove source from current location
    removeFromParent(self.macroTree, sourceId)

    -- Insert in new location
    if position == "before" then
        local parent, pos = findParentAndPosition(self.macroTree, targetId)
        if parent then
            table.insert(parent, pos, sourceItem)
        end
    elseif position == "after" then
        local parent, pos = findParentAndPosition(self.macroTree, targetId)
        if parent then
            table.insert(parent, pos + 1, sourceItem)
        end
    elseif position == "inside" then
        if not targetItem.children then
            targetItem.children = {}
        end
        table.insert(targetItem.children, sourceItem)
    end

    self:saveConfig()
    self:refreshWindow()
    return true
end

-- Function to show context menu for an item
function obj:showContextMenu(id)
    local item = treeHelpers.findItem(self.macroTree, id)
    if not item then return end

    local menu = hs.menubar.new()
    menu:setMenu({
        { title = "Edit",   fn = function() self:editItem(id) end },
        { title = "Delete", fn = function() self:deleteItem(id) end },
        { title = "-" },
        {
            title = "Add Folder",
            fn = function()
                self.currentSelection = item
                self:addFolder()
            end
        },
        {
            title = "Add Action",
            fn = function()
                self.currentSelection = item
                self:addAction()
            end
        },
        {
            title = "Add Sequence",
            fn = function()
                self.currentSelection = item
                self:addSequence()
            end
        }
    })
    menu:popupMenu(hs.mouse.absolutePosition())

    -- Auto-hide menu after a delay
    hs.timer.doAfter(0.1, function()
        menu:delete()
    end)
end

-- Function to cancel editing
function obj:cancelEdit()
    if self.window then
        -- Clear properties panel
        self.window:evaluateJavaScript([[
            document.getElementById('properties-panel').innerHTML = '';
        ]])
    end
end

-- Function to test URL handling
function obj:testURLHandling()
    -- Create a test item if none exists
    if #self.macroTree == 0 then
        self:createMacroItem("Test Item", "action", nil)
    end

    -- Get the first item ID
    local testId = self.macroTree[1].id

    -- Generate test URL
    local testURL = "hammerspoon://selectItem?" .. testId
    self.logger:i("Testing URL handling with: " .. testURL)

    -- Execute the URL to test handling
    hs.execute("open '" .. testURL .. "'")

    return testURL
end
-- Function to refresh the window content
function obj:refreshWindow()
    if not self.window then return end

    -- Generate HTML for the macro tree
    local html = ""
    for _, item in ipairs(self.macroTree) do
        html = html .. treeHelpers.itemToHTML(item, 0, self.currentSelection)
    end

    -- Insert the HTML into the webview
    self.window:html(html)
end

-- Function to add a new folder
function obj:addFolder()
    local name = "New Folder"
    self:createMacroItem(name, "folder", self:getCurrentSelection())

    -- Refresh the UI
    self:refreshWindow()
end

-- Function to add a new action
function obj:addAction()
    local name = "New Action"
    self:createMacroItem(name, "action", self:getCurrentSelection())

    -- Refresh the UI
    self:refreshWindow()
end

-- Function to create a new macro item
function obj:createMacroItem(name, type, parent)
    self.lastId = self.lastId + 1
    local item = {
        id = tostring(self.lastId),
        name = name,
        type = type,
        expanded = false,
        children = (type ~= "action") and {} or nil,
        tag = type
    }

    if type == "action" then
        item.fn = function()
            hs.alert.show("Action: " .. name)
        end
    elseif type == "sequence" then
        item.steps = {}
    elseif type == "folder" then
        item.children = {}
    end

    if parent then
        if not parent.children then
            parent.children = {}
        end
        table.insert(parent.children, item)
    else
        table.insert(self.macroTree, item)
    end

    -- Save the updated macros
    config.saveMacros(self.configPath, self.macroTree)

    return item
end

-- Function to get the current selection
function obj:getCurrentSelection()
    return self.currentSelection
end

-- Function to add a sequence
function obj:addSequence()
    local name = "New Sequence"
    self:createMacroItem(name, "sequence", self:getCurrentSelection())
    self:refreshWindow()
end

-- Function to save configuration
function obj:saveConfig()
    config.saveMacros(self.configPath, self.macroTree)
    ui.showError(self, "Configuration saved")
end

-- Function to reload configuration
function obj:reloadConfig()
    self.macroTree, self.lastId = config.loadMacros(self.configPath)
    self:refreshWindow()
    ui.showError(self, "Configuration reloaded")
end

-- Function to toggle item expansion
function obj:toggleItem(id)
    local item = treeHelpers.findItem(self.macroTree, id)
    if item and item.children then
        item.expanded = not item.expanded
        ui.toggleItemExpansion(self, id)
    end
end

-- Function to edit item
function obj:editItem(id)
    local item = treeHelpers.findItem(self.macroTree, id)
    if item then
        self.currentSelection = item
        ui.showProperties(self, item)
    end
end

-- Function to delete item
function obj:deleteItem(id)
    local function removeItem(items, targetId)
        for i, item in ipairs(items) do
            if item.id == targetId then
                table.remove(items, i)
                return true
            end
            if item.children then
                if removeItem(item.children, targetId) then
                    return true
                end
            end
        end
        return false
    end

    if removeItem(self.macroTree, id) then
        self:saveConfig()
        self:refreshWindow()
    end
end

-- Function to save properties
function obj:saveProperties(data)
    local item = treeHelpers.findItem(self.macroTree, data.id)
    if item then
        item.name = data.name
        item.type = data.type

        -- Update type-specific properties
        if data.attributes then
            for key, value in pairs(data.attributes) do
                item[key] = value
            end
        end

        self:saveConfig()
        self:refreshWindow()
    end
end

-- Return the spoon object
return obj
