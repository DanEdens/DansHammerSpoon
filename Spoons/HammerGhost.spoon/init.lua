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
obj.actionEditor = nil
obj.currentActionId = nil

-- Load additional modules
local xmlparser = dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))
local actionManager = dofile(hs.spoons.resourcePath("scripts/action_manager.lua"))

-- Helper function to generate unique IDs
function obj:generateId()
    self.lastId = self.lastId + 1
    return tostring(self.lastId)
end

function obj:init()
    -- Create a logger for better debugging
    local HyperLogger = require('HyperLogger')
    self.logger = HyperLogger.new('HammerGhost', 'info')
    self.logger:setLogLevel('debug')
    self.logger:i("Initializing HammerGhost")
    -- Check resources first
    if not self:checkResources() then
        hs.alert.show("HammerGhost: Missing required resources")
        return self
    end

    -- Register URL event handler for 'hammerspoon' scheme
    self.logger:i("Setting up URL event handlers")
    hs.urlevent.setDefaultHandler('hammerspoon')

    -- Generic URL event handler
    hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
        self.logger:i("Received URL event: " .. fullURL)
        self.logger:d("Params: " .. hs.inspect(params))

        -- Process based on host (action)
        if host == "selectItem" then
            self:selectItem(params.id)
        elseif host == "toggleItem" then
            self:toggleItem(params.id)
        elseif host == "editItem" then
            self:editItem(params)
        elseif host == "deleteItem" then
            self:deleteItem(params.id)
        elseif host == "openActionEditor" then
            self:showActionEditor()
        else
            self.logger:w("Unhandled URL event action: " .. host)
        end
    end
    -- Initialize action manager
    actionManager:init()
    -- Load saved macros if they exist
    if hs.fs.attributes(self.configPath) then
        local f = io.open(self.configPath, "r")
        if f then
            local content = f:read("*all")
            f:close()
            self.macroTree = xmlparser.fromXML(content) or {}
            -- Find highest ID to continue from
            local function findHighestId(items)
                local highest = 0
                for _, item in ipairs(items) do
                    local id = tonumber(item.id)
                    if id and id > highest then
                        highest = id
                    end
                    if item.children then
                        local childHighest = findHighestId(item.children)
                        if childHighest > highest then
                            highest = childHighest
                        end
                    end
                end
                return highest
            end
            self.lastId = findHighestId(self.macroTree)
        end
    end
    return self
end

function obj:start()
    if not self.window then
        self:createMainWindow()
    end
    if self.window then
        self.window:show()
        -- Inject our JavaScript bridge after a small delay to ensure the page is loaded
        hs.timer.doAfter(0.5, function()
            self:injectBridge()
        end)
    end
    return self
end

function obj:stop()
    if self.window then
        self:saveConfig()
        self.window:hide()
    end
    -- Save actions
    actionManager:save()
    return self
end

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
---   * showActions - Open the action editor
---
--- Returns:
---  * The HammerGhost object
function obj:bindHotkeys(mapping)
    local spec = {
        toggle = hs.fnutils.partial(self.toggle, self),
        addAction = hs.fnutils.partial(self.addAction, self),
        addSequence = hs.fnutils.partial(self.addSequence, self),
        addFolder = hs.fnutils.partial(self.addFolder, self),
        showActions = hs.fnutils.partial(self.showActionEditor, self)
    }
    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

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

    -- Set up navigation callback for URL scheme based communication
    webview:navigationCallback(function(action, webview)
        self.logger:d("WebView navigation event: " .. action)

        -- If this is an actual URL (not a WebView event), try to extract hammerspoon:// URLs
        if action:match("^[a-z]+://") then
            if action:match("^hammerspoon://") then
                self.logger:i("Found hammerspoon URL: " .. action)
                -- Let it through so the OS can handle the URL scheme
                return false
            elseif action:match("^http[s]?://") then
                -- Also let through normal web URLs
                return false
            end
        end

        -- For WebView events, just return false to allow navigation
        return false
    end)

    -- Load HTML content
    local htmlFile = io.open(hs.spoons.resourcePath("assets/index.html"), "r")
    if htmlFile then
        local content = htmlFile:read("*all")
        htmlFile:close()
        webview:html(content)
    else
        self.logger:e("Failed to load index.html")
        webview:html("<html><body style='background: #1e1e1e; color: #d4d4d4;'><h1>Error loading UI</h1></body></html>")
    end

    -- Store the webview
    self.window = webview

    -- Create toolbar
    self:createToolbar()
