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
obj.spoonPath = hs.spoons.scriptPath()

-- Load additional modules
dofile(hs.spoons.resourcePath("scripts/xmlparser.lua"))

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
        if self.window:_window():isVisible() then
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
    webview:windowStyle("closable,titled,resizable")
    webview:allowTextEntry(true)
    webview:darkMode(true)

    -- Set up message handlers
    webview:setCallback(function(action, data)
        if action == "selectItem" then
            self:selectItem(data)
        elseif action == "toggleItem" then
            self:toggleItem(data)
        elseif action == "editItem" then
            self:editItem(data)
        elseif action == "deleteItem" then
            self:deleteItem(data)
        end
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
    local toolbar = hs.webview.toolbar.new("HammerGhostToolbar", {
        { id = "addFolder", label = "New Folder", image = hs.image.imageFromPath(hs.spoons.resourcePath("assets/images/folder.png")) },
        { id = "addAction", label = "New Action", image = hs.image.imageFromPath(hs.spoons.resourcePath("assets/images/action.png")) },
        { id = "addSequence", label = "New Sequence", image = hs.image.imageFromPath(hs.spoons.resourcePath("assets/images/sequence.png")) },
        { id = "save", label = "Save", image = hs.image.imageFromPath(hs.spoons.resourcePath("assets/images/save.png")) }
    })
    
    toolbar:setCallback(function(toolbar, webview, id)
        if id == "addFolder" then
            self:addFolder()
        elseif id == "addAction" then
            self:addAction()
        elseif id == "addSequence" then
            self:addSequence()
        elseif id == "save" then
            self:saveConfig()
        end
    end)
    
    self.window:attachedToolbar(toolbar)
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
    -- TODO: Implement folder addition
    hs.logger.new("HammerGhost"):d("Adding new folder")
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
    -- TODO: Implement action addition
    hs.logger.new("HammerGhost"):d("Adding new action")
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
    -- TODO: Implement sequence addition
    hs.logger.new("HammerGhost"):d("Adding new sequence")
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
    -- TODO: Implement XML saving
    hs.logger.new("HammerGhost"):d("Saving configuration")
end

-- Return the object
return obj 
