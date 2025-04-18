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
obj.server = nil

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

    -- Initialize the server for URL handling
    self.logger:i("Initializing HTTP server for URL event handling")
    -- Register URL event handlers for JavaScript bridge
    self.logger:i("Setting up URL event handlers")
    -- Make sure Hammerspoon handles the hammerspoon:// URL scheme
    hs.urlevent.setDefaultHandler('hammerspoon')
    
    -- Enable URL event tracing for debugging
    self:addURLTracing()
    -- Initialize the callback table
    self.callbacks = {
        onSelect = nil,
        onToggle = nil,
        onEdit = nil,
        onDelete = nil,
        onMove = nil,
        onAdd = nil
    }

    -- URL event handlers for JavaScript bridge
    local handlers = {
        selectItem = function(params)
            local id = params.id
            if id and self.callbacks.onSelect then
                self.callbacks.onSelect(id)
            end
            return true
        end,

        toggleItem = function(params)
            local id = params.id
            if id and self.callbacks.onToggle then
                self.callbacks.onToggle(id)
            end
            return true
        end,

        editItem = function(params)
            local id = params.id
            local label = params.label
            if id and label and self.callbacks.onEdit then
                self.callbacks.onEdit(id, label)
            end
            return true
        end,

        deleteItem = function(params)
            local id = params.id
            if id and self.callbacks.onDelete then
                self.callbacks.onDelete(id)
            end
            return true
        end,

        moveItem = function(params)
            local id = params.id
            local targetId = params.targetId
            local position = params.position
            if id and position and self.callbacks.onMove then
                self.callbacks.onMove(id, targetId, position)
            end
            return true
        end,

        addItem = function(params)
            local label = params.label
            if label and self.callbacks.onAdd then
                self.callbacks.onAdd(label)
            end
            return true
        end
    }

    -- Handle selectItem events
    hs.urlevent.bind("selectItem", function(eventName, params)
        self.logger:d("Received selectItem event with params: " .. hs.inspect(params))
        if params and params.id then
            self.logger:i("Selecting item with ID: " .. params.id)
            self:selectItem(params.id)
        else
            self.logger:w("Missing id parameter for selectItem")
        end
    end)

    -- Handle toggleItem events
    hs.urlevent.bind("toggleItem", function(eventName, params)
        self.logger:d("Received toggleItem event with params: " .. hs.inspect(params))
        if params and params.id then
            self:toggleItem(params.id)
        else
            self.logger:w("Missing id parameter for toggleItem")
        end
    end)

    -- Handle editItem events
    hs.urlevent.bind("editItem", function(eventName, params)
        self.logger:d("Received editItem event with params: " .. hs.inspect(params))
        if params and params.id and params.name then
            self:editItem({ id = params.id, name = params.name })
        else
            self.logger:w("Missing parameters for editItem")
        end
    end)

    -- Handle deleteItem events
    hs.urlevent.bind("deleteItem", function(eventName, params)
        self.logger:d("Received deleteItem event with params: " .. hs.inspect(params))
        if params and params.id then
            self:deleteItem(params.id)
        else
            self.logger:w("Missing id parameter for deleteItem")
        end
    end)

    -- Handle moveItem events
    hs.urlevent.bind("moveItem", function(eventName, params)
        self.logger:d("Received moveItem event with params: " .. hs.inspect(params))
        if params and params.sourceId and params.targetId and params.position then
            self:moveItem({
                sourceId = params.sourceId,
                targetId = params.targetId,
                position = params.position
            })
        else
            self.logger:w("Missing parameters for moveItem")
        end
    end)

    -- Handle updateProperty events
    hs.urlevent.bind("updateProperty", function(eventName, params)
        self.logger:d("Received updateProperty event with params: " .. hs.inspect(params))
        if params and params.id and params.property and params.value ~= nil then
            self:updateProperty({
                id = params.id,
                property = params.property,
                value = params.value
            })
        else
            self.logger:w("Missing required parameters for updateProperty")
        end
    end)
    -- Handle openActionEditor events
    hs.urlevent.bind("openActionEditor", function(eventName, params)
        self.logger:d("Received openActionEditor event")
        self:showActionEditor()
    end)
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

                -- Extract the action and parameters
                local scheme, host, paramString = action:match("^(hammerspoon)://([^?]*)%??(.*)$")

                self.logger:d("URL parsed - host: " .. tostring(host) .. ", params: " .. tostring(paramString))

                -- Convert parameter string to a table
                local params = {}
                if paramString and paramString ~= "" then
                    for pair in paramString:gmatch("([^&]+)") do
                        local k, v = pair:match("([^=]+)=(.+)")
                        if k and v then
                            -- URL decode the key and value
                            k = k:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
                            v = v:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
                            params[k] = v
                            self.logger:d("Param: " .. k .. " = " .. v)
                        end
                    end
                end
                -- Manually trigger the appropriate handler based on the host
                if host == "selectItem" then
                    hs.urlevent.handleURLEvent("selectItem", params)
                elseif host == "toggleItem" then
                    hs.urlevent.handleURLEvent("toggleItem", params)
                elseif host == "editItem" then
                    hs.urlevent.handleURLEvent("editItem", params)
                elseif host == "deleteItem" then
                    hs.urlevent.handleURLEvent("deleteItem", params)
                elseif host == "moveItem" then
                    hs.urlevent.handleURLEvent("moveItem", params)
                elseif host == "openActionEditor" then
                    hs.urlevent.handleURLEvent("openActionEditor", params)
                end

                -- Return true to prevent the OS from trying to handle the URL
                return true
            elseif action:match("^http[s]?://") then
                -- Let through normal web URLs
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
            
            function deleteItem(id, name) {
                console.log("Deleting item:", id, name);
                return window.bridge.sendCommand('deleteItem', { id: id });
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

        -- Format item name for use in JavaScript event handlers to avoid quote issues
        local escapedName = item.name:gsub("'", "\\'")
        
        -- Build HTML in parts to avoid complex string formatting
        local html = '<div class="drop-indicator"></div>\n'

        -- Start tree item div
        html = html .. string.format('<div class="tree-item%s" data-id="%s" data-type="%s" style="%s" ',
            selectedClass, item.id, item.type, indentStyle)

        -- Add event handlers
        html = html .. string.format('onclick="selectItemHandler(\'%s\')" ', item.id)
        html = html .. 'draggable="true" '
        html = html .. string.format('ondragstart="startDrag(event, \'%s\')" ', item.id)
        html = html .. 'ondragend="endDrag(event)" '
        html = html .. 'ondragover="dragOver(event)" '
        html = html .. string.format('ondrop="drop(event, \'%s\', \'after\')">', item.id)

        -- Add icon
        html = html .. string.format('<span class="icon" onclick="toggleItemHandler(\'%s\'); return false;">%s</span>',
            item.id, icon)

        -- Add name
        html = html .. string.format('<span class="name">%s</span>', item.name)

        -- Add action buttons
        html = html .. '<div class="actions">'
        html = html ..
            string.format(
                '<button class="edit" onclick="editItemHandler(\'%s\', \'%s\'); return false;" title="Edit">✏️</button>',
                item.id, escapedName)
        html = html ..
            string.format(
                '<button class="delete" onclick="deleteItemHandler(\'%s\', \'%s\'); return false;" title="Delete">🗑️</button>',
                item.id, escapedName)
        html = html .. '</div>'

        -- Close tree item div
        html = html .. '</div>\n'
        html = html .. '<div class="drop-indicator"></div>'

        -- Recursively generate HTML for children if this item is expanded
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
                <input type="text" value="%s" onchange="updatePropertyHandler('%s', 'name', this.value)">
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
                    <input type="text" value="%s" onchange="updatePropertyHandler('%s', 'shortcut', this.value)" placeholder="e.g. cmd+alt+ctrl+A">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea onchange="updatePropertyHandler('%s', 'description', this.value)">%s</textarea>
                </div>
            ]], self.currentSelection.shortcut or "", self.currentSelection.id,
                self.currentSelection.id, self.currentSelection.description or "")

        elseif self.currentSelection.type == "sequence" then
            propertiesHtml = propertiesHtml .. string.format([[
                <div class="form-group">
                    <label>Delay Between Steps (ms)</label>
                    <input type="number" value="%s" onchange="updatePropertyHandler('%s', 'delay', this.value)" min="0">
                </div>
                <div class="form-group">
                    <label>Run in Background</label>
                    <input type="checkbox" %s onchange="updatePropertyHandler('%s', 'background', this.checked)">
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
        hs.logger:e("Could not find target item: " .. data.targetId)
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
    -- JavaScript bridge implementation for WebView
    local bridgeJS = [[
        console.log("Setting up HammerGhost JavaScript bridge...");
        
        // Create the bridge object first
        window.bridge = {
            sendCommand: function(action, params) {
                // Convert parameters to query string
                let queryParams = '';
                if (params) {
                    queryParams = Object.entries(params)
                        .map(([key, value]) => {
                            // Ensure value is properly converted to string
                            if (value === null || value === undefined) {
                                value = '';
                            } else if (typeof value === 'boolean') {
                                value = value ? 'true' : 'false';
                            }
                            return encodeURIComponent(key) + '=' + encodeURIComponent(value);
                        })
                        .join('&');
                }

                // Create the hammerspoon:// URL with action as the host
                const url = 'hammerspoon://' + action + (queryParams ? '?' + queryParams : '');
                console.log("Sending command via bridge:", url);

                // Navigate to the URL to trigger Hammerspoon handler
                window.location.href = url;
                return true;
            }
        };
        
        // Make sendCommand available at both window level and bridge level for compatibility
        window.sendCommand = function(action, params) {
            console.log("Calling window.sendCommand, redirecting to bridge");
            return window.bridge.sendCommand(action, params);
        };

        // Item selection handler
        window.selectItemHandler = function(id) {
            console.log("Selecting item:", id);
            return window.bridge.sendCommand('selectItem', { id: id });
        };

        // Item toggle handler
        window.toggleItemHandler = function(id) {
            console.log("Toggling item:", id);
            return window.bridge.sendCommand('toggleItem', { id: id });
        };

        // Edit item handler
        window.editItemHandler = function(id, name) {
            console.log("Editing item:", id, name);
            const newName = prompt("Edit item name:", name);
            if (newName !== null && newName !== name) {
                return window.bridge.sendCommand('editItem', { id: id, name: newName });
            }
            return false;
        };

        // Delete item handler
        window.deleteItemHandler = function(id, name) {
            console.log("Deleting item:", id, name);
            const confirmed = confirm("Are you sure you want to delete '" + name + "'?");
            if (confirmed) {
                return window.bridge.sendCommand('deleteItem', { id: id });
            }
            return false;
        };

        // Update property handler
        window.updatePropertyHandler = function(id, property, value) {
            console.log("Updating property:", id, property, value);
            return window.bridge.sendCommand('updateProperty', { id: id, property: property, value: value });
        };

        // Drag and drop support
        window.startDrag = function(event, id) {
            event.dataTransfer.setData("text/plain", id);
            event.dataTransfer.effectAllowed = "move";
            console.log("Started dragging item:", id);
        };

        window.endDrag = function(event) {
            event.preventDefault();
            console.log("Drag ended");
        };

        window.dragOver = function(event) {
            event.preventDefault();
            event.dataTransfer.dropEffect = "move";
        };

        window.drop = function(event, targetId, position) {
            event.preventDefault();
            const sourceId = event.dataTransfer.getData("text/plain");
            console.log("Drop - Source:", sourceId, "Target:", targetId, "Position:", position);

            if (sourceId && targetId) {
                return window.bridge.sendCommand('moveItem', {
                    sourceId: sourceId,
                    targetId: targetId,
                    position: position
                });
            }
            return false;
        };

        console.log("HammerGhost JavaScript bridge setup complete!");
    ]]

    -- Inject the bridge JavaScript into the WebView
    self.window:evaluateJavaScript(bridgeJS, function(result, error)
        if error then
            self.logger:e("Failed to inject JavaScript bridge: " .. hs.inspect(error))
        else
            self.logger:i("JavaScript bridge injected successfully")
        end
    end)
    return self
end

function obj:getHTML()
    local template = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HammerGhost</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0;
            padding: 10px;
            background-color: #f5f5f7;
            color: #333;
        }
        h1 {
            font-size: 24px;
            margin-bottom: 16px;
            color: #000;
        }
        ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        li {
            padding: 10px 15px;
            margin-bottom: 8px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            cursor: pointer;
            position: relative;
        }
        li:hover {
            background-color: #f0f0f5;
        }
        li.selected {
            background-color: #e6f7ff;
            border-left: 4px solid #1890ff;
        }
        li.dragging {
            opacity: 0.5;
        }
        .item-label {
            flex-grow: 1;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .item-check {
            margin-right: 10px;
            width: 20px;
            height: 20px;
            cursor: pointer;
        }
        .item-actions {
            display: none;
            margin-left: 10px;
        }
        li:hover .item-actions {
            display: flex;
        }
        .item-action {
            padding: 5px;
            margin-left: 5px;
            cursor: pointer;
            color: #666;
            border-radius: 4px;
        }
        .item-action:hover {
            background-color: rgba(0,0,0,0.05);
            color: #000;
        }
        .drop-indicator {
            background-color: #1890ff;
            height: 2px;
            position: absolute;
            left: 0;
            right: 0;
            display: none;
        }
        .drop-indicator.top {
            top: 0;
        }
        .drop-indicator.bottom {
            bottom: 0;
        }
        .drop-indicator.visible {
            display: block;
        }
        .add-item {
            margin-top: 16px;
            display: flex;
        }
        .add-input {
            flex-grow: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px 0 0 8px;
            font-size: 14px;
        }
        .add-button {
            background-color: #007aff;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 0 8px 8px 0;
            cursor: pointer;
            font-size: 14px;
        }
        .add-button:hover {
            background-color: #0066cc;
        }
    </style>
</head>
<body>
    <h1>HammerGhost</h1>
    <div id="app">
        <ul id="item-list">
            <!-- Item template -->
            <template id="item-template">
                <li class="item"
                    data-id=""
                    onclick="selectItemHandler(this.dataset.id)"
                    draggable="true"
                    ondragstart="startDrag(event, this.dataset.id)"
                    ondragend="endDrag(event)"
                    ondragover="dragOver(event)"
                    ondrop="drop(event, this.dataset.id, 'middle')">
                    <input type="checkbox" class="item-check" onclick="event.stopPropagation(); toggleItemHandler(this.parentNode.dataset.id)">
                    <span class="item-label"></span>
                    <div class="item-actions">
                        <span class="item-action edit-action"
                              onclick="event.stopPropagation(); editItemHandler(this.parentNode.parentNode.dataset.id, this.parentNode.parentNode.querySelector('.item-label').textContent)">✏️</span>
                        <span class="item-action delete-action"
                              onclick="event.stopPropagation(); deleteItemHandler(this.parentNode.parentNode.dataset.id, this.parentNode.parentNode.querySelector('.item-label').textContent)">🗑️</span>
                    </div>
                    <div class="drop-indicator top"></div>
                    <div class="drop-indicator bottom"></div>
                </li>
            </template>
        </ul>

        <div class="add-item">
            <input type="text" id="new-item-input" class="add-input" placeholder="Add new item...">
            <button id="add-item-button" class="add-button">Add</button>
        </div>
    </div>

    <script>
        // Handler functions that use the JavaScript bridge
        function selectItemHandler(itemId) {
            console.log('Item selected:', itemId);
            window.bridge.sendCommand('selectItem', { id: itemId });
        }

        function toggleItemHandler(itemId) {
            console.log('Toggle item:', itemId);
            window.bridge.sendCommand('toggleItem', { id: itemId });
        }

        function editItemHandler(itemId, label) {
            console.log('Edit item:', itemId, label);
            window.bridge.sendCommand('editItem', { id: itemId, label: label });
        }

        function deleteItemHandler(itemId, label) {
            console.log('Delete item:', itemId, label);
            window.sendCommand('deleteItem', { id: itemId });
        }

        function startDrag(event, itemId) {
            const item = event.target.closest('li');
            item.classList.add('dragging');
            event.dataTransfer.setData('text/plain', itemId);
            event.dataTransfer.effectAllowed = 'move';
        }

        function endDrag(event) {
            document.querySelectorAll('.dragging').forEach(el => {
                el.classList.remove('dragging');
            });
            document.querySelectorAll('.drop-indicator').forEach(el => {
                el.classList.remove('visible');
            });
        }

        function dragOver(event) {
            event.preventDefault();
            const item = event.target.closest('li');
            if (!item) return;

            event.dataTransfer.dropEffect = 'move';

            // Get mouse position relative to the item
            const rect = item.getBoundingClientRect();
            const y = event.clientY - rect.top;

            // Hide all indicators
            document.querySelectorAll('.drop-indicator').forEach(el => {
                el.classList.remove('visible');
            });

            if (y < rect.height / 2) {
                item.querySelector('.drop-indicator.top').classList.add('visible');
            } else {
                item.querySelector('.drop-indicator.bottom').classList.add('visible');
            }
        }

        function drop(event, targetId, position) {
            event.preventDefault();
            const draggedId = event.dataTransfer.getData('text/plain');
            if (draggedId === targetId) return; // Can't drop onto self

            console.log('Drop:', draggedId, 'onto', targetId, 'at', position);

            // Hide indicators
            document.querySelectorAll('.drop-indicator').forEach(el => {
                el.classList.remove('visible');
            });

            // Determine drop position
            let dropPosition = position;
            if (position === 'middle') {
                const rect = event.target.closest('li').getBoundingClientRect();
                const y = event.clientY - rect.top;
                dropPosition = y < rect.height / 2 ? 'before' : 'after';
            }

            // Use bridge to move item
            window.bridge.sendCommand('moveItem', {
                id: draggedId,
                targetId: targetId,
                position: dropPosition
            });
        }

        // We'll use the data from the Hammerspoon bridge
        document.addEventListener('DOMContentLoaded', function() {
            // Render items using data from bridge
            if (window.bridge) {
                renderItemList();
            } else {
                console.error('Bridge not available');
                // Show sample data for testing
                renderSampleData();
            }

            // Set up event listeners
            document.getElementById('add-item-button').addEventListener('click', addNewItem);
            document.getElementById('new-item-input').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    addNewItem();
                }
            });

            // Set up drop zones
            setupDropZones();
        });

        function renderItemList() {
            const itemList = document.getElementById('item-list');
            itemList.innerHTML = ''; // Clear existing items

            try {
                // Get data from bridge
                const items = JSON.parse(window.bridge.getItems());
                renderItems(items);
            } catch (err) {
                console.error('Error getting items from bridge:', err);
                renderSampleData();
            }
        }

        function renderSampleData() {
            const items = [
                { id: '1', label: 'Sample Item 1', checked: false },
                { id: '2', label: 'Sample Item 2', checked: true },
                { id: '3', label: 'Sample Item 3', checked: false }
            ];
            renderItems(items);
        }

        function renderItems(items) {
            const itemList = document.getElementById('item-list');

            // Render each item
            items.forEach(item => {
                const template = document.getElementById('item-template');
                const clone = document.importNode(template.content, true);

                const li = clone.querySelector('li');
                li.dataset.id = item.id;

                const checkbox = clone.querySelector('.item-check');
                checkbox.checked = item.checked;

                const label = clone.querySelector('.item-label');
                label.textContent = item.label;

                itemList.appendChild(clone);
            });
        }

        function addNewItem() {
            const input = document.getElementById('new-item-input');
            const value = input.value.trim();

            if (value) {
                // Send to bridge
                if (window.bridge) {
                    window.bridge.sendCommand('addItem', { label: value });
                    input.value = '';
                    renderItemList(); // Refresh the list
                } else {
                    console.log('Adding new item:', value);
                    input.value = '';

                    // For demo purposes, just add to the UI
                    const template = document.getElementById('item-template');
                    const clone = document.importNode(template.content, true);

                    const li = clone.querySelector('li');
                    li.dataset.id = 'new-' + Date.now();

                    const label = clone.querySelector('.item-label');
                    label.textContent = value;

                    document.getElementById('item-list').appendChild(clone);
                }
            }
        }

        function setupDropZones() {
            const list = document.getElementById('item-list');

            // Add drop zone at the beginning of the list
            const firstDropZone = document.createElement('div');
            firstDropZone.className = 'drop-zone top-zone';
            firstDropZone.style.height = '10px';
            firstDropZone.ondragover = (e) => { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; };
            firstDropZone.ondrop = (e) => { drop(e, null, 'top'); };

            list.insertBefore(firstDropZone, list.firstChild);
        }
    </script>