end

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
            id = "actionEditor",
            label = "Action Editor",
            image = hs.image.imageFromName("NSPreferencesGeneral"),
            fn = function() self:showActionEditor() end
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

-- Show action editor window
function obj:showActionEditor()
    if self.actionEditor then
        self.actionEditor:show()
        self:refreshActionEditor()
        return
    end

    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- Create action editor window
    local editor = hs.webview.new({
        x = frame.x + (frame.w * 0.15),
        y = frame.y + (frame.h * 0.15),
        w = frame.w * 0.7,
        h = frame.h * 0.7
    }, { developerExtrasEnabled = true })

    -- Set up window
    editor:windowTitle("HammerGhost Action Editor")
    editor:windowStyle(hs.webview.windowMasks.titled
        | hs.webview.windowMasks.closable
        | hs.webview.windowMasks.resizable)
    editor:allowTextEntry(true)
    editor:darkMode(true)

    -- Set up navigation handler (reusing the same handler as main window)
    editor:navigationCallback(function(action, webview)
        return self.window:navigationCallback()(action, webview)
    end)

    -- Load the action editor HTML
    local htmlFile = io.open(hs.spoons.resourcePath("assets/action_editor.html"), "r")
    if htmlFile then
        local content = htmlFile:read("*all")
        htmlFile:close()
        editor:html(content)
    else
        hs.logger.new("HammerGhost"):e("Failed to load action_editor.html")
        editor:html(
        "<html><body style='background: #1e1e1e; color: #d4d4d4;'><h1>Error loading Action Editor</h1></body></html>")
    end

    -- Store the editor
    self.actionEditor = editor
end

-- Close action editor
function obj:closeActionEditor()
    if self.actionEditor then
        self.actionEditor:hide()
    end
end

-- Refresh action editor with current data
function obj:refreshActionEditor()
    if not self.actionEditor or not self.actionEditor:isVisible() then return end

    local data = actionManager:getActionEditorData(self.currentActionId)
    local jsonData = hs.json.encode(data)

    -- Inject the data into the editor
    self.actionEditor:evaluateJavaScript(string.format("updateData(%s)", jsonData))
end

function obj:selectItem(index)
    local function findItem(items)
        for _, item in ipairs(items) do
            if item.id == index then
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
    hs.logger.new("HammerGhost"):d("Selected item: " .. tostring(index))
    self:refreshWindow()
end

function obj:toggleItem(index)
    local function findAndToggle(items)
        for _, item in ipairs(items) do
            if item.id == index and item.children then
                item.expanded = not item.expanded
                hs.logger.new("HammerGhost"):d("Toggled item: " .. item.name .. ", expanded: " .. tostring(item.expanded))
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

function obj:editItem(data)
    if not data or not data.id or not data.name then
        hs.logger.new("HammerGhost"):e("Invalid edit data")
        return
    end

    local function findAndEdit(items)
        for _, item in ipairs(items) do
            if item.id == data.id then
                item.name = data.name
                hs.logger.new("HammerGhost"):d("Edited item " .. data.id .. " to name: " .. data.name)
                return true
            end
            if item.children then
                if findAndEdit(item.children) then
                    return true
                end
            end
        end
        return false
    end

    if findAndEdit(self.macroTree) then
        self:refreshWindow()
        self:saveConfig()
    else
        hs.logger.new("HammerGhost"):e("Could not find item with id: " .. data.id)
    end
end

