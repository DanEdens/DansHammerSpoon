-- test_init_flow.lua
-- Tests the initialization flow of Hammerspoon to detect redundancies and ordering issues

-- Create a mock logger to track module loads and initialization
local trackingLog = {}

-- Track module initialization
local moduleInitOrder = {}
local spoonLoadOrder = {}
local redundantLoads = {}

-- Track component load times
local loadTimings = {}
local startTime = os.time()

-- Mock various key modules to track their initialization
local mockModules = {
    "WindowManager",
    "FileManager",
    "HotkeyManager",
    "ProjectManager",
    "AppManager",
    "DeviceManager",
    "WindowToggler"
}

-- Store original require function
local originalRequire = require

-- Override require to track module loading
function require(moduleName)
    local moduleStart = os.clock()

    -- Pass through to the original require
    local result = originalRequire(moduleName)

    -- Track the module load
    local loadTime = os.clock() - moduleStart

    -- Only track our core modules
    for _, name in ipairs(mockModules) do
        if moduleName == name then
            table.insert(moduleInitOrder, { name = moduleName, time = loadTime })
            loadTimings[moduleName] = loadTime

            -- Check for redundant loading
            local count = 0
            for _, loaded in ipairs(moduleInitOrder) do
                if loaded.name == moduleName then
                    count = count + 1
                end
            end

            if count > 1 then
                table.insert(redundantLoads, moduleName)
            end

            print("Module loaded: " .. moduleName .. " in " .. loadTime .. "s")
        end
    end

    return result
end

-- Mock spoon loading
local originalLoadSpoon = hs.loadSpoon
function hs.loadSpoon(spoonName)
    local spoonStart = os.clock()
    local result = originalLoadSpoon(spoonName)
    local loadTime = os.clock() - spoonStart

    table.insert(spoonLoadOrder, { name = spoonName, time = loadTime })
    loadTimings[spoonName .. " (Spoon)"] = loadTime

    print("Spoon loaded: " .. spoonName .. " in " .. loadTime .. "s")

    return result
end

-- Report function
local function reportInitialization()
    print("\n=== Initialization Report ===\n")

    -- Module initialization order
    print("Module Initialization Order:")
    for i, module in ipairs(moduleInitOrder) do
        print(string.format("%2d. %s (%.3fs)", i, module.name, module.time))
    end

    -- Spoon loading order
    print("\nSpoon Loading Order:")
    for i, spoon in ipairs(spoonLoadOrder) do
        print(string.format("%2d. %s (%.3fs)", i, spoon.name, spoon.time))
    end

    -- Redundant loads
    if #redundantLoads > 0 then
        print("\nRedundant Module Loads:")
        for _, moduleName in ipairs(redundantLoads) do
            print("  - " .. moduleName)
        end
    else
        print("\nNo redundant module loads detected.")
    end

    -- Performance report
    print("\nPerformance Report:")
    local sortedTimings = {}
    for name, time in pairs(loadTimings) do
        table.insert(sortedTimings, { name = name, time = time })
    end

    table.sort(sortedTimings, function(a, b) return a.time > b.time end)

    for i, timing in ipairs(sortedTimings) do
        print(string.format("%2d. %s: %.3fs", i, timing.name, timing.time))
    end

    -- Total initialization time
    local totalTime = os.time() - startTime
    print("\nTotal initialization time: " .. totalTime .. "s")
end

-- Install a timer to run the report after initialization
hs.timer.doAfter(5, reportInitialization)

-- Notify that we're testing
hs.alert.show("Testing init flow...")

-- Now proceed with normal initialization
print("Beginning initialization flow test...")

-- The actual initialization will happen in init.lua
-- This is just a hook to track the process