</body>
</html>
]]
    return template
end

-- Callback setters

-- Set callback for item selection
function obj:setOnSelectCallback(callback)
    self.callbacks.onSelect = callback
    return self
end

-- Set callback for item toggling
function obj:setOnToggleCallback(callback)
    self.callbacks.onToggle = callback
    return self
end

-- Set callback for item editing
function obj:setOnEditCallback(callback)
    self.callbacks.onEdit = callback
    return self
end

-- Set callback for item deletion
function obj:setOnDeleteCallback(callback)
    self.callbacks.onDelete = callback
    return self
end

-- Set callback for item movement
function obj:setOnMoveCallback(callback)
    self.callbacks.onMove = callback
    return self
end

-- Set callback for item addition
function obj:setOnAddCallback(callback)
    self.callbacks.onAdd = callback
    return self
end

-- Add a test method for URL handling
function obj:testURLHandling()
    self.logger:i("Testing URL handling")

    -- Create a simple test item if none exists
    if #self.macroTree == 0 then
        self:createMacroItem("Test Folder", "folder")
        self.logger:i("Created test folder with ID: " .. self.macroTree[1].id)
    end

    -- Try to select the first item using the URL scheme
    local itemId = self.macroTree[1].id
    local testURL = "hammerspoon://selectItem?id=" .. itemId
    self.logger:i("Testing URL: " .. testURL)

    -- Open the URL to trigger the handler
    hs.execute("open '" .. testURL .. "'")

    return self
