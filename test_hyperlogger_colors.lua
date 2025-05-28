-- test_hyperlogger_colors.lua
-- Test colored log messages with HyperLogger

-- Load HyperLogger module
local HyperLogger = require('HyperLogger')

-- Create a logger instance
local log = HyperLogger.new('TestColors', 'debug')

-- Test different log levels with colored output
print("\n---- Testing HyperLogger with colored output ----\n")

-- Info level (blue)
log:i("This is an informational message - should be blue")

-- Debug level (gray)
log:d("This is a debug message - should be gray")

-- Warning level (orange/yellow)
log:w("This is a warning message - should be orange/yellow")

-- Error level (red)
log:e("This is an error message - should be red")

-- Multiple parameters
log:i("Test with multiple", "parameters")

-- Show the colors of nested modules
local nested = {}
nested.log = HyperLogger.new('NestedModule', 'debug')
nested.log:i("Log message from a nested module - still blue")
nested.log:e("Error from nested module - should be red")

print("\n---- Test completed ----\n")
