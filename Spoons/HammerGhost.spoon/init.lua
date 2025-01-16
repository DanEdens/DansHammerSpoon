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
    self.window:show()
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
        toggle = hs.fnutils.partial(self.toggleWindow, self),
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
    self.window = hs.webview.new({
        x = frame.x + (frame.w * 0.1),
        y = frame.y + (frame.h * 0.1),
        w = frame.w * 0.8,
        h = frame.h * 0.8
    })
    
    -- Set up webview
    self.window:windowTitle("HammerGhost")
    self.window:windowStyle("closable,titled,resizable")
    self.window:allowTextEntry(true)
    self.window:darkMode(true)
    
    -- Load HTML content
    local htmlFile = io.open(hs.spoons.resourcePath("assets/index.html"), "r")
    if htmlFile then
        local content = htmlFile:read("*all")
        htmlFile:close()
        self.window:html(content)
    end
    
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

-- Return the object
return obj 
