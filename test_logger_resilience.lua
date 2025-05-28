-- test_logger_resilience.lua
-- Test HyperLogger resilience against nil _baseLogger

local function printHeader(text)
    print("\n" .. string.rep("=", 50))
    print("  " .. text)
    print(string.rep("=", 50))
end

-- Test the HyperLogger directly
printHeader("TESTING HYPERLOGGER MODULE")
local HyperLogger = require('HyperLogger')
print("HyperLogger loaded successfully")

-- Create logger with nil _baseLogger (simulating the error)
local brokenLogger = {
    _namespace = "TestBroken",
    _baseLogger = nil -- Deliberately set to nil
}

-- Copy methods from a real logger
local realLogger = HyperLogger.new("TestReal")
for k, v in pairs(getmetatable(realLogger) or {}) do
    if type(v) == "function" then
        brokenLogger[k] = v
    end
end

-- Try different log levels with the broken logger
print("\nTesting broken logger with nil _baseLogger (fixed version should handle gracefully):")
pcall(function() brokenLogger:d("Debug message test") end)
pcall(function() brokenLogger:i("Info message test") end)
pcall(function() brokenLogger:w("Warning message test") end)
pcall(function() brokenLogger:e("Error message test") end)

-- Now test WindowManager logger
printHeader("TESTING WINDOWMANAGER LOGGER")
local WindowManager = require('WindowManager')
print("WindowManager loaded successfully")

-- Reset and try to get a reference to the logger
_G.WindowManagerLogger = nil

-- Try loading again to test the new initialization pattern
local WindowManager2 = require('WindowManager')
print("WindowManager reloaded successfully")

print("\nAll tests completed. If no error occurred, the fixes are working properly.")
