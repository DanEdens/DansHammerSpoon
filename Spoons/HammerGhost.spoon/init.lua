--- === HammerGhost ===
---
--- EventGhost-like macro editor for Hammerspoon
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
obj.macroTree = {}
obj.configPath = hs.configdir .. "/hammerghost_config.json"

--- HammerGhost:init()
--- Method
--- Initialize the spoon
function obj:init()
    -- Load saved macros if they exist
    if hs.fs.attributes(self.configPath) then
        local f = io.open(self.configPath, "r")
        if f then
            local content = f:read("*all")
            f:close()
            self.macroTree = hs.json.decode(content) or {}
        end
    end
    return self
end

--- HammerGhost:createTreeItem(name, type, icon, fn)
--- Method
--- Create a new tree item (action, folder, or sequence)
function obj:createTreeItem(name, type, icon, fn)
    return {
        name = name,
        type = type,
        icon = icon,
        fn = fn,
        expanded = false,
        items = {},
        steps = {}
    }
end

--- HammerGhost:addItem(item, parentPath)
--- Method
--- Add an item to the macro tree at the specified path
function obj:addItem(item, parentPath)
    local current = self.macroTree
    if parentPath then
        for _, name in ipairs(parentPath) do
            for _, existingItem in ipairs(current) do
                if existingItem.name == name then
                    current = existingItem.items
                    break
                end
            end
        end
    end
    table.insert(current, item)
    self:saveConfig()
    self:refreshWindow()
end

--- HammerGhost:saveConfig()
--- Method
--- Save the current macro configuration to disk
function obj:saveConfig()
    local f = io.open(self.configPath, "w")
    if f then
        f:write(hs.json.encode(self.macroTree))
        f:close()
    end
end

--- HammerGhost:buildTreeHTML(items, depth)
--- Method
--- Build HTML representation of the tree
function obj:buildTreeHTML(items, depth)
    depth = depth or 0
    local html = ""
    for i, item in ipairs(items) do
        local indent = string.rep("    ", depth)
        local icon = ""
        if item.type == "folder" then
            icon = item.expanded and "📂" or "📁"
        elseif item.type == "action" then
            icon = item.icon or "⚡"
        elseif item.type == "sequence" then
            icon = item.icon or "⚙️"
        end
        
        html = html .. string.format([[
            <div class="tree-item" data-index="%d" data-depth="%d" data-type="%s">
                <span class="icon">%s</span>
                <span class="name">%s</span>
                <div class="actions">
                    <button onclick="editItem(%d)">✏️</button>
                    <button onclick="deleteItem(%d)">🗑️</button>
                </div>
            </div>
        ]], i, depth, item.type, icon, item.name, i, i)
        
        if item.expanded then
            if item.type == "folder" and item.items then
                html = html .. self:buildTreeHTML(item.items, depth + 1)
            elseif item.type == "sequence" and item.steps then
                html = html .. self:buildTreeHTML(item.steps, depth + 1)
            end
        end
    end
    return html
end

--- HammerGhost:show()
--- Method
--- Show or hide the HammerGhost window
function obj:show()
    if self.window then
        self.window:delete()
        self.window = nil
        return
    end

    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    
    -- Create the window
    self.window = hs.webview.new({x = frame.w - 400, y = 100, w = 380, h = 600})
    self.window:windowStyle({"titled", "closable", "resizable"})
    self.window:titleVisibility("visible")
    self.window:title("HammerGhost")
    
    -- Set up the HTML content
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    background-color: #1e1e1e;
                    color: #d4d4d4;
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
                    margin: 0;
                    padding: 10px;
                    user-select: none;
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
                    background-color: #2d2d2d;
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
                }
                .tree-item:hover .actions {
                    opacity: 1;
                }
                .tree-item button {
                    background: none;
                    border: none;
                    cursor: pointer;
                    font-size: 14px;
                    padding: 2px 4px;
                    margin-left: 4px;
                }
                .toolbar {
                    padding: 10px;
                    border-bottom: 1px solid #333;
                    margin-bottom: 10px;
                }
                .toolbar button {
                    background-color: #2d2d2d;
                    border: 1px solid #404040;
                    color: #d4d4d4;
                    padding: 6px 12px;
                    border-radius: 4px;
                    cursor: pointer;
                    margin-right: 8px;
                }
                .toolbar button:hover {
                    background-color: #404040;
                }
            </style>
        </head>
        <body>
            <div class="toolbar">
                <button onclick="addFolder()">New Folder</button>
                <button onclick="addAction()">New Action</button>
                <button onclick="addSequence()">New Sequence</button>
            </div>
            <div id="tree">
            ]] .. self:buildTreeHTML(self.macroTree) .. [[
            </div>
            <script>
                function addFolder() {
                    webkit.messageHandlers.addFolder.postMessage("");
                }
                function addAction() {
                    webkit.messageHandlers.addAction.postMessage("");
                }
                function addSequence() {
                    webkit.messageHandlers.addSequence.postMessage("");
                }
                function editItem(index) {
                    webkit.messageHandlers.editItem.postMessage(index);
                }
                function deleteItem(index) {
                    webkit.messageHandlers.deleteItem.postMessage(index);
                }
                function toggleItem(index) {
                    webkit.messageHandlers.toggleItem.postMessage(index);
                }
            </script>
        </body>
        </html>
    ]]
    
    -- Set up message handlers
    self.window:setCallback(function(action, data)
        if action == "addFolder" then
            local name = hs.dialog.textPrompt("New Folder", "Enter folder name:", "", "OK", "Cancel")
            if name and name ~= "" then
                self:addItem(self:createTreeItem(name, "folder", "📁"))
            end
        elseif action == "addAction" then
            local name = hs.dialog.textPrompt("New Action", "Enter action name:", "", "OK", "Cancel")
            if name and name ~= "" then
                self:addItem(self:createTreeItem(name, "action", "⚡"))
            end
        elseif action == "addSequence" then
            local name = hs.dialog.textPrompt("New Sequence", "Enter sequence name:", "", "OK", "Cancel")
            if name and name ~= "" then
                self:addItem(self:createTreeItem(name, "sequence", "⚙️"))
            end
        elseif action == "editItem" then
            -- TODO: Implement item editing
        elseif action == "deleteItem" then
            -- TODO: Implement item deletion
        elseif action == "toggleItem" then
            -- TODO: Implement item expansion/collapse
        end
    end)
    
    self.window:html(html)
    self.window:show()
end

--- HammerGhost:refreshWindow()
--- Method
--- Refresh the window content
function obj:refreshWindow()
    if self.window then
        self.window:html(self:buildTreeHTML(self.macroTree))
    end
end

--- HammerGhost:bindHotkeys(mapping)
--- Method
--- Bind hotkeys for HammerGhost
---
--- Parameters:
---  * mapping - A table containing hotkey objifier/key details for the following items:
---   * toggle - Toggle the HammerGhost window
function obj:bindHotkeys(mapping)
    local def = {
        toggle = hs.fnutils.partial(self.show, self)
    }
    hs.spoons.bindHotkeysToSpec(def, mapping)
    return self
end

return obj 
