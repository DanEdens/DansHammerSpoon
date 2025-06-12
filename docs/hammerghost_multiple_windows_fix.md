# HammerGhost Multiple Windows Fix

## Problem
When reloading the Hammerspoon configuration (`hs.reload()`), multiple HammerGhost windows were being opened instead of none. The expected behavior is that HammerGhost should only open when explicitly triggered by a hotkey.

## Root Cause
The issue was in `init.lua` where HammerGhost was being automatically initialized during configuration loading:

```lua
-- Old problematic code
local hammerghost = spoon.HammerGhost:init()
if hammerghost then
    hammerghost:bindHotkeys({
        toggle = { { "cmd", "alt", "ctrl" }, "H" }
    })
end
```

This meant every time the configuration was reloaded, a new HammerGhost instance would be created and initialized.

## Solution
Changed the initialization to only occur when the hotkey is pressed:

```lua
-- New fixed code
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    local hammerghost = spoon.HammerGhost:init()
    if hammerghost then
        hs.logger.new("init.lua"):i("HammerGhost spoon opened successfully via hotkey.")
    else
        hs.logger.new("init.lua"):e("Failed to open HammerGhost spoon via hotkey.")
    end
end)
```

## Changes Made
1. **Removed automatic initialization**: No longer calls `spoon.HammerGhost:init()` during configuration loading
2. **Hotkey-only initialization**: HammerGhost is only initialized when `Cmd+Alt+Ctrl+H` is pressed
3. **Improved logging**: Added clearer log messages to distinguish hotkey-triggered initialization

## Testing
- Configuration loads without opening HammerGhost windows
- Pressing `Cmd+Alt+Ctrl+H` opens HammerGhost as expected
- Reloading configuration (`hs.reload()`) no longer creates duplicate windows

## Files Modified
- `init.lua` - Lines 16-27: Replaced automatic initialization with hotkey-triggered initialization

## Lessons Learned
- Spoon initialization should be carefully managed to prevent duplicate instances
- Configuration reload behavior should be considered when implementing automatic features
- Hotkey-triggered initialization provides better user control over when features are activated

## Date
2024-12-19

## Status
✅ Completed and tested 