function obj:deleteItem(index)
    self.logger:i("Deleting item with ID: " .. tostring(index))

    -- Ensure index is treated as string for consistent comparison
    index = tostring(index)
    local function removeFromParent(items)
        for i, item in ipairs(items) do
            -- Ensure item.id is treated as string for comparison
            self.logger:d("Comparing item with ID: " .. tostring(item.id) .. " to target ID: " .. index)
            if tostring(item.id) == index then
                local name = item.name -- Store name before removal
                table.remove(items, i)
                self.logger:i("Deleted item: " .. name .. " at index " .. i)
                return true, name
            end
            if item.children then
                local success, name = removeFromParent(item.children)
                if success then return true, name end
            end
        end
        return false, nil
    end

    local success, name = removeFromParent(self.macroTree)
    if success then
        -- If we deleted the currently selected item, clear the selection
        if self.currentSelection and tostring(self.currentSelection.id) == index then
            self.currentSelection = nil
        end
        self.logger:i("Successfully deleted item: " .. (name or "unknown"))
        self:refreshWindow()
        self:saveConfig()
        hs.alert.show("Deleted: " .. (name or "item"))
    else
        self.logger:e("Could not find item with id: " .. index)
    end
end

function obj:getCurrentSelection()
    return self.currentSelection
end

function obj:addFolder()
    local name = "New Folder"
    self:createMacroItem(name, "folder", self:getCurrentSelection())
end

function obj:addAction()
    local name = "New Action"
    self:createMacroItem(name, "action", self:getCurrentSelection())
end

function obj:addSequence()
    local name = "New Sequence"
    self:createMacroItem(name, "sequence", self:getCurrentSelection())
end

function obj:refreshWindow()
    if not self.window then return end

    -- If we have items in the tree, generate the tree view, otherwise let the welcome screen show
    if #self.macroTree > 0 then
        -- Generate HTML for the macro tree
        local html = self:generateTreeHTML()
        self.window:html(html)
    end
    -- If there are no items, keep the welcome screen visible (which is loaded from index.html)
