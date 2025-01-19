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
obj.version = "1.0"
obj.author = "Dan Edens"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Load additional modules
local xmlparser = dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))
local config = dofile(hs.spoons.resourcePath("scripts/config.lua"))
local ui = dofile(hs.spoons.resourcePath("scripts/ui.lua"))

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
obj.spoonPath = hs.spoons.scriptPath()

-- Load additional modules
dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))

-- Helper function to generate unique IDs
function obj:generateId()
    self.lastId = self.lastId + 1
    return tostring(self.lastId)
end

--- HammerGhost:init()
--- Method
--- Initialize the spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The HammerGhost object
function obj:init()
    -- Check resources first
    if not self:checkResources() then
        hs.alert.show("HammerGhost: Missing required resources")
        return self
    end

    -- Load saved macros if they exist
    self.macroTree, self.lastId = config.loadMacros(self.configPath)  -- Use config module

    -- Before loading the UI
    hs.logger.new("HammerGhost"):d("Loading UI...")

    -- Load the UI
    local success, err = pcall(function() ui.createMainWindow(self) end)
    if not success then
        hs.logger.new("HammerGhost"):e("Error loading UI: " .. err)
    end

    return self
end

--- HammerGhost:start()
--- Method
--- Start HammerGhost and show the main window
---
--- Parameters:
---  * None
---
--- Returns:
---  * The HammerGhost object

function obj:start()
    if not self.window then
        self:createMainWindow()
    end
    if self.window and self.window:_window() then
        self.window:_window():show()
    end
    return self
end

--- HammerGhost:stop()
--- Method
--- Stop HammerGhost and hide the main window
---
--- Parameters:
---  * None
---
--- Returns:
---  * The HammerGhost object
function obj:stop()
    if self.window then
        self:saveConfig()
        self.window:hide()
    end
    return self
end

--- HammerGhost:toggle()
--- Method
--- Toggle the HammerGhost window visibility
---
--- Parameters:
---  * None
---
--- Returns:
---  * The HammerGhost object
function obj:toggle()
    if not self.window then
        self:start()
    else
        if self.window:_window() and self.window:_window():isVisible() then
            self:stop()
        else
            self:start()
        end
    end
    return self
end

