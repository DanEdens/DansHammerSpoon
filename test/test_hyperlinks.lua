-- Test script for hyperlinks in the Hammerspoon console
-- Run this in the Hammerspoon console directly to test link functionality

print("\n")
print("================================================")
print("  HYPERLOGGER HYPERLINK TEST SCRIPT")
print("================================================")
print("\nThis script tests if hyperlinks work in the Hammerspoon console.")
print("** IMPORTANT: You must run this in the actual Hammerspoon console, **")
print("** not through the command line, to properly test clicking links. **")
print("\n")

-- Test 1: Regular styled text with link
local styledtext = hs.styledtext
local text = styledtext.new("Click me to open Google", {
    color = { red = 0.4, green = 0.7, blue = 1.0 },
    underlineStyle = "single",
    backgroundColor = { red = 0.1, green = 0.1, blue = 0.2 },
    link = "https://www.google.com"
})
print("--- TEST 1: Regular HTML link ---")
print("The text below should be clickable and open Google in your browser:")
hs.console.printStyledtext(text)
print("\n")

-- Test 2: HyperLogger links
local HyperLogger = require("HyperLogger")
local logger = HyperLogger.new("TestLogger", "debug")

print("--- TEST 2: HyperLogger links ---")
print("The file/line references below should be clickable and open the file in your editor:")
logger:i("This is an info message")
logger:d("This is a debug message")
logger:w("This is a warning message")
logger:e("This is an error message")
print("\n")

-- Test 3: Test with explicit file path
print("--- TEST 3: HyperLogger with explicit file path ---")
logger:i("This message has a custom path that should be clickable", "test_hyperlinks.lua", 32)
print("\n")

-- Test 4: URL Event Handler
print("--- TEST 4: Custom URL handler ---")
hs.urlevent.bind("test", function(eventName, params)
    print("Test URL handler called with params:", hs.inspect(params))
    hs.alert.show("URL Handler Triggered with: " .. params.param)
end)

local testLinkText = styledtext.new("Click me to trigger a custom URL handler", {
    color = { red = 0.4, green = 0.7, blue = 1.0 },
    underlineStyle = "single",
    backgroundColor = { red = 0.1, green = 0.1, blue = 0.2 },
    link = "hammerspoon://test?param=Hello_World"
})
hs.console.printStyledtext(testLinkText)

-- Create a styled text with a document icon for better visibility
local improvedLink = styledtext.new("\n📄 Click this improved link style", {
    color = { red = 0.4, green = 0.7, blue = 1.0 },
    font = { name = "Menlo", size = 14 },
    underlineStyle = "single",
    backgroundColor = { red = 0.1, green = 0.1, blue = 0.2 },
    link = "hammerspoon://test?param=improved_style"
})
hs.console.printStyledtext(improvedLink)

print("\n\nINFO: If links aren't clickable, make sure you're running this script directly in")
print("the Hammerspoon console, not via the command line or Cursor/IDE console.")
