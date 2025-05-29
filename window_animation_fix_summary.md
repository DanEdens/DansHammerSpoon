# Window Animation Issue Investigation and Fix

## Problem Description
The window snapping functionality in WindowManager.lua was experiencing:
- Windows animating to new positions instead of snapping instantly
- Inconsistent positioning due to simultaneous resize and reposition operations
- Windows sometimes ending up in unexpected locations along the animation route

## Root Cause Analysis

### Issue Located
The problem was in the `setFrameInScreenWithRetry` function in WindowManager.lua at lines 345-346 and 382:

```lua
-- Save original animation duration and temporarily disable animations
local originalDuration = hs.window.animationDuration
hs.window.animationDuration = 0
...
-- Restore original animation duration
hs.window.animationDuration = originalDuration
```

### The Problem
The function was:
1. Saving the current `hs.window.animationDuration` value
2. Temporarily setting it to 0 for the window operation
3. **Restoring the original value afterwards**

If some other part of the system had set `animationDuration` to a non-zero value, this function would restore animations, causing the erratic behavior.

### Evidence
- Global animation duration was correctly set to 0 in both init.lua (line 442) and WindowManager.lua (line 11)
- Multiple window operation functions properly set `animationDuration = 0`
- Only the retry function was restoring potentially non-zero values

## Solution Implemented

### Changes Made
1. **WindowManager.lua**: Modified `setFrameInScreenWithRetry` function to ensure animations stay disabled:
   - Removed saving/restoring of original duration
   - Ensured `animationDuration = 0` at both start and end of function

2. **init.lua**: Added clarifying comment about the importance of keeping animations disabled

### Code Changes
```42:45:WindowManager.lua
-- Helper function to set window frame with verification and retry
function WindowManager.setFrameInScreenWithRetry(win, newFrame, retryCount)
    retryCount = retryCount or 3

    -- Ensure animations are always disabled for reliable positioning
    hs.window.animationDuration = 0
```

And at the end:
```378:381:WindowManager.lua
    -- Keep animations disabled for consistent window management
    hs.window.animationDuration = 0

    return frameCorrect
```

## Testing
- Configuration loads without syntax errors
- Hammerspoon reload successful
- No breaking changes to existing functionality

## Expected Outcome
- Window snapping should now be instant again
- No more animation-related positioning issues
- Consistent window management behavior across all operations

## Prevention
Added comments to make the intent clear for future maintainers that animations should remain disabled for reliable window positioning. 