--- HammerGhost:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for HammerGhost
---
--- Parameters:
---  * mapping - A table containing hotkey details for the following items:
---   * toggle - Toggle the HammerGhost window
---   * addAction - Add a new action
---   * addSequence - Add a new sequence
---   * addFolder - Add a new folder
---
--- Returns:
---  * The HammerGhost object
function obj:bindHotkeys(mapping)
    local spec = {
        toggle = hs.fnutils.partial(self.toggle, self),
        addAction = hs.fnutils.partial(self.addAction, self),
        addSequence = hs.fnutils.partial(self.addSequence, self),
        addFolder = hs.fnutils.partial(self.addFolder, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

--- HammerGhost:createMainWindow()
--- Method
--- Creates the main HammerGhost window
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:createMainWindow()
    ui.createMainWindow(self)  -- Use UI module
end

--- HammerGhost:createToolbar()
--- Method
--- Creates the toolbar for the main window
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:createToolbar()
    -- Define toolbar items with system icons
    local toolbar = hs.webview.toolbar.new("HammerGhostToolbar", {
        {
            id = "addFolder",
            label = "New Folder",
            image = hs.image.imageFromName("NSFolderSmartTemplate"),
            fn = function() self:addFolder() end
        },
        {
            id = "addAction",
            label = "New Action",
            image = hs.image.imageFromName("NSActionTemplate"),
            fn = function() self:addAction() end
        },
        {
            id = "addSequence",
            label = "New Sequence",
            image = hs.image.imageFromName("NSListViewTemplate"),
            fn = function() self:addSequence() end
        },
        {
            id = "save",
            label = "Save",
            image = hs.image.imageFromName("NSSaveTemplate"),
            fn = function() self:saveConfig() end
        }
    })

    -- Apply the toolbar to the window
    if self.window then
        self.window:attachedToolbar(toolbar)
    end

    -- Store the toolbar reference
    self.toolbar = toolbar
end

--- HammerGhost:selectItem(index)
--- Method
--- Handle item selection in the tree view
---
--- Parameters:
---  * index - The index of the selected item
---
--- Returns:
---  * None
function obj:selectItem(index)
    -- TODO: Implement item selection and property panel update
    hs.logger.new("HammerGhost"):d("Selected item: " .. tostring(index))
end

--- HammerGhost:toggleItem(index)
--- Method
--- Toggle expansion state of an item
---
--- Parameters:
---  * index - The index of the item to toggle
---
--- Returns:
---  * None
function obj:toggleItem(index)
    -- TODO: Implement item expansion/collapse
    hs.logger.new("HammerGhost"):d("Toggled item: " .. tostring(index))
end

--- HammerGhost:editItem(index)
--- Method
--- Edit an item in the tree
---
--- Parameters:
---  * index - The index of the item to edit
---
--- Returns:
---  * None
function obj:editItem(index)
    -- TODO: Implement item editing
    hs.logger.new("HammerGhost"):d("Editing item: " .. tostring(index))
end

--- HammerGhost:deleteItem(index)
--- Method
--- Delete an item from the tree
---
--- Parameters:
---  * index - The index of the item to delete
---
--- Returns:
---  * None
function obj:deleteItem(index)
    -- TODO: Implement item deletion
    hs.logger.new("HammerGhost"):d("Deleting item: " .. tostring(index))
end

--- HammerGhost:addFolder()
--- Method
--- Add a new folder to the tree
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:addFolder()
    local name = "New Folder"
    self:createMacroItem(name, "folder", self:getCurrentSelection())
end

--- HammerGhost:addAction()
--- Method
--- Add a new action to the tree
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:addAction()
    local name = "New Action"
    self:createMacroItem(name, "action", self:getCurrentSelection())
end

--- HammerGhost:addSequence()
--- Method
--- Add a new sequence to the tree
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:addSequence()
    local name = "New Sequence"
    self:createMacroItem(name, "sequence", self:getCurrentSelection())
end

--- HammerGhost:getCurrentSelection()
--- Method
--- Get the current selection
---
--- Parameters:
---  * None
---
--- Returns:
---  * The current selection
function obj:getCurrentSelection()
    -- TODO: Implement selection tracking
    return nil
end

--- HammerGhost:refreshWindow()
--- Method
--- Refresh the window content
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:refreshWindow()
    if not self.window then return end

    -- Generate HTML for the macro tree
    local html = self:generateTreeHTML()
    self.window:html(html)
end

--- HammerGhost:generateTreeHTML()
--- Method
--- Generate HTML for the macro tree
---
--- Parameters:
---  * None
---
--- Returns:
---  * The generated HTML
function obj:generateTreeHTML()
    local function itemToHTML(item, level)
        local indentStyle = string.format("padding-left: %dpx;", level * 20)
        local selectedClass = item.id == self.currentSelection and "selected" or ""
        local icon = item.type == "folder" and "📁" or (item.type == "sequence" and "📋" or "⚡")
        
        return string.format([[
            <div class="item %s" data-id="%s" data-type="%s" style="%s" draggable="true" ondragstart="handleDragStart(event)" ondragover="handleDragOver(event)" ondrop="handleDrop(event)">
                <span class="icon" onclick="toggleItem('%s', event)">%s</span>
                <span class="name">%s</span>
                <div class="actions">
                    <button class="edit" onclick="editItem('%s', '%s', event)" title="Edit">✏️</button>
                    <button class="delete" onclick="deleteItem('%s', '%s', event)" title="Delete">🗑️</button>
                </div>
                <div class="drop-indicator"></div>
            </div>
        ]], selectedClass, item.id, item.type, indentStyle, item.id, icon, item.name,
            item.id, item.name:gsub("'", "\\'"), item.id, item.name:gsub("'", "\\'"))
    end

    local treeContent = [[<div id="tree-panel">]]

    for _, item in ipairs(self.macroTree) do
        treeContent = treeContent .. itemToHTML(item, 0)
    end

    treeContent = treeContent .. [[</div><div id="properties-panel">]]

    -- Add properties panel content if an item is selected
    if self.currentSelection then
        local propertiesHtml = [[<div class="properties-form">]]

        -- Common properties for all types
        propertiesHtml = propertiesHtml .. string.format([[
            <div class="form-group">
                <label>Name</label>
                <input type="text" value="%s" onchange="updateProperty('%s', 'name', this.value)">
            </div>
            <div class="form-group">
                <label>Type</label>
                <input type="text" value="%s" readonly>
            </div>
        ]], self.currentSelection.name, self.currentSelection.id, self.currentSelection.type)

        -- Type-specific properties
        if self.currentSelection.type == "action" then
            propertiesHtml = propertiesHtml .. string.format([[
                <div class="form-group">
                    <label>Shortcut</label>
                    <input type="text" value="%s" onchange="updateProperty('%s', 'shortcut', this.value)" placeholder="e.g. cmd+alt+ctrl+A">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea onchange="updateProperty('%s', 'description', this.value)">%s</textarea>
                </div>
            ]], self.currentSelection.shortcut or "", self.currentSelection.id,
                self.currentSelection.id, self.currentSelection.description or "")

        elseif self.currentSelection.type == "sequence" then
            propertiesHtml = propertiesHtml .. string.format([[
                <div class="form-group">
                    <label>Delay Between Steps (ms)</label>
                    <input type="number" value="%s" onchange="updateProperty('%s', 'delay', this.value)" min="0">
                </div>
                <div class="form-group">
                    <label>Run in Background</label>
                    <input type="checkbox" %s onchange="updateProperty('%s', 'background', this.checked)">
                </div>
            ]], self.currentSelection.delay or "0", self.currentSelection.id,
                self.currentSelection.background and "checked" or "", self.currentSelection.id)
        end

        propertiesHtml = propertiesHtml .. [[</div>]]
        treeContent = treeContent .. propertiesHtml
    end

    treeContent = treeContent .. [[</div>]]

    return treeContent
end

--- HammerGhost:saveConfig()
--- Method
--- Save the current configuration to XML
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:saveConfig()
    config.saveMacros(self.configPath, self.macroTree)  -- Use config module
    hs.alert.show("Configuration saved")
end

--- HammerGhost:checkResources()
--- Method
--- Ensure all required resources are available
---
--- Parameters:
---  * None
---
--- Returns:
---  * True if all resources are available, false otherwise
function obj:checkResources()
    local resources = {
        "scripts/xmlparser.lua",
        "assets/index.html"
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

--- HammerGhost:createMacroItem(name, type, parent)
--- Method
--- Create a new macro item (folder, action, or sequence)
---
--- Parameters:
---  * name - The name of the item
---  * type - The type of item ("folder", "action", or "sequence")
---  * parent - Optional parent item to add this item to
---
--- Returns:
---  * The created item
function obj:createMacroItem(name, type, parent)
    local item = {
        id = self:generateId(),
        name = name,
        type = type,
        expanded = false,
        children = (type ~= "action") and {} or nil
    }

    if type == "action" then
        item.fn = function()
            hs.alert.show("Action: " .. name)
        end
    elseif type == "sequence" then
        item.steps = {}
    end

    if parent then
        table.insert(parent.children, item)
    else
        table.insert(self.macroTree, item)
    end

    -- Refresh the window to show the new item
    self:refreshWindow()
    return item
end

--- HammerGhost:getCurrentSelection()
--- Method
--- Get the currently selected item
---
--- Parameters:
---  * None
---
--- Returns:
---  * The selected item or nil
function obj:getCurrentSelection()
    return self.currentSelection
end

--- HammerGhost:selectItem(id)
--- Method
--- Select an item in the tree
---
--- Parameters:
---  * id - The ID of the item to select
---
--- Returns:
---  * None
function obj:selectItem(id)
    local function findItem(items)
        for _, item in ipairs(items) do
            if item.id == id then
                return item
            end
            if item.children then
                local found = findItem(item.children)
                if found then return found end
            end
        end
        return nil
    end

    self.currentSelection = findItem(self.macroTree)
    self:refreshWindow()
end

--- HammerGhost:toggleItem(id)
--- Method
--- Toggle the expanded state of an item
---
--- Parameters:
---  * id - The ID of the item to toggle
---
--- Returns:
---  * None
function obj:toggleItem(id)
    local function findAndToggle(items)
        for _, item in ipairs(items) do
            if item.id == id and item.children then
                item.expanded = not item.expanded
                return true
            end
            if item.children then
                if findAndToggle(item.children) then
                    return true
                end
            end
        end
        return false
    end

    if findAndToggle(self.macroTree) then
        self:refreshWindow()
    end
end

--- HammerGhost:editItem(data)
--- Method
--- Edit an item in the tree
---
--- Parameters:
---  * data - The data of the item to edit
---
--- Returns:
---  * None
function obj:editItem(data)
    local success, data = pcall(hs.json.decode, data)
    if not success then
        hs.logger.new("HammerGhost"):e("Failed to decode edit data")
        return
    end

    local function updateItem(items)
        for i, item in ipairs(items) do
            if item.id == data.id then
                item.name = data.name
                return true
            end
            if item.children then
                if updateItem(item.children) then
                    return true
                end
            end
        end
        return false
    end

    if updateItem(self.macroTree) then
        self:refreshWindow()
        self:saveConfig()
    end
end

--- HammerGhost:deleteItem(id)
--- Method
--- Delete an item from the tree
---
--- Parameters:
---  * id - The ID of the item to delete
---
--- Returns:
---  * None
function obj:deleteItem(id)
    local function removeItem(items)
        for i, item in ipairs(items) do
            if item.id == id then
                table.remove(items, i)
                return true
            end
            if item.children then
                if removeItem(item.children) then
                    return true
                end
            end
        end
        return false
    end

    if removeItem(self.macroTree) then
        if self.currentSelection and self.currentSelection.id == id then
            self.currentSelection = nil
        end
        self:refreshWindow()
        self:saveConfig()
    end
end

--- HammerGhost:updateProperty(data)
--- Method
--- Update a property of an item
---
--- Parameters:
---  * data - The data containing the item ID, property name, and new value
---
--- Returns:
---  * None
function obj:updateProperty(data)
    if not data or not data.id or not data.property or data.value == nil then
        hs.logger.new("HammerGhost"):e("Invalid property update data")
        return
    end

    local function findItem(id)
        local function search(items)
            for _, item in ipairs(items) do
                if item.id == id then
                    return item
                end
                if item.children then
                    local found = search(item.children)
                    if found then return found end
                end
            end
            return nil
        end
        return search(self.macroTree)
    end

    local item = findItem(data.id)
    if item then
        -- Update the property
        item[data.property] = data.value

        -- Special handling for certain properties
        if data.property == "shortcut" and item.type == "action" then
            -- Update the hotkey if it exists
            if item.hotkey then
                item.hotkey:delete()
            end
            if data.value and data.value ~= "" then
                item.hotkey = hs.hotkey.new(data.value, function()
                    if item.fn then item.fn() end
                end)
                item.hotkey:enable()
            end
        end

        self:refreshWindow()
        self:saveConfig()
    else
        hs.logger.new("HammerGhost"):e("Could not find item with id: " .. data.id)
    end
end

--- HammerGhost:moveItem(data)
--- Method
--- Move an item to a new position in the tree
---
--- Parameters:
---  * data - Table containing sourceId, targetId, and position
---
--- Returns:
---  * None
function obj:moveItem(data)
    if not data or not data.sourceId or not data.targetId or not data.position then
        hs.logger.new("HammerGhost"):e("Invalid move data")
        return
    end

    local function findAndRemoveItem(items, id)
        for i, item in ipairs(items) do
            if item.id == id then
                return table.remove(items, i)
            end
            if item.children then
                local found = findAndRemoveItem(item.children, id)
                if found then return found end
            end
        end
        return nil
    end

    local function findParentAndIndex(items, id)
        for i, item in ipairs(items) do
            if item.id == id then
                return items, i
            end
            if item.children then
                local parent, index = findParentAndIndex(item.children, id)
                if parent then return parent, index end
            end
        end
        return nil, nil
    end

    -- Find and remove the source item
    local sourceItem = findAndRemoveItem(self.macroTree, data.sourceId)
    if not sourceItem then
        hs.logger.new("HammerGhost"):e("Could not find source item: " .. data.sourceId)
        return
    end

    -- Find the target location
    local targetParent, targetIndex = findParentAndIndex(self.macroTree, data.targetId)
    if not targetParent then
        hs.logger.new("HammerGhost"):e("Could not find target item: " .. data.targetId)
        -- If we failed to find the target, put the source item back
        table.insert(self.macroTree, sourceItem)
        return
    end

    -- Insert the item at the new position
    if data.position == "before" then
        table.insert(targetParent, targetIndex, sourceItem)
    elseif data.position == "after" then
        table.insert(targetParent, targetIndex + 1, sourceItem)
    elseif data.position == "inside" and targetParent[targetIndex].type == "folder" then
        local targetItem = targetParent[targetIndex]
        if not targetItem.children then
            targetItem.children = {}
        end
        targetItem.expanded = true
        table.insert(targetItem.children, sourceItem)
    else
        -- If something went wrong, put the item back where it came from
        table.insert(self.macroTree, sourceItem)
        hs.logger.new("HammerGhost"):e("Invalid drop position: " .. data.position)
        return
    end

    -- Save the changes and refresh the window
    self:saveConfig()
    self:refreshWindow()
end

-- Function to handle application switch events
local function appSwitched(appName)
    print("Switched to application: " .. appName)

    -- Add specific actions for the Arc browser
    if appName == "Arc" then
        print("Arc browser activated!")
        -- Add any specific actions for Arc here
    else
        print("Activated application: " .. appName)
    end

    -- Add specific actions for the Cursor application
    if appName == "Cursor" then
        print("Cursor application activated!")
        -- Add any specific actions for Cursor here
    end
end

-- Function to handle cursor switch events
-- (This function can be removed if not needed)
-- local function cursorSwitched()
--     print("Cursor switched!")
--     -- Add any specific actions for cursor switch here
-- end

-- Create an application watcher
appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.activated then
        appSwitched(appName)
    end
end)

-- (Remove the cursor watcher if not needed)
-- cursorWatcher = hs.mouse.new(function(event)
--     if event:getType() == "mouseMoved" then
--         cursorSwitched()
--     end
-- end)

-- Start the watchers
appWatcher:start()
-- cursorWatcher:start() -- Uncomment if you keep the cursor watcher

-- Add autosave when Hammerspoon is about to exit
hs.shutdownCallback = function()
    if obj.window then
        obj:saveConfig()
    end
end

-- Return the object
return obj