end

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
                cursor: move;
                user-select: none;
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
            
            .tree-item.dragging {
                opacity: 0.5;
                background: var(--active-color);
            }
            
            .drop-indicator {
                height: 2px;
                background-color: var(--selected-color);
                margin: 0;
                opacity: 0;
                transition: opacity 0.2s;
            }
            
            .drop-indicator.active {
                opacity: 1;
            }
            
            .drop-indicator.inside {
                margin-left: 20px;
            }
        </style>
        <script>
            let draggedItem = null;
            let lastDropIndicator = null;
            
            function startDrag(id, event) {
                event.stopPropagation();
                draggedItem = document.querySelector(`.tree-item[data-id="${id}"]`);
                draggedItem.classList.add('dragging');
                event.dataTransfer.setData('text/plain', id);
                event.dataTransfer.effectAllowed = 'move';
            }
            
            function endDrag(event) {
                if (draggedItem) {
                    draggedItem.classList.remove('dragging');
                    draggedItem = null;
                }
                // Remove any active drop indicators
                document.querySelectorAll('.drop-indicator.active').forEach(el => {
                    el.classList.remove('active');
                });
            }
            
            function dragOver(event) {
                event.preventDefault();
                event.stopPropagation();
                event.dataTransfer.dropEffect = 'move';
                
                const target = event.target.closest('.tree-item');
                if (!target || target === draggedItem) return;
                
                // Calculate drop position (before, after, or inside)
                const rect = target.getBoundingClientRect();
                const y = event.clientY - rect.top;
                const position = y < rect.height / 3 ? 'before' :
                               y > rect.height * 2/3 ? 'after' : 'inside';
                
                // Show drop indicator
                if (lastDropIndicator) {
                    lastDropIndicator.classList.remove('active');
                }
                
                let indicator;
                if (position === 'before') {
                    indicator = target.previousElementSibling;
                } else if (position === 'after') {
                    indicator = target.nextElementSibling;
                } else {
                    indicator = target.querySelector('.drop-indicator');
                }
                
                if (indicator && indicator.classList.contains('drop-indicator')) {
                    indicator.classList.add('active');
                    lastDropIndicator = indicator;
                }
            }
            
            function drop(event) {
                event.preventDefault();
                event.stopPropagation();
                
                const sourceId = event.dataTransfer.getData('text/plain');
                const target = event.target.closest('.tree-item');
                if (!target || target.dataset.id === sourceId) return;
                
                // Calculate drop position
                const rect = target.getBoundingClientRect();
                const y = event.clientY - rect.top;
                const position = y < rect.height / 3 ? 'before' :
                               y > rect.height * 2/3 ? 'after' : 'inside';
                
                // Send move command to Hammerspoon
                sendCommand('moveItem', {
                    sourceId: sourceId,
                    targetId: target.dataset.id,
                    position: position
                });
                
                endDrag(event);
            }
            
            function selectItem(id, event) {
                if (event) event.stopPropagation();
                sendCommand('selectItem', { id: id });
            }
            
            function toggleItem(id, event) {
                if (event) event.stopPropagation();
                sendCommand('toggleItem', { id: id });
            }
            
            function editItem(id, name, event) {
                if (event) event.stopPropagation();
                const newName = prompt('Enter new name:', name);
                if (newName) {
                    sendCommand('editItem', { id: id, name: newName });
                }
            }
            
            function updateProperty(id, property, value) {
                sendCommand('updateProperty', {
                    id: id,
                    property: property,
                    value: value
                });
            }
            
            function deleteItem(id, name, event) {
                if (event) event.stopPropagation();
                // Instead of using confirm dialog, create a better delete confirmation UI
                const confirmDeleteModal = document.createElement('div');
                confirmDeleteModal.className = 'delete-confirm-modal';
                confirmDeleteModal.innerHTML = `
                    <div class="delete-confirm-content">
                        <h3>Confirm Delete</h3>
                        <p>Are you sure you want to delete "${name}"?</p>
                        <div class="delete-confirm-buttons">
                            <button class="btn-cancel">Cancel</button>
                            <button class="btn-delete">Delete</button>
                        </div>
                    </div>
                `;
                
                document.body.appendChild(confirmDeleteModal);
                
                // Style the modal
                const style = document.createElement('style');
                style.textContent = `
                    .delete-confirm-modal {
                        position: fixed;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        background-color: rgba(0, 0, 0, 0.5);
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        z-index: 1000;
                    }
                    .delete-confirm-content {
                        background-color: var(--bg-color);
                        border-radius: 8px;
                        padding: 20px;
                        width: 300px;
                        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
                    }
                    .delete-confirm-content h3 {
                        margin-top: 0;
                    }
                    .delete-confirm-buttons {
                        display: flex;
                        justify-content: flex-end;
                        gap: 10px;
                        margin-top: 20px;
                    }
                    .btn-cancel {
                        background-color: var(--active-color);
                        color: var(--text-color);
                        border: none;
                        padding: 8px 16px;
                        border-radius: 4px;
                        cursor: pointer;
                    }
                    .btn-delete {
                        background-color: #772b2b;
                        color: white;
                        border: none;
                        padding: 8px 16px;
                        border-radius: 4px;
                        cursor: pointer;
                    }
                `;
                document.head.appendChild(style);
                
                // Add event listeners
                const cancelBtn = confirmDeleteModal.querySelector('.btn-cancel');
                const deleteBtn = confirmDeleteModal.querySelector('.btn-delete');
                
                cancelBtn.addEventListener('click', () => {
                    document.body.removeChild(confirmDeleteModal);
                    document.head.removeChild(style);
                });
                
                deleteBtn.addEventListener('click', () => {
                    // First remove the modal
                    document.body.removeChild(confirmDeleteModal);
                    document.head.removeChild(style);
                    
                    // Then trigger the delete action with a slight delay to ensure UI updates first
                    setTimeout(() => {
                        sendCommand('deleteItem', { id: id });
                    }, 50);
                });
            }
            
            // Helper function to send commands to Hammerspoon
            function sendCommand(action, data) {
                // Create a global Hammerspoon communication object if it doesn't exist
                if (!window.HammerspoonActions) {
                    window.HammerspoonActions = {
                        pendingCommands: []
                    };
                }
                
                // Add the command to the queue
                window.HammerspoonActions.pendingCommands.push({
                    action: action,
                    ...data
                });
                
                // Use URL scheme to notify Hammerspoon
                const params = encodeURIComponent(JSON.stringify({
                    action: action,
                    ...data
                }));
                window.location.href = `hammerspoon://${action}?${params}`;
            }
        </script>
    </head>
    <body>
    ]]

    local function generateItemHTML(item, depth)
        local indent = string.rep("    ", depth)
        -- Update icon handling to use system icons
        local icon = ""
        if item.type == "folder" then
            icon = item.expanded and "📂" or "📁"
        elseif item.type == "action" then
            icon = "⚡"
        elseif item.type == "sequence" then
            icon = "⚙️"
        else
            icon = "❓"
        end

        local selectedClass = (self.currentSelection and self.currentSelection.id == item.id) and " selected" or ""
        local indentStyle = string.format("padding-left: %dpx;", depth * 20)

        local html = string.format([[
            <div class="drop-indicator"></div>
            <div class="tree-item%s" data-id="%s" data-type="%s" style="%s"
                 onclick="selectItem('%s')"
                 draggable="true"
                 ondragstart="startDrag('%s', event)"
                 ondragend="endDrag(event)"
                 ondragover="dragOver(event)"
                 ondrop="drop(event)">
                <span class="icon" onclick="toggleItem('%s', event)">%s</span>
                <span class="name">%s</span>
                <div class="actions">
                    <button class="edit" onclick="editItem('%s', '%s', event)" title="Edit">✏️</button>
                    <button class="delete" onclick="deleteItem('%s', '%s', event)" title="Delete">🗑️</button>
                </div>
            </div>
            <div class="drop-indicator"></div>
        ]], selectedClass, item.id, item.type, indentStyle, item.id, item.id, item.id, icon, item.name,
            item.id, item.name:gsub("'", "\\'"), item.id, item.name:gsub("'", "\\'"))

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

    return baseHtml .. treeContent .. [[</body></html>]]
