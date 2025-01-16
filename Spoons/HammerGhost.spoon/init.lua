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
    if hs.fs.attributes(self.configPath) then
        local f = io.open(self.configPath, "r")
        if f then
            local content = f:read("*all")
            f:close()
            -- TODO: Parse XML content
            -- self.macroTree = parseXML(content) or {}
        end
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
    if self.window then
        self.window:show()
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
        if self.window:isVisible() then
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
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- Create main window
    local webview = hs.webview.new({
        x = frame.x + (frame.w * 0.1),
        y = frame.y + (frame.h * 0.1),
        w = frame.w * 0.8,
        h = frame.h * 0.8
    }, { developerExtrasEnabled = true })  -- Enable dev tools for debugging

    if not webview then
        hs.logger.new("HammerGhost"):e("Failed to create webview")
        return
    end

    -- Set up webview
    webview:windowTitle("HammerGhost")
    webview:windowStyle(hs.webview.windowMasks.titled 
                     | hs.webview.windowMasks.closable 
                     | hs.webview.windowMasks.resizable)
    webview:allowTextEntry(true)
    webview:darkMode(true)

    -- Set up message handlers
    webview:navigationCallback(function(action, webview)
        if action == "selectItem" then
            self:selectItem(webview:evaluateJavaScript("event.data"))
        elseif action == "toggleItem" then
            self:toggleItem(webview:evaluateJavaScript("event.data"))
        elseif action == "editItem" then
            self:editItem(webview:evaluateJavaScript("event.data"))
        elseif action == "deleteItem" then
            self:deleteItem(webview:evaluateJavaScript("event.data"))
        end
        return true
    end)

    -- Load HTML content
    local htmlFile = io.open(hs.spoons.resourcePath("assets/index.html"), "r")
    if htmlFile then
        local content = htmlFile:read("*all")
        htmlFile:close()
        webview:html(content)
    else
        hs.logger.new("HammerGhost"):e("Failed to load index.html")
        webview:html("<html><body style='background: #1e1e1e; color: #d4d4d4;'><h1>Error loading UI</h1></body></html>")
    end
    
    -- Store the webview
    self.window = webview
    
    -- Create toolbar
    self:createToolbar()
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
    local function generateItemHTML(item, depth)
        local indent = string.rep("    ", depth)
        local icon = item.type == "folder" and (item.expanded and "📂" or "📁") or
                    item.type == "action" and "⚡" or
                    item.type == "sequence" and "⚙️" or "❓"
        
        local selectedClass = (self.currentSelection and self.currentSelection.id == item.id) and " selected" or ""
        local indentStyle = string.format("padding-left: %dpx;", depth * 20)
        
        local html = string.format([[
            <div class="tree-item%s" data-id="%s" data-type="%s" style="%s" onclick="selectItem('%s')">
                <span class="icon" onclick="toggleItem('%s', event)">%s</span>
                <span class="name">%s</span>
                <div class="actions">
                    <button onclick="editItem('%s', event)">✏️</button>
                    <button onclick="deleteItem('%s', event)">🗑️</button>
                </div>
            </div>
        ]], selectedClass, item.id, item.type, indentStyle, item.id, item.id, icon, item.name, item.id, item.id)
        
        if item.children and #item.children > 0 and item.expanded then
            for _, child in ipairs(item.children) do
                html = html .. generateItemHTML(child, depth + 1)
            end
        end
        
        return html
    end
    
    local treeHtml = [[
        <div id="tree-panel">
    ]]
    
    for _, item in ipairs(self.macroTree) do
        treeHtml = treeHtml .. generateItemHTML(item, 0)
    end
    
    treeHtml = treeHtml .. [[
        </div>
        <div id="properties-panel">
    ]]
    
    -- Add properties panel content if an item is selected
    if self.currentSelection then
        treeHtml = treeHtml .. string.format([[
            <div class="properties-form">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" value="%s" onchange="updateProperty('name', this.value)">
                </div>
                <div class="form-group">
                    <label>Type</label>
                    <input type="text" value="%s" readonly>
                </div>
            </div>
        ]], self.currentSelection.name, self.currentSelection.type)
    end
    
    treeHtml = treeHtml .. [[
        </div>
    ]]
    
    return treeHtml
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
    -- Convert macro tree to XML
    local xml = self:macroTreeToXML()
    
    -- Save to file
    local f = io.open(self.configPath, "w")
    if f then
        f:write(xml)
        f:close()
        hs.alert.show("Configuration saved")
    else
        hs.alert.show("Error saving configuration")
    end
end

--- HammerGhost:macroTreeToXML()
--- Method
--- Convert the macro tree to XML
---
--- Parameters:
---  * None
---
--- Returns:
---  * The generated XML
function obj:macroTreeToXML()
    local function itemToXML(item)
        local attrs = string.format('type="%s" name="%s"', item.type, item.name)
        if item.type == "action" then
            return string.format('<item %s/>', attrs)
        else
            local children = ""
            if item.children and #item.children > 0 then
                for _, child in ipairs(item.children) do
                    children = children .. itemToXML(child)
                end
            end
            return string.format('<item %s>%s</item>', attrs, children)
        end
    end
    
    local xml = '<?xml version="1.0" encoding="UTF-8"?>\n<macros>\n'
    for _, item in ipairs(self.macroTree) do
        xml = xml .. itemToXML(item) .. "\n"
    end
    xml = xml .. '</macros>'
    
    return xml
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

-- Return the object
return obj 