end

-- Add a test method to debug all URL handlers
function obj:testAllURLHandlers()
    self.logger:i("Testing all URL handlers")

    -- Create test data for each URL handler
    local tests = {
        {
            name = "selectItem",
            params = { id = "test-id-1" }
        },
        {
            name = "toggleItem",
            params = { id = "test-id-1" }
        },
        {
            name = "editItem",
            params = { id = "test-id-1", name = "New Test Name" }
        },
        {
            name = "deleteItem",
            params = { id = "test-id-1" }
        },
        {
            name = "moveItem",
            params = { sourceId = "test-id-1", targetId = "test-id-2", position = "after" }
        },
        {
            name = "updateProperty",
            params = { id = "test-id-1", property = "name", value = "New Value" }
        },
        {
            name = "openActionEditor",
            params = {}
        }
    }

    -- Execute each test
    for _, test in ipairs(tests) do
        self.logger:i("Testing URL handler: " .. test.name)

        -- Convert parameters to query string
        local queryParams = {}
        for k, v in pairs(test.params) do
            table.insert(queryParams, string.format("%s=%s",
                hs.http.encodeForQuery(k),
                hs.http.encodeForQuery(tostring(v)))
            )
        end

        local queryStr = table.concat(queryParams, "&")
        local testURL = "hammerspoon://" .. test.name
        if queryStr ~= "" then
            testURL = testURL .. "?" .. queryStr
        end

        self.logger:i("Test URL: " .. testURL)

        -- Call the handler directly
        hs.urlevent.handleURLEvent(test.name, test.params)
    end

    return self
end

-- Add tracing hook to the hs.urlevent module
function obj:addURLTracing()
    self.logger:i("Adding URL event tracing")

    -- Save original function
    local originalHandleURLEvent = hs.urlevent.handleURLEvent

    -- Replace with tracing wrapper
    hs.urlevent.handleURLEvent = function(eventName, params)
        self.logger:i("URL Event Trace: " .. eventName .. " with params: " .. hs.inspect(params))
        return originalHandleURLEvent(eventName, params)
    end

    return self
end
-- Return the object
return obj
