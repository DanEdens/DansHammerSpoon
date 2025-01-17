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
    if self.window and self.window:_window() then
        self.window:_window():hide()
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
        local scheme, host, params = action:match("^([^:]+)://([^?]+)%??(.*)$")
        if scheme == "hammerspoon" then
            if host == "selectItem" then
                self:selectItem(hs.http.urlDecode(params))
            elseif host == "toggleItem" then
                self:toggleItem(hs.http.urlDecode(params))
            elseif host == "configureItem" then
                self:configureItem(hs.http.urlDecode(params))
            elseif host == "saveProperties" then
                self:saveProperties(hs.http.urlDecode(params))
            elseif host == "deleteItem" then
                self:deleteItem(hs.http.urlDecode(params))
            end
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
    -- Base HTML with styles
    local baseHtml = [[
    <html>
    <head>
        <style>
            :root {
                --bg-color: #1e1e1e;
                --text-color: #d4d4d4;
                --border-color: #404040;
                --hover-color: #2d2d2d;
                --active-color: #3d3d3d;
                --selected-color: #094771;
            }
            
            body {
                background-color: var(--bg-color);
                color: var(--text-color);
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                margin: 0;
                padding: 0;
                user-select: none;
                height: 100vh;
                display: flex;
            }
            
            #tree-panel {
                width: 70%;
                border-right: 1px solid var(--border-color);
                overflow-y: auto;
                padding: 10px;
            }
            
            #properties-panel {
                width: 30%;
                padding: 10px;
                overflow-y: auto;
            }
            
            .tree-item {
                padding: 6px 8px;
                margin: 2px 0;
                border-radius: 4px;
                display: flex;
                align-items: center;
                cursor: pointer;
            }
            
            .tree-item:hover {
                background-color: var(--hover-color);
            }
            
            .tree-item.selected {
                background-color: var(--selected-color);
            }
            
            .tree-item .icon {
                margin-right: 8px;
                font-size: 16px;
            }
            
            .tree-item .name {
                flex-grow: 1;
            }
            
            .tree-item .actions {
                opacity: 0;
                transition: opacity 0.2s;
                display: flex;
                align-items: center;
                gap: 4px;
            }
            
            .tree-item:hover .actions {
                opacity: 1;
            }
            
            .tree-item button {
                background: none;
                border: none;
                color: var(--text-color);
                cursor: pointer;
                font-size: 14px;
                padding: 4px;
                margin: 0;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
            }
            
            .tree-item button:hover {
                background-color: var(--active-color);
            }
            
            .tree-item button.edit:hover {
                background-color: #2b4f77;
            }
            
            .tree-item button.delete:hover {
                background-color: #772b2b;
            }
            
            .properties-form {
                display: flex;
                flex-direction: column;
                gap: 10px;
            }
            
            .form-group {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }
            
            .form-group label {
                font-weight: 500;
            }
            
            .form-group input, .form-group select {
                background-color: var(--bg-color);
                border: 1px solid var(--border-color);
                color: var(--text-color);
                padding: 6px 8px;
                border-radius: 4px;
            }
            
            .form-group input:focus, .form-group select:focus {
                outline: none;
                border-color: var(--selected-color);
            }
        </style>
        <script>
            function selectItem(id, event) {
                if (event) event.stopPropagation();
                window.location.href = 'hammerspoon://selectItem?' + encodeURIComponent(id);
            }
            
            function toggleItem(id, event) {
                if (event) event.stopPropagation();
                window.location.href = 'hammerspoon://toggleItem?' + encodeURIComponent(id);
            }
            
            function editItem(id, event) {
                if (event) event.stopPropagation();
                const name = prompt('Enter new name:');
                if (name) {
                    window.location.href = 'hammerspoon://editItem?' + encodeURIComponent(JSON.stringify({id: id, name: name}));
                }
            }
            
            function deleteItem(id, event) {
                if (event) event.stopPropagation();
                if (confirm('Are you sure you want to delete this item?')) {
                    window.location.href = 'hammerspoon://deleteItem?' + encodeURIComponent(id);
                }
            }
        </script>
    </head>
    <body>
    ]]

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
                    <button class="edit" onclick="editItem('%s', event)" title="Edit">✏️</button>
                    <button class="delete" onclick="deleteItem('%s', event)" title="Delete">🗑️</button>
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

    local treeContent = [[<div id="tree-panel">]]

    for _, item in ipairs(self.macroTree) do
        treeContent = treeContent .. generateItemHTML(item, 0)
    end

    treeContent = treeContent .. [[</div><div id="properties-panel">]]

    -- Add properties panel content if an item is selected
    if self.currentSelection then
        treeContent = treeContent .. string.format([[
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

    treeContent = treeContent .. [[</div>]]

    return baseHtml .. treeContent .. [[</body></html>]]
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

--- HammerGhost:configureItem(id)
--- Method
--- Show configuration panel for an item
---
--- Parameters:
---  * id - The ID of the item to configure
---
--- Returns:
---  * None
function obj:configureItem(id)
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

    local item = findItem(self.macroTree)
    if not item then return end

    -- Select the item first
    self.currentSelection = item

    -- Generate properties panel HTML based on item type
    local propertiesHtml = string.format([[
        <div class="properties-form" id="properties-form">
            <h2>%s Properties</h2>
            <div class="form-group">
                <label for="name">Name</label>
                <input type="text" name="name" value="%s">
            </div>
            <div class="form-group">
                <label>
                    <input type="checkbox" name="enabled" %s>
                    Enabled
                </label>
            </div>
    ]], item.type:gsub("^%l", string.upper), item.name, item.enabled and "checked" or "")

    -- Add type-specific configuration fields
    if item.type == "action" then
        propertiesHtml = propertiesHtml .. [[
            <div class="form-group">
                <label for="command">Command</label>
                <textarea name="command" data-config rows="4"></textarea>
            </div>
        ]]
    elseif item.type == "sequence" then
        propertiesHtml = propertiesHtml .. [[
            <div class="form-group">
                <label for="delay">Delay between steps (ms)</label>
                <input type="number" name="delay" data-config value="0" min="0">
            </div>
        ]]
    end

    -- Add save/cancel buttons
    propertiesHtml = propertiesHtml .. string.format([[
            <div class="form-buttons">
                <button onclick="saveProperties('%s')" class="primary">Save</button>
            </div>
        </div>
    ]], item.id)

    -- Update the properties panel
    if self.window then
        self.window:evaluateJavaScript(string.format([[
            document.getElementById('properties-panel').innerHTML = `%s`;
        ]], propertiesHtml))
    end
end

--- HammerGhost:saveProperties(data)
--- Method
--- Save properties for an item
---
--- Parameters:
---  * data - JSON string containing the properties to save
---
--- Returns:
---  * None
function obj:saveProperties(jsonData)
    local success, data = pcall(hs.json.decode, jsonData)
    if not success then
        hs.logger.new("HammerGhost"):e("Failed to decode properties data")
        return
    end

    local function updateItem(items)
        for _, item in ipairs(items) do
            if item.id == data.id then
                item.name = data.name
                item.enabled = data.enabled
                if data.config then
                    item.config = data.config
                end
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
        hs.alert.show("Properties saved")
    end
end

-- Return the object
return obj
