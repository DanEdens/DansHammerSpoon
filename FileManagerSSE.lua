-- FileManagerSSE.lua - Enhanced file management with SSE real-time updates
-- Using SSE-based MCP client for real-time project management
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.FileManagerSSE then
    log:d('Returning existing FileManagerSSE module')
    return _G.FileManagerSSE
end

log:i('Initializing SSE-enhanced file management system')

-- Try to load MCP SSE client for real-time project management
local MCPClientSSE
local sseClientAvailable = false
local success, sseClientModule = pcall(function()
    return require('MCPClientSSE')
end)

if success and sseClientModule then
    MCPClientSSE = sseClientModule
    sseClientAvailable = true
    log:i('MCP SSE client loaded successfully for real-time project management')
else
    log:w('MCP SSE client not available, falling back to basic mode: ' .. (sseClientModule or "unknown error"))
end

-- Configuration
local editor = "cursor"
local seatOfMadness = "/Users/d.edens/lab/madness_interactive"
local seatOfTest = "/Users/d.edens/lab/regressiontestkit"

-- State
local selectedFile = nil
local fileChooser = nil
local lastSelected = {
    file = nil,
    project = nil,
    editor = nil
}

-- Real-time update state
local projectUpdateCallbacks = {}
local lastProjectUpdate = 0

local FileManagerSSE = {
    -- Project update tracking
    projectsLastModified = 0,
    isRealTimeEnabled = false
}

-- File Lists (static)
local fileList = {
    { name = "init.lua",       path = "~/.hammerspoon/init.lua" },
    { name = "global hotkeys", path = "~/.hammerspoon/hotkeys.lua" },
    { name = "zshenv",         path = "~/.zshenv" },
    { name = "File Manager",   path = "~/.hammerspoon/FileManagerSSE.lua" },
    { name = "zshrc",          path = "~/.zshrc" },
    { name = "bash_aliases",   path = "~/.bash_aliases" },
    { name = "goosehints",     path = "~/.config/goose/.goosehints" },
    { name = "tasks",          path = "~/lab/regressiontestkit/tasks.py" },
    { name = "ssh config",     path = "~/.ssh/config" },
    { name = "mad_rules",      path = seatOfMadness .. "/.cursor/rules" },
    { name = "swarmonomicon",  path = seatOfMadness .. "/projects/common/swarmonomicon/.cursorrules" },
}

-- Fallback projects list (used when SSE is unavailable)
local fallback_projects_list = {
    { name = "madness_interactive",   path = seatOfMadness },
    { name = ".hammerspoon",          path = "~/.hammerspoon" },
    { name = "Todomill_projectorium", path = seatOfMadness .. "/projects/python/Omnispindle/Todomill_projectorium" },
    { name = "Inventorium",           path = seatOfMadness .. "/projects/common/Inventorium" },
    { name = "Omnispindle",           path = seatOfMadness .. "/projects/python/Omnispindle" },
    { name = "Swarmonomicon",         path = seatOfMadness .. "/projects/common/Swarmonomicon" },
    { name = "lab",                   path = seatOfTest },
    { name = "regressiontestkit",     path = seatOfTest },
    { name = "hammerspoon-proj",      path = seatOfMadness .. "/projects/lua/hammerspoon" },
}

local editorList = {
    { name = "Visual Studio Code",        command = "code" },
    { name = "cursor",                    command = "cursor" },
    { name = "nvim",                      command = "nvim" },
    { name = "PyCharm Community Edition", command = "pycharm" }
}

-- Initialize SSE integration
function FileManagerSSE.initSSE()
    log:d('Initializing SSE integration for FileManager')

    if not sseClientAvailable then
        log:w('SSE client not available for initialization')
        return false
    end

    -- Configure SSE client with callbacks
    local config = {
        onProjectUpdate = FileManagerSSE.onProjectUpdate,
        onConnectionStatus = FileManagerSSE.onConnectionStatus
    }

    local success = MCPClientSSE.init(config)
    if success then
        -- Start SSE connection for real-time updates
        MCPClientSSE.startSSEConnection()
        FileManagerSSE.isRealTimeEnabled = true
        log:i('SSE integration initialized successfully')

        -- Show user notification
        hs.alert.show("Real-time project updates enabled")
    else
        log:w('Failed to initialize SSE client')
    end

    return success
end

-- Handle project updates from SSE
function FileManagerSSE.onProjectUpdate(projectData)
    log:i('Received real-time project update')

    -- Invalidate any cached project lists
    lastProjectUpdate = os.time()

    -- Notify any registered callbacks
    for _, callback in ipairs(projectUpdateCallbacks) do
        pcall(callback, projectData)
    end

    -- Show subtle notification to user
    hs.alert.show("Projects updated", 1)
