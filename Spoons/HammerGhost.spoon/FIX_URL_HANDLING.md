# URL Event Handling Fix for HammerGhost.spoon

## Issue
The HammerGhost.spoon Hammerspoon component had a critical issue with URL event handling. In the `init()` function, the code was attempting to set a callback on `self.server` using `self.server:setCallback()`, but `self.server` was never initialized. This caused URL scheme-based communication between JavaScript and Lua to fail.

## Fix Details

1. **Added Server Initialization**:
   - Added `obj.server = nil` to the object's property declarations
   - Added initialization code: `self.server = hs.urlevent.watcher.new()` before attempting to use the server object

2. **Improved URL Parsing**:
   - Enhanced the navigation callback with better URL parsing to extract hosts and parameters
   - Added detailed debug logging for URL parameters

3. **Added Testing Capabilities**:
   - Created a new `testURLHandling()` method that:
     - Creates a test item if none exists
     - Generates a test URL to trigger the selectItem handler
     - Uses `hs.execute("open...")` to trigger URL handling outside of the WebView

4. **Updated Documentation**:
   - Added a new section to README.md on testing URL handling
   - Added examples for manual URL testing and JavaScript URL navigation

## How to Test

```lua
-- Load the spoon
hs.loadSpoon("HammerGhost")

-- Start the UI
spoon.HammerGhost:start()

-- Test URL handling
spoon.HammerGhost:testURLHandling()
```

Or manually test with:

```lua
hs.execute("open 'hammerspoon://selectItem?id=1'")
```

## Benefits

This fix enables:
1. JavaScript-to-Lua communication via URL scheme
2. All button/interaction handlers to work properly
3. Better debugging of URL events with enhanced logging
4. Easy testing via the new test helper method

## Future Improvements

Potential enhancements to consider in the future:
1. Add more robust error handling for URL parameter parsing
2. Consider using hs.webview.usercontent instead of URL scheme for better performance
3. Add more comprehensive testing utilities 
