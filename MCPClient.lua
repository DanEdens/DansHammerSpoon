-- MCPClient.lua - HTTP client for communicating with MCP servers
-- Provides centralized project management by calling Omnispindle MCP server

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.MCPClient then
    log:d('Returning existing MCPClient module')
    return _G.MCPClient
end

log:i('Initializing MCP client for centralized project management')

local MCPClient = {
    -- Configuration
    mcpServerUrl = "http://localhost:8080", -- Default MCP server URL
    timeout = 10,                           -- Request timeout in seconds

    -- Cache for project list
    projectsCache = nil,
    cacheTimestamp = 0,
    cacheTimeout = 300 -- 5 minutes cache
}

-- Initialize MCP client with configuration
function MCPClient.init(config)
    log:d('Initializing MCP client with config')
    config = config or {}

    if config.serverUrl then
        MCPClient.mcpServerUrl = config.serverUrl
    end

    if config.timeout then
        MCPClient.timeout = config.timeout
    end

    log:i('MCP client initialized with server: ' .. MCPClient.mcpServerUrl)
    return true
end

-- Make HTTP request to MCP server
function MCPClient.makeRequest(method, endpoint, params)
    log:d('Making MCP request: ' .. method .. ' ' .. endpoint)

    local url = MCPClient.mcpServerUrl .. endpoint
    local success, result = pcall(function()
        -- Using hs.http for HTTP requests
        local status, response = hs.http.doRequest(url, method, params, {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }, MCPClient.timeout)

        if status == 200 then
            local data = hs.json.decode(response)
            return { success = true, data = data }
        else
            log:w('MCP request failed with status: ' .. status)
            return { success = false, error = "HTTP " .. status, response = response }
        end
    end)

    if success then
        log:d('MCP request completed successfully')
        return result
    else
        log:e('MCP request error: ' .. (result or "unknown error"))
        return { success = false, error = result }
    end
end

-- Get projects list from MCP server
function MCPClient.getProjectsList(forceRefresh)
    log:d('Getting projects list from MCP server')

    -- Check cache first
    local currentTime = os.time()
    if not forceRefresh and MCPClient.projectsCache and
        (currentTime - MCPClient.cacheTimestamp) < MCPClient.cacheTimeout then
        log:d('Returning cached projects list')
        return { success = true, data = MCPClient.projectsCache }
    end

    -- Make request to MCP server
    local result = MCPClient.makeRequest("GET", "/api/projects", nil)

    if result.success then
        -- Update cache
        MCPClient.projectsCache = result.data.projects or result.data
        MCPClient.cacheTimestamp = currentTime
        log:i('Retrieved ' .. #MCPClient.projectsCache .. ' projects from MCP server')
        return result
    else
        log:w('Failed to get projects from MCP server: ' .. (result.error or "unknown error"))

        -- Return cached data if available as fallback
        if MCPClient.projectsCache then
            log:w('Returning cached projects as fallback')
            return { success = true, data = MCPClient.projectsCache, cached = true }
        end

        return result
    end
end

-- Convert MCP project list to FileManager format for compatibility
function MCPClient.convertToFileManagerFormat(mcpProjects)
    log:d('Converting MCP projects to FileManager format')

    local converted = {}
    for _, project in ipairs(mcpProjects) do
        table.insert(converted, {
            name = project,
            path = "~/lab/madness_interactive/projects/" .. project:lower(), -- Default path pattern
            description = "Project from centralized MCP server"
        })
    end

    log:d('Converted ' .. #converted .. ' projects to FileManager format')
    return converted
end

-- Test MCP server connectivity
function MCPClient.testConnection()
    log:d('Testing MCP server connection')

    local result = MCPClient.makeRequest("GET", "/api/health", nil)

    if result.success then
        log:i('MCP server connection test successful')
        return true
    else
        log:w('MCP server connection test failed: ' .. (result.error or "unknown error"))
        return false
    end
end

-- Clear projects cache
function MCPClient.clearCache()
    log:d('Clearing MCP projects cache')
    MCPClient.projectsCache = nil
    MCPClient.cacheTimestamp = 0
end

-- Get projects list in FileManager compatible format
function MCPClient.getProjectsListForFileManager(forceRefresh)
    log:d('Getting projects list for FileManager compatibility')

    local result = MCPClient.getProjectsList(forceRefresh)

    if result.success then
        local converted = MCPClient.convertToFileManagerFormat(result.data)
        return { success = true, data = converted, cached = result.cached }
    else
        return result
    end
end

-- Initialize the module
log:i('MCP client module loaded successfully')

-- Make module globally accessible
_G.MCPClient = MCPClient

return MCPClient
