-- logger_diagnostics.lua
-- Utility script to analyze logger usage across the codebase

local HyperLogger = require('HyperLogger')

local function printHeader(title)
    local separator = string.rep("=", 60)
    print("\n" .. separator)
    print("    " .. title)
    print(separator)
end

-- Get all registered loggers
local function reportLoggers()
    printHeader("REGISTERED LOGGERS")

    local loggers = HyperLogger.getLoggers()
    if #loggers == 0 then
        print("No loggers registered yet.")
        return
    end

    -- Sort loggers alphabetically
    table.sort(loggers)

    -- Print statistics
    print(string.format("Total loggers registered: %d\n", #loggers))

    -- Print all logger namespaces
    for i, namespace in ipairs(loggers) do
        local creationStack = HyperLogger.getCreationStack(namespace)
        local creationInfo = creationStack and "\n   Created at: " .. creationStack or ""
        print(string.format("%2d. %s%s", i, namespace, creationInfo))
    end
end

-- Check for potential logger naming inconsistencies
local function checkNamingConsistency()
    printHeader("LOGGER NAMING CONSISTENCY CHECK")

    local loggers = HyperLogger.getLoggers()
    local prefixCounts = {}
    local abbreviatedNames = {}

    -- Group loggers by prefix (first part of name)
    for _, name in ipairs(loggers) do
        -- Try to extract prefix
        local prefix = name:match("^([^%.]+)")
        if prefix then
            prefixCounts[prefix] = (prefixCounts[prefix] or 0) + 1
        end

        -- Check for abbreviated names
        if name:len() <= 5 and name ~= "Main" then
            table.insert(abbreviatedNames, name)
        end
    end

    -- Report on similar prefixes
    local similarPrefixes = {}
    local prefixes = {}
    for prefix, _ in pairs(prefixCounts) do
        table.insert(prefixes, prefix)
    end

    -- Sort prefixes
    table.sort(prefixes)

    -- Print all prefixes with counts
    print("Logger namespaces by prefix:")
    for _, prefix in ipairs(prefixes) do
        print(string.format("  %s: %d logger(s)", prefix, prefixCounts[prefix]))
    end

    -- Report on abbreviated names
    if #abbreviatedNames > 0 then
        print("\nPotentially abbreviated namespaces (may cause confusion):")
        for _, name in ipairs(abbreviatedNames) do
            print("  " .. name)
        end
    end
end

-- Recommend logger naming based on module structure
local function suggestNamingStandard()
    printHeader("LOGGER NAMING RECOMMENDATIONS")

    print("For consistent logging, consider using these namespace patterns:")
    print("  - Use descriptive, full module names rather than abbreviations")
    print("  - For core modules: ModuleName (e.g., 'WindowManager', 'FileManager')")
    print("  - For Spoons: SpoonName (e.g., 'DragonGrid', 'ClipboardTool')")
    print("  - For nested components: ParentModule.Component")
    print("  - Avoid generic names like 'Logger', 'Debug', 'Test'")
    print("\nThis helps with filtering logs and understanding their source.")
end

-- Run a memory check for logger objects
local function checkMemoryUsage()
    printHeader("LOGGER MEMORY USAGE")

    local loggers = HyperLogger.getLoggers()

    -- Count total estimated memory
    local estimatedMemoryPerLogger = 2048 -- Conservative estimate in bytes
    local totalEstimatedMemory = #loggers * estimatedMemoryPerLogger

    print(string.format("Estimated logger memory usage: %.2f KB (%d loggers)",
        totalEstimatedMemory / 1024, #loggers))

    if #loggers > 20 then
        print("\nWARNING: High number of loggers detected.")
        print("Consider reviewing logger usage or increasing garbage collection frequency.")
    else
        print("\nMemory usage appears normal.")
    end
end

-- Main function to run all diagnostics
local function runDiagnostics()
    printHeader("LOGGER DIAGNOSTICS REPORT")
    print("Running comprehensive logger analysis...\n")

    reportLoggers()
    checkNamingConsistency()
    checkMemoryUsage()
    suggestNamingStandard()

    printHeader("END OF REPORT")
end

-- Check if file is being executed directly or imported as a module
local info = debug.getinfo(1, 'S')
local isImported = info.source ~= "=stdin" and info.source:sub(1, 1) == "@"

if isImported then
    -- Being loaded as a library, return the functions
    return {
        reportLoggers = reportLoggers,
        checkNamingConsistency = checkNamingConsistency,
        suggestNamingStandard = suggestNamingStandard,
        checkMemoryUsage = checkMemoryUsage,
        runDiagnostics = runDiagnostics
    }
else
    -- Being run directly, execute the diagnostics
    runDiagnostics()
end
