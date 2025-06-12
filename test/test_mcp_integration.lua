-- test_mcp_integration.lua - Test MCP client integration
-- Test the centralized project management system integration

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('TestMCPIntegration')

log:i('Starting MCP integration tests')

-- Test 1: Load MCP Client
log:d('Test 1: Loading MCP Client module')
local MCPClient
local success, result = pcall(function()
    return require('MCPClient')
end)

if success then
    MCPClient = result
    log:i('✓ MCP Client module loaded successfully')
else
    log:e('✗ Failed to load MCP Client module: ' .. (result or "unknown error"))
    return false
end

-- Test 2: Initialize MCP Client
log:d('Test 2: Initializing MCP Client')
local initSuccess = MCPClient.init({
    serverUrl = "http://localhost:8000",
    timeout = 5
})

if initSuccess then
    log:i('✓ MCP Client initialized successfully')
else
    log:e('✗ Failed to initialize MCP Client')
    return false
end

-- Test 3: Test connection
log:d('Test 3: Testing MCP server connection')
local connected = MCPClient.testConnection()
if connected then
    log:i('✓ MCP server connection successful')
else
    log:w('⚠ MCP server connection failed (may be normal if server is not running)')
end

-- Test 4: Test project list retrieval
log:d('Test 4: Testing project list retrieval')
local projectsResult = MCPClient.getProjectsList()
if projectsResult and projectsResult.success then
    if projectsResult.data and #projectsResult.data > 0 then
        log:i('✓ Retrieved ' .. #projectsResult.data .. ' projects from MCP server')
        log:d('First 5 projects: ' .. hs.inspect(table.slice(projectsResult.data, 1, 5)))
    else
        log:w('⚠ MCP server returned empty project list')
    end
else
    log:w('⚠ Failed to retrieve projects from MCP server: ' ..
    (projectsResult and projectsResult.error or "unknown error"))
end

-- Test 5: Test FileManager integration
log:d('Test 5: Testing FileManager integration')
local FileManager
local success2, result2 = pcall(function()
    return require('FileManager')
end)

if success2 then
    FileManager = result2
    log:i('✓ FileManager module loaded successfully')

    -- Test getting projects through FileManager
    local projects = FileManager.getProjectsList()
    if projects and #projects > 0 then
        log:i('✓ FileManager returned ' .. #projects .. ' projects')
        log:d('First project: ' .. hs.inspect(projects[1]))
    else
        log:w('⚠ FileManager returned empty project list')
    end

    -- Test refresh functionality
    log:d('Testing project refresh functionality')
    local refreshedProjects = FileManager.refreshProjectsList()
    if refreshedProjects then
        log:i('✓ Project refresh functionality works')
    else
        log:w('⚠ Project refresh failed (may be normal if MCP server is not available)')
    end

    -- Test MCP connection test
    log:d('Testing MCP connection test through FileManager')
    local connectionTest = FileManager.testMCPConnection()
    if connectionTest then
        log:i('✓ MCP connection test through FileManager successful')
    else
        log:w('⚠ MCP connection test through FileManager failed')
    end
else
    log:e('✗ Failed to load FileManager module: ' .. (result2 or "unknown error"))
    return false
end

-- Test 6: Test fallback functionality
log:d('Test 6: Testing fallback functionality')
-- Temporarily break MCP client to test fallback
local originalServerUrl = MCPClient.mcpServerUrl
MCPClient.mcpServerUrl = "http://invalid-server:9999"

local fallbackProjects = FileManager.getProjectsList()
if fallbackProjects and #fallbackProjects > 0 then
    log:i('✓ Fallback to hardcoded project list works (' .. #fallbackProjects .. ' projects)')
else
    log:e('✗ Fallback functionality failed')
end

-- Restore original server URL
MCPClient.mcpServerUrl = originalServerUrl

log:i('MCP integration tests completed')

-- Helper function to slice tables (if not available)
if not table.slice then
    table.slice = function(tbl, first, last)
        local sliced = {}
        for i = first or 1, last or #tbl do
            sliced[#sliced + 1] = tbl[i]
        end
        return sliced
    end
end

-- Return test results summary
return {
    mcpClientLoaded = (MCPClient ~= nil),
    mcpClientInitialized = initSuccess,
    mcpServerConnected = connected,
    fileManagerIntegrated = (FileManager ~= nil),
    fallbackWorks = (#fallbackProjects > 0)
}
