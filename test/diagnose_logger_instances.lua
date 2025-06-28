-- diagnose_logger_instances.lua
-- Utility script to identify and diagnose multiple logger instances

local HyperLogger = require('HyperLogger')

local function printHeader(title)
    local separator = string.rep("=", 60)
    print("\n" .. separator)
    print("    " .. title)
    print(separator)
end

-- Check the HyperLogger implementation to see if it properly implements singleton pattern
local function analyzeLoggerImplementation()
    printHeader("HYPERLOGGER IMPLEMENTATION ANALYSIS")

    -- Check if loggers table exists and is being used correctly
    local hasLoggersClosure = false

    for k, v in pairs(HyperLogger) do
        if k == "getLoggers" then
            hasLoggersClosure = true
            break
        end
    end

    if hasLoggersClosure then
        print("✓ HyperLogger has a getLoggers function, suggesting it maintains a registry")

        -- Test the singleton behavior
        local logger1 = HyperLogger.new("TestSingleton", "debug")
        local logger2 = HyperLogger.new("TestSingleton", "info")

        if logger1:getLogLevel() == logger2:getLogLevel() then
            print("✓ Singleton pattern appears to be working - same logger returned for same namespace")
        else
            print("✗ Singleton pattern broken - different loggers returned for same namespace")
            print("  Logger1 level: " .. logger1:getLogLevel())
            print("  Logger2 level: " .. logger2:getLogLevel())
        end
    else
        print("✗ HyperLogger does not appear to properly track created instances")
    end
end

-- Analyze the init.lua for logger initialization
local function analyzeInitFile()
    printHeader("INIT.LUA LOGGER ANALYSIS")

    local initFile = io.open(hs.configdir .. "/init.lua", "r")
    if not initFile then
        print("Could not open init.lua for analysis")
        return
    end

    local content = initFile:read("*all")
    initFile:close()

    local loggerInitCount = 0
    local hyperLoggerRequireCount = 0

    -- Count HyperLogger requires
    for _ in content:gmatch("require%(['\"]HyperLogger['\"]") do
        hyperLoggerRequireCount = hyperLoggerRequireCount + 1
    end

    -- Count HyperLogger initializations
    for _ in content:gmatch("HyperLogger%.new%(") do
        loggerInitCount = loggerInitCount + 1
    end

    print("Found " .. hyperLoggerRequireCount .. " HyperLogger imports in init.lua")
    print("Found " .. loggerInitCount .. " HyperLogger initializations in init.lua")

    if loggerInitCount > 1 then
        print("⚠️ Multiple logger initializations detected in init.lua")
    else
        print("✓ Single logger initialization in init.lua")
    end
end

-- Analyze hotkeys.lua for logger initialization
local function analyzeHotkeysFile()
    printHeader("HOTKEYS.LUA LOGGER ANALYSIS")

    local hotkeysFile = io.open(hs.configdir .. "/hotkeys.lua", "r")
    if not hotkeysFile then
        print("Could not open hotkeys.lua for analysis")
        return
    end

    local content = hotkeysFile:read("*all")
    hotkeysFile:close()

    local loggerInitCount = 0
    local hyperLoggerRequireCount = 0

    -- Count HyperLogger requires
    for _ in content:gmatch("require%(['\"]HyperLogger['\"]") do
        hyperLoggerRequireCount = hyperLoggerRequireCount + 1
    end

    -- Count HyperLogger initializations
    for _ in content:gmatch("HyperLogger%.new%(") do
        loggerInitCount = loggerInitCount + 1
    end

    print("Found " .. hyperLoggerRequireCount .. " HyperLogger imports in hotkeys.lua")
    print("Found " .. loggerInitCount .. " HyperLogger initializations in hotkeys.lua")

    if loggerInitCount > 0 then
        print("⚠️ Logger initialization detected in hotkeys.lua - may duplicate init.lua logger")
    else
        print("✓ No separate logger initialization in hotkeys.lua")
    end
end

