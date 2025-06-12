# WindowToggler Toggle Enhancement

## Summary

Enhanced the main `toggleWindowPosition` function to intelligently cycle between Location 1 and Location 2, replacing the previous behavior that toggled with a "nearly full" layout.

## New Toggle Behavior

### Smart Cycling Logic

The enhanced toggle function now implements intelligent cycling between two saved positions:

1. **Both locations exist**: Cycles between Location 1 ↔ Location 2
2. **Only Location 1 exists**: When at Location 1, saves current position as Location 2
3. **Only Location 2 exists**: When at Location 2, saves current position as Location 1  
4. **No locations exist**: Saves current position as Location 1

### User Workflow

1. **First use**: Position window and press `Cmd+Ctrl+Alt+W` → saves as Location 1
2. **Second use**: Move to different position and press `Cmd+Ctrl+Alt+W` → saves as Location 2
3. **Subsequent uses**: Press `Cmd+Ctrl+Alt+W` to cycle between the two saved positions

## Key Improvements

### Enhanced User Experience

- **Visual Feedback**: Clear alerts showing which location is active (e.g., "AppName: Location 1 → Location 2")
- **Automatic Setup**: No need to manually save locations first - the toggle function creates them automatically
- **Smart Detection**: Uses 10-pixel tolerance to detect current position matches

### Workflow Benefits

- **Two-Position Workflow**: Perfect for users who regularly switch between two specific window positions
- **No Manual Setup Required**: Just start using the toggle key and it builds the locations automatically
- **Clear Status**: Always know which location you're moving to or from

## Technical Implementation

### Position Matching

```lua
local function positionMatches(savedFrame, tolerance)
    if not savedFrame then return false end
    tolerance = tolerance or 10
    return math.abs(currentFrame.x - savedFrame.x) < tolerance and
           math.abs(currentFrame.y - savedFrame.y) < tolerance and
           math.abs(currentFrame.w - savedFrame.w) < tolerance and
           math.abs(currentFrame.h - savedFrame.h) < tolerance
end
```

### Intelligent State Management

The function determines the appropriate action based on:

- Which locations exist for the current window
- Whether the current position matches any saved location
- Provides automatic fallbacks for edge cases

## Updated Documentation

### Hotkey Description

- **Before**: "Toggle Window Position"
- **After**: "Toggle Between Location 1 and 2"

### README Updates

- Updated hotkey mapping table
- Revised Basic Window Toggle usage pattern
- Updated Key Features section

## User Impact

### Before

- Required saving positions to Location 1/2 manually via separate hotkeys
- Main toggle only worked with "nearly full" layout
- Less intuitive workflow

### After  

- Single hotkey automatically manages two positions
- Builds saved locations automatically through usage
- More intuitive and streamlined workflow
- Better suited for common two-position use cases

## Commit Information

- **Initial Enhancement**: f15b99f
- **Reliability Improvement**: abcb49c
- **Files Modified**: 3 (WindowToggler.lua, hotkeys.lua, README.md) + 1 reliability fix
- **Lines Changed**: 74 insertions, 40 deletions + 7 insertions, 7 deletions

## Post-Enhancement Reliability Fix

### Window Movement Delay Problem

After implementing the toggle enhancement, discovered the same window movement delay issues that were previously solved in WindowManager.lua. The problem occurred when `win:setFrame()` calls didn't reliably position windows due to timing and animation issues.

### Solution: Reuse Proven Retry Logic

**Replaced all direct `win:setFrame()` calls with `WindowManager.setFrameInScreenWithRetry()`:**

- **Robust Positioning**: Uses retry logic with verification to ensure frames are set correctly
- **Animation Handling**: Automatically disables animations for reliable positioning  
- **Tolerance Checking**: Verifies position with 10-pixel tolerance and retries if needed
- **Alternative Methods**: Falls back to `setFrameWithWorkarounds()` if standard method fails

**Benefits of reusing existing solution:**

- **No Code Duplication**: Leverages proven WindowManager functionality
- **Consistent Behavior**: Same reliable positioning across all window management functions
- **Maintenance**: Single point of maintenance for retry logic

This ensures that WindowToggler position changes are as reliable as other WindowManager operations, eliminating any delay or positioning issues.

This enhancement transforms the WindowToggler from a layout-based tool into a true two-position cycling system, making it much more useful for common window management workflows.
