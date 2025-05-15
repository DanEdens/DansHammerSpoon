-- test_hyperlogger_spoon_integration.lua
-- Test script to verify HyperLogger integration with Spoon-style loggers

-- Create a styled header
local function printHeader(text)
    local styledText = hs.styledtext.new("\n==== " .. text .. " ====\n", {
        font = { name = "Menlo", size = 18 },
        color = { red = 0.2, green = 0.7, blue = 1.0 }
    })
    hs.console.printStyledtext(styledText)
end

printHeader("HyperLogger Spoon Integration Test")

-- Store the original logger function
local originalLoggerNew = hs.logger.new

-- Load our HyperLogger
local HyperLogger = require('HyperLogger')
local hyperLog = HyperLogger.new('TestHarness')

hyperLog:i("Testing Spoon logger integration")

-- Mock the way a Spoon creates and uses a logger
local function createMockSpoon(name)
    local mockSpoon = {}

    -- This is how Spoons typically create loggers
    mockSpoon.logger = hs.logger.new(name)
    mockSpoon.logger.setLogLevel('debug')

    -- Spoons typically log this way (no 'self:' syntax)
    mockSpoon.someFunction = function()
        mockSpoon.logger.i("Info log from " .. name)
        mockSpoon.logger.d("Debug log from " .. name)
        mockSpoon.logger.w("Warning log from " .. name)
        mockSpoon.logger.e("Error log from " .. name)
    end

    return mockSpoon
end

printHeader("Using Original Logger")

-- Create mock Spoons with original logger
local dragonGridOriginal = createMockSpoon('DragonGridOriginal')
dragonGridOriginal.someFunction()

-- Monkey-patch the logger
printHeader("Monkey-Patching hs.logger.new")

-- Replace with our wrapper
hs.logger.new = function(namespace, loglevel)
    hyperLog:d('Intercepted logger creation for: ' .. (namespace or "unnamed"))

    -- Create a HyperLogger instance instead
    local hyperLogger = HyperLogger.new(namespace, loglevel)

    return hyperLogger
end

-- Create mock Spoons with our monkey-patched logger
local dragonGridPatched = createMockSpoon('DragonGridPatched')
local layoutsPatched = createMockSpoon('LayoutsPatched')

printHeader("Spoon-Style Log Messages")

-- Test the monkey-patched spoon loggers
dragonGridPatched.someFunction()
layoutsPatched.someFunction()

-- Restore the original logger
hs.logger.new = originalLoggerNew

printHeader("Test Complete")
print("If this works correctly, you should see:")
print("1. Original logger messages with timestamps (DragonGridOriginal)")
print("2. Patched logger messages with consistent styling (DragonGridPatched and LayoutsPatched)")
print("3. No errors from method calls like mockSpoon.logger.i() without 'self:'")

return {
    dragonGridOriginal = dragonGridOriginal,
    dragonGridPatched = dragonGridPatched,
    layoutsPatched = layoutsPatched
}