end

--- HammerGhost:saveConfig()
function obj:saveConfig()
    -- Convert macro tree to XML
    local xml = xmlparser.toXML(self.macroTree)
    hs.logger.new("HammerGhost"):i("Saving config, tree has " .. #self.macroTree .. " items")

    -- Save to file
    local f = io.open(self.configPath, "w")
    if f then
        f:write(xml)
        f:close()
        hs.alert.show("Configuration saved")
        hs.logger.new("HammerGhost"):i("Config saved successfully to " .. self.configPath)
    else
        hs.alert.show("Error saving configuration")
        hs.logger.new("HammerGhost"):e("Failed to open config file for writing: " .. self.configPath)
    end
end


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
    if not targetParent or not targetIndex then
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

-- Add autosave when Hammerspoon is about to exit
hs.shutdownCallback = function()
    if obj.window then
        obj:saveConfig()
    end
    -- Also save actions
    actionManager:save()
end
function obj:getTreeDataJSON()
    self.logger:d("Getting tree data as JSON")
    -- Convert the macro tree to JSON
    local success, jsonData = pcall(hs.json.encode, self.macroTree)
    if success then
        return jsonData
    else
        self.logger:e("Failed to encode tree data to JSON: " .. jsonData)
        return "[]"
    end
end

function obj:injectBridge()
    if not self.window then
        self.logger:e("Cannot inject bridge - window not initialized")
        return
    end

    self.logger:i("Injecting JavaScript bridge")

    -- Prepare the bridge script
    local bridge = [[
        // Create the bridge object if it doesn't exist
        if (!window.hammerspoon) {
            window.hammerspoon = {};
        }

        // Add tree data method
        window.hammerspoon.getTreeData = function() {
            return `TREE_DATA_JSON`;
        };

        // Log that we've set up the bridge
        console.log("Hammerspoon bridge injected successfully");
    ]]

    -- Insert the actual tree data
    bridge = bridge:gsub("TREE_DATA_JSON", self:getTreeDataJSON())

    -- Inject the bridge script
    self.window:evaluateJavaScript(bridge, function(result, error)
        if error then
            self.logger:e("Failed to inject JavaScript bridge: " .. hs.inspect(error))
        else
            self.logger:i("JavaScript bridge injected successfully")
        end
    end)
end
-- Return the object
return obj
