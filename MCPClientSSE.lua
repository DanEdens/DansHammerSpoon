-- MCPClientSSE.lua - Server-Sent Events client for communicating with MCP servers
-- Provides real-time streaming updates from Omnispindle MCP server

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.MCPClientSSE then
    log:d('Returning existing MCPClientSSE module')
    return _G.MCPClientSSE
end

log:i('Initializing MCP SSE client for real-time project management')

local MCPClientSSE = {
    -- Configuration
    serverUrl = os.getenv("MCP_SERVER_URL"),
    timeout = 30,                            -- Extended timeout for SSE connections

    -- SSE Connection state
    sseConnection = nil,
    isConnected = false,
    reconnectAttempts = 0,
    maxReconnectAttempts = 5,
    reconnectDelay = 5, -- seconds

    -- Event callbacks
    eventCallbacks = {},

    -- Data caches
    projectsCache = nil,
    todosCache = nil,
    lessonsCache = nil,
    cacheTimestamp = 0,
    cacheTimeout = 300, -- 5 minutes

    -- Event handlers
    onProjectUpdate = nil,
    onTodoUpdate = nil,
    onConnectionStatus = nil
}

-- Initialize SSE client with configuration
function MCPClientSSE.init(config)
    log:d('Initializing MCP SSE client with config')
    config = config or {}

    if config.serverUrl then
        MCPClientSSE.serverUrl = config.serverUrl
    end

    if config.timeout then
        MCPClientSSE.timeout = config.timeout
    end

    if config.onProjectUpdate then
        MCPClientSSE.onProjectUpdate = config.onProjectUpdate
    end

    if config.onTodoUpdate then
        MCPClientSSE.onTodoUpdate = config.onTodoUpdate
    end

    if config.onConnectionStatus then
        MCPClientSSE.onConnectionStatus = config.onConnectionStatus
    end

    log:i('MCP SSE client initialized with server: ' .. MCPClientSSE.serverUrl)
    return true
end

-- Parse SSE event data
function MCPClientSSE.parseSSEEvent(data)
    log:d('Parsing SSE event data')

    if not data or data == "" then
        return nil
    end

    -- SSE data format: "data: {json}\n\n"
    local jsonData = data:match("data:%s*(.+)")
    if not jsonData then
        log:w('Could not extract JSON from SSE data: ' .. data)
        return nil
    end

    local success, parsed = pcall(function()
        return hs.json.decode(jsonData)
    end)

    if success then
        log:d('Successfully parsed SSE event: ' .. (parsed.event or 'unknown'))
        return parsed
    else
        log:w('Failed to parse SSE JSON: ' .. (parsed or "unknown error"))
        return nil
    end
end

-- Handle SSE events
function MCPClientSSE.handleSSEEvent(eventData)
    if not eventData then return end

    local eventType = eventData.event or eventData.type
    log:d('Handling SSE event: ' .. (eventType or 'unknown'))

    -- Update caches based on event type
    if eventType == "project_update" or eventType == "projects_changed" then
        log:i('Received project update event')
        MCPClientSSE.projectsCache = nil -- Invalidate cache

        if MCPClientSSE.onProjectUpdate then
            MCPClientSSE.onProjectUpdate(eventData.data)
        end
    elseif eventType == "todo_update" or eventType == "todos_changed" then
        log:i('Received todo update event')
        MCPClientSSE.todosCache = nil -- Invalidate cache

        if MCPClientSSE.onTodoUpdate then
            MCPClientSSE.onTodoUpdate(eventData.data)
        end
    elseif eventType == "connection" or eventType == "ping" then
        log:d('Received connection/ping event')
    elseif eventType == "error" then
        log:w('Received error event: ' .. (eventData.message or "unknown error"))
    else
        log:d('Received unknown event type: ' .. (eventType or 'unknown'))
    end

    -- Call any registered event callbacks
    local callbacks = MCPClientSSE.eventCallbacks[eventType] or {}
    for _, callback in ipairs(callbacks) do
        pcall(callback, eventData)
    end
end

-- Start SSE connection
function MCPClientSSE.startSSEConnection()
    log:i('Starting SSE connection to: ' .. MCPClientSSE.serverUrl)

    -- For now, we'll simulate SSE using periodic HTTP requests
    -- Hammerspoon doesn't have native SSE support, so we'll poll with long timeout
    MCPClientSSE.simulateSSE()
end

-- Simulate SSE using periodic requests (Hammerspoon limitation workaround)
function MCPClientSSE.simulateSSE()
    log:d('Simulating SSE connection with periodic requests')

    -- Create a timer for periodic updates
    if MCPClientSSE.sseConnection then
        MCPClientSSE.sseConnection:stop()
    end

    MCPClientSSE.sseConnection = hs.timer.doEvery(99999, function()
        -- Check for updates every 10 seconds
        MCPClientSSE.checkForUpdates()
    end)

    MCPClientSSE.isConnected = true
    log:i('SSE simulation started with 10-second intervals')

    if MCPClientSSE.onConnectionStatus then
        MCPClientSSE.onConnectionStatus(true, "SSE simulation started")
    end
end

