-- test_mcp_mode_toggle.lua - Test MCP client mode toggle functionality
-- Verify only one MCP client is active at a time

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('TestMCPModeToggle')

log:i('Testing MCP client mode toggle functionality')

-- Test 1: Check global MCP client configuration
log:d('Test 1: Checking global MCP client configuration')
local mcpClientType = _G.MCPClientType
local mcpClientLoaded = _G.MCPClientLoaded

log:i('Global MCP client type: ' .. (mcpClientType or "none"))
log:i('Global MCP client loaded: ' .. tostring(mcpClientLoaded))

-- Test 2: Check which modules are available
log:d('Test 2: Checking MCP module availability')
local httpClientAvailable = (_G.MCPClient ~= nil)
local sseClientAvailable = (_G.MCPClientSSE ~= nil)

log:i('HTTP client globally available: ' .. tostring(httpClientAvailable))
log:i('SSE client globally available: ' .. tostring(sseClientAvailable))

-- Test 3: Test FileManager integration
log:d('Test 3: Testing FileManager integration')
local FileManager = require('FileManager')
local projects = FileManager.getProjectsList()

if projects and #projects > 0 then
    log:i('✓ FileManager successfully loaded ' .. #projects .. ' projects')
    log:d('First project: ' .. (projects[1].name or "unknown"))
else
    log:w('⚠ FileManager returned no projects')
end

-- Test 4: Test connection functionality
log:d('Test 4: Testing MCP connection')
local connectionTest = FileManager.testMCPConnection()
log:i('Connection test result: ' .. tostring(connectionTest))

-- Test 5: Check for conflicts
log:d('Test 5: Checking for potential conflicts')
local conflicts = {}

if httpClientAvailable and sseClientAvailable and mcpClientType == "sse" then
    table.insert(conflicts, "Both HTTP and SSE clients are loaded while in SSE mode")
end

if #conflicts > 0 then
    log:w('⚠ Potential conflicts detected:')
    for _, conflict in ipairs(conflicts) do
        log:w('  - ' .. conflict)
    end
else
    log:i('✓ No conflicts detected')
end

-- Summary
log:i('Test Results Summary:')
log:i('- MCP Mode: ' .. (mcpClientType or "unknown"))
log:i('- Client Loaded: ' .. tostring(mcpClientLoaded))
log:i('- Projects Available: ' .. (projects and #projects or 0))
log:i('- Connection Working: ' .. tostring(connectionTest))
log:i('- Conflicts: ' .. #conflicts)

-- Return test results
return {
    mcpMode = mcpClientType,
    clientLoaded = mcpClientLoaded,
    projectCount = projects and #projects or 0,
    connectionWorking = connectionTest,
    conflictCount = #conflicts,
    httpAvailable = httpClientAvailable,
    sseAvailable = sseClientAvailable
}
