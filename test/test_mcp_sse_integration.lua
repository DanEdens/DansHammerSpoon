-- test_mcp_sse_integration.lua - Test MCP SSE client integration
-- Test the SSE-based centralized project management system

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('TestMCPSSEIntegration')

log:i('Starting MCP SSE integration tests')

-- Test results storage
local testResults = {
    mcpSSEClientLoaded = false,
    mcpSSEClientInitialized = false,
    mcpSSEServerConnected = false,
    sseConnectionStarted = false,
    fileManagerSSEIntegrated = false,
    fallbackWorks = false,
    realTimeCallbacksWork = false
}

-- Test 1: Load MCP SSE Client
log:d('Test 1: Loading MCP SSE Client module')
local MCPClientSSE
local success, result = pcall(function()
    return require('MCPClientSSE')
end)

if success then
    MCPClientSSE = result
    testResults.mcpSSEClientLoaded = true
    log:i('✓ MCP SSE Client module loaded successfully')
else
    log:e('✗ Failed to load MCP SSE Client module: ' .. (result or "unknown error"))
    return testResults
end

-- Test 2: Initialize MCP SSE Client
log:d('Test 2: Initializing MCP SSE Client')

-- Test callback functions
local projectUpdateReceived = false
local connectionStatusReceived = false

local function testProjectUpdateCallback(projectData)
    log:d('Test callback received project update: ' .. hs.inspect(projectData))
    projectUpdateReceived = true
end

local function testConnectionStatusCallback(connected, message)
    log:d('Test callback received connection status: ' .. tostring(connected) .. " - " .. message)
    connectionStatusReceived = true
end

local initSuccess = MCPClientSSE.init({
    serverUrl = "http://52.44.236.251:8000",
    timeout = 10,
    onProjectUpdate = testProjectUpdateCallback,
    onConnectionStatus = testConnectionStatusCallback
})

if initSuccess then
    testResults.mcpSSEClientInitialized = true
    log:i('✓ MCP SSE Client initialized successfully')
else
    log:e('✗ Failed to initialize MCP SSE Client')
    return testResults
end

-- Test 3: Test connection
log:d('Test 3: Testing MCP SSE server connection')
local connected = MCPClientSSE.testConnection()
if connected then
    testResults.mcpSSEServerConnected = true
    log:i('✓ MCP SSE server connection successful')
else
    log:w('⚠ MCP SSE server connection failed (may be normal if server is not running)')
end

-- Test 4: Start SSE connection simulation
log:d('Test 4: Starting SSE connection simulation')
MCPClientSSE.startSSEConnection()

local status = MCPClientSSE.getConnectionStatus()
if status.connected then
    testResults.sseConnectionStarted = true
    log:i('✓ SSE connection simulation started successfully')
    log:d('Connection status: ' .. hs.inspect(status))
else
    log:w('⚠ SSE connection simulation failed to start')
end