end

-- Handle connection status changes
function FileManagerSSE.onConnectionStatus(connected, message)
    log:i('SSE connection status: ' .. (connected and "connected" or "disconnected") .. " - " .. message)

    if connected then
        FileManagerSSE.isRealTimeEnabled = true
    else
        FileManagerSSE.isRealTimeEnabled = false
        -- Show user notification about fallback
        hs.alert.show("Real-time updates offline, using cached data", 2)
    end
end

-- Register project update callback
function FileManagerSSE.addProjectUpdateCallback(callback)
    log:d('Registering project update callback')
    table.insert(projectUpdateCallbacks, callback)
end

-- Helper Functions
function FileManagerSSE.getEditor()
    log:d('Getting current editor: ' .. editor)
    return editor
end

function FileManagerSSE.setEditor(newEditor)
    log:i('Setting editor to: ' .. newEditor)
    editor = newEditor
    lastSelected.editor = newEditor
end

function FileManagerSSE.getProjectsList()
    log:d('Getting projects list with SSE support')

    -- Try to get projects from MCP SSE client first
    if sseClientAvailable then
        log:d('Attempting to get projects from MCP SSE client')
        local mcpResult = MCPClientSSE.getProjectsListForFileManager()

        if mcpResult and mcpResult.success and mcpResult.data then
            log:i('Retrieved ' .. #mcpResult.data .. ' projects from MCP SSE server' ..
                (mcpResult.cached and ' (cached)' or '') ..
                (FileManagerSSE.isRealTimeEnabled and ' [LIVE]' or ' [OFFLINE]'))
            return mcpResult.data
        else
            log:w('Failed to get projects from MCP SSE client: ' .. (mcpResult and mcpResult.error or "unknown error"))
        end
    end

    -- Fallback to hardcoded project list
    log:w('Using fallback hardcoded projects list')
    return fallback_projects_list
end