-- Check for updates (SSE simulation)
function MCPClientSSE.checkForUpdates()
    -- log:d('Checking for updates from MCP server')

    -- Make a request to check for updates
    local url = MCPClientSSE.serverUrl .. "/api/updates"
    local success, result = pcall(function()
        local status, response = hs.http.doRequest(url, "GET", nil, {
            ["Accept"] = "application/json",
            ["Cache-Control"] = "no-cache"
        }, 5) -- Short timeout for update checks

        if status == 200 then
            return hs.json.decode(response)
        else
            return nil
        end
    end)

    if success and result then
        -- Simulate receiving SSE events
        if result.projects_updated then
            MCPClientSSE.handleSSEEvent({
                event = "project_update",
                data = result.projects
            })
        end

        if result.todos_updated then
            MCPClientSSE.handleSSEEvent({
                event = "todo_update",
                data = result.todos
            })
        end
    end
end

-- Stop SSE connection
function MCPClientSSE.stopSSEConnection()
    log:i('Stopping SSE connection')

    if MCPClientSSE.sseConnection then
        MCPClientSSE.sseConnection:stop()
        MCPClientSSE.sseConnection = nil
    end

    MCPClientSSE.isConnected = false

    if MCPClientSSE.onConnectionStatus then
        MCPClientSSE.onConnectionStatus(false, "SSE connection stopped")
    end
end

-- Get projects list with real-time updates
function MCPClientSSE.getProjectsList(forceRefresh)
    log:d('Getting projects list from MCP SSE server')

    -- Check cache first
    local currentTime = os.time()
    if not forceRefresh and MCPClientSSE.projectsCache and
        (currentTime - MCPClientSSE.cacheTimestamp) < MCPClientSSE.cacheTimeout then
        log:d('Returning cached projects list')
        return { success = true, data = MCPClientSSE.projectsCache, cached = true }
    end

    -- Make request to MCP server
    local url = MCPClientSSE.serverUrl .. "/api/projects"
    local success, result = pcall(function()
        local status, response = hs.http.doRequest(url, "GET", nil, {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }, MCPClientSSE.timeout)

        if status == 200 then
            local data = hs.json.decode(response)
            return { success = true, data = data }
        else
            log:w('MCP request failed with status: ' .. status)
            return { success = false, error = "HTTP " .. status, response = response }
        end
    end)

    if success and result.success then
        -- Update cache
        MCPClientSSE.projectsCache = result.data.projects or result.data
        MCPClientSSE.cacheTimestamp = currentTime
        log:i('Retrieved ' .. #MCPClientSSE.projectsCache .. ' projects from MCP SSE server')
        return result
    else
        log:w('Failed to get projects from MCP SSE server: ' .. (result and result.error or "unknown error"))

        -- Return cached data if available as fallback
        if MCPClientSSE.projectsCache then
            log:w('Returning cached projects as fallback')
            return { success = true, data = MCPClientSSE.projectsCache, cached = true }
        end

        return result or { success = false, error = "Request failed" }
    end
end

-- Convert MCP project list to FileManager format for compatibility
function MCPClientSSE.convertToFileManagerFormat(mcpProjects)
    log:d('Converting MCP projects to FileManager format')

    local converted = {}
    for _, project in ipairs(mcpProjects) do
        table.insert(converted, {
            name = project,
            path = "~/lab/madness_interactive/projects/" .. project:lower(),
            description = "Project from centralized MCP SSE server"
        })
    end

    log:d('Converted ' .. #converted .. ' projects to FileManager format')
    return converted
end

-- Get projects list in FileManager compatible format
function MCPClientSSE.getProjectsListForFileManager(forceRefresh)
    log:d('Getting projects list for FileManager compatibility')

    local result = MCPClientSSE.getProjectsList(forceRefresh)

    if result.success then
        local converted = MCPClientSSE.convertToFileManagerFormat(result.data)
        return { success = true, data = converted, cached = result.cached }
    else
        return result
    end
end

-- Test connection to MCP server
function MCPClientSSE.testConnection()
    log:d('Testing MCP SSE server connection')

    local url = MCPClientSSE.serverUrl .. "/api/health"
    local success, result = pcall(function()
        local status, response = hs.http.doRequest(url, "GET", nil, {
            ["Accept"] = "application/json"
        }, 5) -- Quick timeout for connection test

        return status == 200
    end)

    if success and result then
        log:i('MCP SSE server connection test successful')
        return true
    else
        log:w('MCP SSE server connection test failed')
        return false
    end
end

-- Register event callback
function MCPClientSSE.addEventListener(eventType, callback)
    log:d('Registering event listener for: ' .. eventType)

    if not MCPClientSSE.eventCallbacks[eventType] then
        MCPClientSSE.eventCallbacks[eventType] = {}
    end

    table.insert(MCPClientSSE.eventCallbacks[eventType], callback)
end

-- Clear projects cache
function MCPClientSSE.clearCache()
    log:d('Clearing MCP SSE caches')
    MCPClientSSE.projectsCache = nil
    MCPClientSSE.todosCache = nil
    MCPClientSSE.lessonsCache = nil
    MCPClientSSE.cacheTimestamp = 0
end

-- Get connection status
function MCPClientSSE.getConnectionStatus()
    return {
        connected = MCPClientSSE.isConnected,
        serverUrl = MCPClientSSE.serverUrl,
        reconnectAttempts = MCPClientSSE.reconnectAttempts
    }
end

-- Initialize the module
log:i('MCP SSE client module loaded successfully')

-- Make module globally accessible
_G.MCPClientSSE = MCPClientSSE

return MCPClientSSE
