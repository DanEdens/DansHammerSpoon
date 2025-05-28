-- test_hyperlogger.lua
-- Test script for HyperLogger editor integration

-- Load the HyperLogger module
local HyperLogger = require("HyperLogger")

-- Create a test logger
local logger = HyperLogger.new("TestLogger", "debug")

-- Log some messages to test the clickable links
print("==== HyperLogger Editor Integration Test ====")
print("Test clicking on the log messages in the Hammerspoon console.")
print("Each log should be clickable and open the file in the editor specified by $EDITOR")
print("Current value of $EDITOR: " .. (os.getenv("EDITOR") or "not set"))
print("")

logger:i("This is an info message")
logger:d("This is a debug message")
logger:w("This is a warning message")
logger:e("This is an error message")

-- Log with explicit file and line info
logger:i("This message has custom file and line info", "test_hyperlogger.lua", 20)

print("")
print("==== Test Complete ====")
print("Check if clicking on the log messages opens the file in your editor")
print("If $EDITOR is not set, it will default to 'cursor'")
