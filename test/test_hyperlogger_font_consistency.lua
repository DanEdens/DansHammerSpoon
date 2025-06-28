-- test_hyperlogger_font_consistency.lua
-- Test script to verify font consistency and formatting across different HyperLogger instances

local HyperLogger = require("HyperLogger")

-- Create a styled header
local function printHeader(text)
    local styledText = hs.styledtext.new("\n==== " .. text .. " ====\n", {
        font = { name = "Menlo", size = 18 },
        color = { red = 0.2, green = 0.7, blue = 1.0 }
    })
    hs.console.printStyledtext(styledText)
end

printHeader("HyperLogger Font Consistency Test")

-- Create multiple loggers with different namespaces
local mainLogger = HyperLogger.new("MainApp", "debug")
local windowLogger = HyperLogger.new("WindowManager", "debug")
local fileLogger = HyperLogger.new("FileSystem", "debug")
local appLogger = HyperLogger.new("AppLauncher", "debug")

-- Clear any previous loggers
HyperLogger.resetLoggers()

-- Recreate our loggers for a clean test
local mainLogger = HyperLogger.new("MainApp", "debug")
local windowLogger = HyperLogger.new("WindowManager", "debug")
local fileLogger = HyperLogger.new("FileSystem", "debug")
local appLogger = HyperLogger.new("AppLauncher", "debug")

printHeader("Standard Logger Messages")

-- Log standard messages from each logger
mainLogger:i("Info message from MainApp")
windowLogger:d("Debug message from WindowManager")
fileLogger:w("Warning message from FileSystem")
appLogger:e("Error message from AppLauncher")

printHeader("Custom File/Line Messages")

-- Log messages with explicit file and line information
mainLogger:i("Custom file info from MainApp", "custom_file.lua", 42)
windowLogger:d("Custom file info from WindowManager", "window_manager.lua", 123)
fileLogger:w("Custom file info from FileSystem", "file_system.lua", 78)
appLogger:e("Custom file info from AppLauncher", "app_launcher.lua", 256)

printHeader("Testing Global AppLogger")

-- Create a global AppLogger similar to what we do in init.lua
_G.AppLogger = HyperLogger.new("GlobalApp", "debug")

-- Log messages using the global logger
_G.AppLogger:i("Info message from GlobalApp")
_G.AppLogger:d("Debug message from GlobalApp")
_G.AppLogger:w("Warning message from GlobalApp")
_G.AppLogger:e("Error message from GlobalApp")

printHeader("Complex Data Type Handling")

-- Test logging of various data types
local testTable = { name = "Test", id = 123, nested = { a = 1, b = 2 } }
local testFunction = function() return "test" end

mainLogger:i("Logging a table:", "test_file.lua", 50)
mainLogger:i(testTable, "test_file.lua", 51)
mainLogger:i("Logging a function reference:", "test_file.lua", 52)
mainLogger:i(testFunction, "test_file.lua", 53)
mainLogger:i("Logging nil:", "test_file.lua", 54)
mainLogger:i(nil, "test_file.lua", 55)

printHeader("Test Complete")
print("All messages should have consistent font styling and formatting")
print("No messages should show timestamps")
print("File and line information should be properly displayed in all cases")
