# HammerGhost Multiple Windows Fix

## Problem
When reloading the Hammerspoon configuration (`hs.reload()`), multiple HammerGhost windows were being opened instead of none. The expected behavior is that HammerGhost should only open when explicitly triggered by a hotkey.

## Root Cause
The issue was twofold:
1. In `init.lua` where HammerGhost was being automatically initialized during configuration loading
2. In the HammerGhost spoon's `init()` method which automatically created and showed the window

```lua
-- Old problematic code in init.lua
local hammerghost = spoon.HammerGhost:init()
if hammerghost then
    hammerghost:bindHotkeys({
        toggle = { { "cmd", "alt", "ctrl" }, "H" }
    })
end
```

```lua
-- Old problematic code in HammerGhost spoon init()
function obj:init()
    -- ... setup code ...
    -- Initialize UI
    self:createMainWindow()  -- This created and showed the window immediately
    return self
end
```

## Solution
**Phase 1**: Changed initialization approach in `init.lua` to use hotkey-triggered initialization
**Phase 2**: Modified the HammerGhost spoon's `init()` method to not create the window automatically

### Final Implementation

In `init.lua`:
```lua
-- Load the HammerGhost spoon
hs.loadSpoon("HammerGhost")

-- Initialize the HammerGhost spoon (no window will be created automatically)
local hammerghost = spoon.HammerGhost:init()
if hammerghost then
    hs.logger.new("init.lua"):i("HammerGhost spoon initialized successfully.")
else
    hs.logger.new("init.lua"):e("Failed to initialize HammerGhost spoon.")
end

-- Bind hotkey for HammerGhost toggle
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
    if hammerghost then
        hammerghost:toggle()
        hs.logger.new("init.lua"):i("HammerGhost toggled via hotkey.")
    else
        hs.logger.new("init.lua"):e("HammerGhost not available for toggle.")
    end
end)
```

In `Spoons/HammerGhost.spoon/init.lua`:
```lua
function obj:init()
    -- ... setup code ...
    -- Don't create window automatically - let toggle() handle window creation when needed
    -- This prevents unwanted windows on initialization/reload
    return self
end
```

## Changes Made
1. **Removed automatic window creation**: Modified HammerGhost spoon's `init()` method to not call `createMainWindow()`
2. **Hotkey-triggered window display**: HammerGhost window only appears when `Cmd+Alt+Ctrl+H` is pressed
3. **Proper initialization flow**: Spoon is initialized during config load but window creation is deferred
4. **Uses toggle() method**: Leverages the existing toggle functionality for proper show/hide behavior

## Testing
- Configuration loads without opening HammerGhost windows
- Pressing `Cmd+Alt+Ctrl+H` opens HammerGhost as expected
- Pressing the hotkey again hides the HammerGhost window
- Reloading configuration (`hs.reload()`) no longer creates any windows
- The toggle() method properly handles window creation when needed

## Files Modified
- `init.lua` - Lines 16-33: Simplified initialization and hotkey binding
- `Spoons/HammerGhost.spoon/init.lua` - Lines 93-95: Removed automatic window creation

## Lessons Learned
- Spoon initialization should be separated from UI creation for better control
- The `toggle()` method in spoons often provides the intended behavior for conditional UI display
- Configuration reload behavior should be considered when implementing any automatic features
- Always check what a spoon's `init()` method does before calling it during configuration load

## Date
2024-12-19

## Status
✅ Completed and thoroughly tested 