-- Analyze all module files for logger initialization
local function scanAllModules()
    printHeader("MODULE-WIDE LOGGER SCAN")

    local files = {
        "WindowManager.lua",
        "FileManager.lua",
        "AppManager.lua",
        "ProjectManager.lua",
        "DeviceManager.lua",
        "WindowToggler.lua",
        "HotkeyManager.lua",
        "init.lua",
        "hotkeys.lua"
    }

    local results = {}

    for _, filename in ipairs(files) do
        local file = io.open(hs.configdir .. "/" .. filename, "r")
        if file then
            local content = file:read("*all")
            file:close()

            local hyperLoggerRequireCount = 0
            local loggerInitCount = 0
            local namespaceName = ""

            -- Count HyperLogger requires
            for _ in content:gmatch("require%(['\"]HyperLogger['\"]") do
                hyperLoggerRequireCount = hyperLoggerRequireCount + 1
            end

            -- Count HyperLogger initializations and capture namespace
            for ns in content:gmatch("HyperLogger%.new%(['\"]([^'\"()]*)") do
                loggerInitCount = loggerInitCount + 1
                namespaceName = ns ~= "" and ns or "default"
            end

            results[filename] = {
                requires = hyperLoggerRequireCount,
                inits = loggerInitCount,
                namespace = namespaceName
            }
        end
    end

    -- Display results
    print("Logger initialization across modules:")
    print(string.format("%-20s %-8s %-8s %s", "Module", "Requires", "Inits", "Namespace"))
    print(string.rep("-", 60))

    for filename, data in pairs(results) do
        print(string.format("%-20s %-8d %-8d %s",
            filename,
            data.requires,
            data.inits,
            data.namespace ~= "" and data.namespace or "(none)"
        ))
    end

    -- Check for potential issues
    local totalInits = 0
    for _, data in pairs(results) do
        totalInits = totalInits + data.inits
    end

    print("\nTotal logger initializations across all modules: " .. totalInits)
    if totalInits > #files then
        print("⚠️ Potential issue: More logger initializations than modules")
        print("   This may indicate multiple loggers per module or excessive logging")
    end
end

-- List all active logger instances and their details
local function listActiveLoggers()
    printHeader("ACTIVE LOGGER INSTANCES")

    local loggers = HyperLogger.getLoggers()
    table.sort(loggers)

    print("Total active loggers: " .. #loggers)
    print(string.rep("-", 60))

    for i, namespace in ipairs(loggers) do
        local logger = HyperLogger.new(namespace)
        local level = logger:getLogLevel()
        print(string.format("%2d. %-30s (level: %s)", i, namespace, level))
    end

    -- Look for duplicates with slightly different names
    local prefixMap = {}
    for _, namespace in ipairs(loggers) do
        local prefix = namespace:match("^(%w+)")
        if prefix then
            prefixMap[prefix] = (prefixMap[prefix] or 0) + 1
        end
    end

    print("\nPotential duplication by name prefix:")
    for prefix, count in pairs(prefixMap) do
        if count > 1 then
            print(string.format("  %-15s : %d instances", prefix, count))
        end
    end
end

-- Make recommendations to fix logger issues
local function makeRecommendations()
    printHeader("RECOMMENDATIONS")

    print("Based on the analysis, here are recommendations to fix logger issues:")
    print("")
    print("1. Ensure each module uses a consistent logger naming convention")
    print("   - Use the module name as the logger namespace")
    print("   - Example: WindowManager module should use 'WindowManager' namespace")
    print("")
    print("2. Consider centralizing logger initialization")
    print("   - Create loggers in init.lua and pass them to modules")
    print("   - Or use a registry pattern where modules request loggers by name")
    print("")
    print("3. Update modules to use existing loggers")
    print("   - Instead of creating new loggers in each module")
    print("   - Use HyperLogger.new() with consistent namespaces")
    print("")
    print("4. For hotkeys.lua specifically")
    print("   - Consider using the main application logger from init.lua")
    print("   - Or ensure its logger has a distinct namespace from others")
    print("")
    print("5. Check for modules creating multiple loggers internally")
    print("   - Each module should create at most one logger")
    print("   - Sub-components should reuse the module's logger")
end

-- Run all diagnostic functions
local function runDiagnostics()
    printHeader("LOGGER INSTANCES DIAGNOSTIC REPORT")

    analyzeLoggerImplementation()
    analyzeInitFile()
    analyzeHotkeysFile()
    scanAllModules()
    listActiveLoggers()
    makeRecommendations()

    printHeader("END OF REPORT")
end

-- Run diagnostics when script is executed directly
runDiagnostics()