-- Test 5: Test project list retrieval
log:d('Test 5: Testing project list retrieval with SSE')
local projectsResult = MCPClientSSE.getProjectsList()
if projectsResult and projectsResult.success then
    if projectsResult.data and #projectsResult.data > 0 then
        log:i('✓ Retrieved ' .. #projectsResult.data .. ' projects from MCP SSE server')
        log:d('First 3 projects: ' .. hs.inspect(table.slice(projectsResult.data, 1, 3)))
    else
        log:w('⚠ MCP SSE server returned empty project list')
    end
else
    log:w('⚠ Failed to retrieve projects from MCP SSE server: ' ..
    (projectsResult and projectsResult.error or "unknown error"))
end

-- Test 6: Test FileManagerSSE integration
log:d('Test 6: Testing FileManagerSSE integration')
local FileManagerSSE
local success2, result2 = pcall(function()
    return require('FileManagerSSE')
end)

if success2 then
    FileManagerSSE = result2
    testResults.fileManagerSSEIntegrated = true
    log:i('✓ FileManagerSSE module loaded successfully')

    -- Test getting projects through FileManagerSSE
    local projects = FileManagerSSE.getProjectsList()
    if projects and #projects > 0 then
        log:i('✓ FileManagerSSE returned ' .. #projects .. ' projects')
        log:d('First project: ' .. hs.inspect(projects[1]))
    else
        log:w('⚠ FileManagerSSE returned empty project list')
    end

    -- Test refresh functionality
    log:d('Testing SSE project refresh functionality')
    local refreshedProjects = FileManagerSSE.refreshProjectsList()
    if refreshedProjects then
        log:i('✓ SSE project refresh functionality works')
    else
        log:w('⚠ SSE project refresh failed (may be normal if MCP server is not available)')
    end

    -- Test SSE connection test
    log:d('Testing SSE connection test through FileManagerSSE')
    local connectionTest = FileManagerSSE.testSSEConnection()
    if connectionTest then
        log:i('✓ SSE connection test through FileManagerSSE successful')
    else
        log:w('⚠ SSE connection test through FileManagerSSE failed')
    end

    -- Test real-time status
    log:d('Testing real-time status functionality')
    local rtStatus = FileManagerSSE.getRealTimeStatus()
    log:i('Real-time status: ' .. hs.inspect(rtStatus))
else
    log:e('✗ Failed to load FileManagerSSE module: ' .. (result2 or "unknown error"))
    return testResults
end

-- Test 7: Test fallback functionality
log:d('Test 7: Testing fallback functionality')
-- Temporarily break SSE client to test fallback
local originalServerUrl = MCPClientSSE.serverUrl
MCPClientSSE.serverUrl = "http://invalid-server:9999"

local fallbackProjects = FileManagerSSE.getProjectsList()
if fallbackProjects and #fallbackProjects > 0 then
    testResults.fallbackWorks = true
    log:i('✓ Fallback to hardcoded project list works (' .. #fallbackProjects .. ' projects)')
else
    log:e('✗ Fallback functionality failed')
end

-- Restore original server URL
MCPClientSSE.serverUrl = originalServerUrl

-- Test 8: Test event callbacks and real-time simulation
log:d('Test 8: Testing event callbacks and real-time simulation')

-- Add test event listener
local eventReceived = false
MCPClientSSE.addEventListener("test_event", function(eventData)
    log:d('Test event listener called with: ' .. hs.inspect(eventData))
    eventReceived = true
end)

-- Simulate receiving an SSE event
local testEventData = {
    event = "project_update",
    data = { "test_project_1", "test_project_2" }
}

MCPClientSSE.handleSSEEvent(testEventData)

-- Check if callbacks were triggered (wait a moment for async operations)
hs.timer.doAfter(2.0, function()
    if projectUpdateReceived or connectionStatusReceived then
        testResults.realTimeCallbacksWork = true
        log:i('✓ Real-time callbacks working (Project: ' .. tostring(projectUpdateReceived) ..
            ', Connection: ' .. tostring(connectionStatusReceived) .. ')')
    else
        log:w('⚠ Real-time callbacks not triggered')
    end

    -- Final test summary
    log:i('MCP SSE integration tests completed')

    local passedTests = 0
    local totalTests = 0
    for testName, result in pairs(testResults) do
        totalTests = totalTests + 1
        if result then
            passedTests = passedTests + 1
        end
    end

    log:i('Test Results Summary: ' .. passedTests .. '/' .. totalTests .. ' tests passed')

    if passedTests == totalTests then
        log:i('🎉 All SSE integration tests PASSED!')
        hs.alert.show("MCP SSE Integration: ALL TESTS PASSED! 🎉")
    else
        log:w('⚠ Some SSE integration tests failed - check logs')
        hs.alert.show("MCP SSE Integration: " .. passedTests .. "/" .. totalTests .. " tests passed")
    end
end)

-- Test 9: Performance test - measure response times
log:d('Test 9: Performance testing')
local startTime = os.clock()
local perfProjects = MCPClientSSE.getProjectsList()
local endTime = os.clock()
local responseTime = (endTime - startTime) * 1000 -- Convert to milliseconds

log:i('Performance test: Project list retrieved in ' .. string.format("%.2f", responseTime) .. 'ms')

-- Test 10: Cache behavior testing
log:d('Test 10: Cache behavior testing')
-- First call (should cache)
local firstCall = MCPClientSSE.getProjectsList()
-- Second call immediately (should use cache)
local secondCall = MCPClientSSE.getProjectsList()

if secondCall.cached then
    log:i('✓ Cache behavior working correctly')
else
    log:w('⚠ Cache behavior unexpected')
end

-- Stop SSE connection for cleanup
log:d('Cleaning up: Stopping SSE connection')
MCPClientSSE.stopSSEConnection()

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
return testResults