-- Force refresh projects from SSE server
function FileManagerSSE.refreshProjectsList()
    log:d('Refreshing projects list from MCP SSE server')

    if sseClientAvailable then
        log:d('Forcing refresh from MCP SSE client')
        local mcpResult = MCPClientSSE.getProjectsListForFileManager(true) -- Force refresh

        if mcpResult and mcpResult.success and mcpResult.data then
            log:i('Refreshed ' .. #mcpResult.data .. ' projects from MCP SSE server')
            hs.alert.show("Projects refreshed from MCP SSE server: " .. #mcpResult.data .. " projects" ..
                (FileManagerSSE.isRealTimeEnabled and " [LIVE]" or " [OFFLINE]"))
            return mcpResult.data
        else
            log:w('Failed to refresh projects from MCP SSE client: ' ..
            (mcpResult and mcpResult.error or "unknown error"))
            hs.alert.show("Failed to refresh projects from MCP SSE server")
            return nil
        end
    else
        log:w('MCP SSE client not available for refresh')
        hs.alert.show("MCP SSE client not available")
        return nil
    end
end

-- Test MCP SSE connectivity
function FileManagerSSE.testSSEConnection()
    log:d('Testing MCP SSE server connection')

    if sseClientAvailable then
        local connected = MCPClientSSE.testConnection()
        local status = MCPClientSSE.getConnectionStatus()

        if connected then
            log:i('MCP SSE server connection test successful')
            hs.alert.show("MCP SSE server connection: OK " ..
                (status.connected and "[LIVE UPDATES]" or "[OFFLINE]"))
        else
            log:w('MCP SSE server connection test failed')
            hs.alert.show("MCP SSE server connection: FAILED")
        end
        return connected
    else
        log:w('MCP SSE client not available for connection test')
        hs.alert.show("MCP SSE client not available")
        return false
    end
end

-- Start real-time updates
function FileManagerSSE.startRealTimeUpdates()
    log:i('Starting real-time project updates')

    if sseClientAvailable then
        MCPClientSSE.startSSEConnection()
        hs.alert.show("Real-time updates started")
    else
        hs.alert.show("SSE client not available")
    end
end

-- Stop real-time updates
function FileManagerSSE.stopRealTimeUpdates()
    log:i('Stopping real-time project updates')

    if sseClientAvailable then
        MCPClientSSE.stopSSEConnection()
        hs.alert.show("Real-time updates stopped")
    end
end

-- Get real-time status
function FileManagerSSE.getRealTimeStatus()
    if not sseClientAvailable then
        return {
            available = false,
            connected = false,
            message = "SSE client not available"
        }
    end

    local status = MCPClientSSE.getConnectionStatus()
    return {
        available = true,
        connected = status.connected,
        serverUrl = status.serverUrl,
        lastUpdate = lastProjectUpdate,
        message = status.connected and "Real-time updates active" or "Real-time updates offline"
    }
end

function FileManagerSSE.getLastSelected()
    log:d('Getting last selected item')
    return lastSelected
end

-- File Management Functions (unchanged from original FileManager)
function FileManagerSSE.openSelectedFile()
    if selectedFile ~= nil then
        log:i('Opening selected file: ' .. selectedFile.text .. ' with ' .. editor)
        lastSelected.file = selectedFile
        hs.execute("open -a '" .. editor .. "' " .. selectedFile.path)
    else
        log:w('No file selected, showing file menu')
        FileManagerSSE.showFileMenu()
    end
end

function FileManagerSSE.showFileMenu()
    log:i('Showing file selection menu')
    local choices = {}
    for _, file in ipairs(fileList) do
        table.insert(choices, {
            text = file.name,
            subText = "Edit this file",
            path = file.path
        })
    end

    if not fileChooser then
        log:d('Creating new file chooser')
        fileChooser = hs.chooser.new(function(choice)
            if choice then
                log:d('File selected: ' .. choice.text)
                selectedFile = choice
                lastSelected.file = choice
                FileManagerSSE.openSelectedFile()
                fileChooser:hide()
            else
                log:d('File selection canceled')
            end
        end)
    end
    fileChooser:choices(choices)
    fileChooser:show()
end

function FileManagerSSE.showEditorMenu()
    log:i('Showing editor selection menu')
    local choices = {}
    for _, editorOption in ipairs(editorList) do
        if editorOption and editorOption.name and editorOption.command then
            table.insert(choices, {
                text = editorOption.name,
                subText = "Select this editor",
                command = editorOption.command
            })
        else
            log:w('Invalid editor option found, skipping:', hs.inspect(editorOption))
        end
    end

    if #choices == 0 then
        log:e('No valid editor choices available')
        hs.alert.show("Error: No valid editors found")
        return
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            log:i('Editor selected: ' .. tostring(choice.text))
            editor = choice.command
            lastSelected.editor = choice
            hs.alert.show("Editor set to: " .. tostring(editor))
            chooser:hide()
        else
            log:d('Editor selection canceled')
        end
    end)

    chooser:choices(choices)
    chooser:show()
end

function FileManagerSSE.openMostRecentImage()
    log:i('Attempting to open most recent image from Desktop')
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    log:d('Desktop path: ' .. desktopPath)

    local cmd = string.format(
        "find '%s' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \\) -exec ls -t {} + | head -n 1",
        desktopPath)
    log:d('Executing command: ' .. cmd)

    local output, status, type, rc = hs.execute(cmd)

    if status and output and output ~= "" then
        local filePath = output:match("^%s*(.-)%s*$")
        if filePath and filePath ~= "" then
            log:i('Opening image: ' .. filePath)
            lastSelected.file = { name = "recent_image", path = filePath }
            local openCmd = string.format("open '%s'", filePath)
            log:d('Executing open command: ' .. openCmd)
            hs.execute(openCmd)
        else
            log:w('No valid file path found in command output')
            hs.alert.show("No recent images found on Desktop")
        end
    else
        log:w('Command failed or no images found. Status: ' .. tostring(status) .. ', RC: ' .. tostring(rc))
        hs.alert.show("No recent images found on Desktop")
    end
end

-- Initialize SSE on module load
if sseClientAvailable then
    -- Only auto-initialize if global MCP client is not already in SSE mode
    local globalMCPType = _G.MCPClientType
    if globalMCPType ~= "sse" then
        log:i('Global MCP client not in SSE mode, initializing FileManagerSSE independently')
        hs.timer.doAfter(1.0, function()
            FileManagerSSE.initSSE()
        end)
    else
        log:i('Global MCP client already in SSE mode, FileManagerSSE will use existing SSE client')
        -- Use the global SSE client instead of creating our own
        if _G.MCPClientSSE then
            MCPClientSSE = _G.MCPClientSSE
            FileManagerSSE.isRealTimeEnabled = true
            log:i('FileManagerSSE using global SSE client')
        end
    end
end

-- Save in global environment for module reuse
_G.FileManagerSSE = FileManagerSSE
return FileManagerSSE
