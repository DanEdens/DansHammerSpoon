# DragonGrid Multi-Screen Support Fix

## Issue Fixed

The DragonGrid module had an inconsistent behavior between level 1 and higher-level grids when working with multiple monitors. Specifically:

1. Level 1 grid correctly drew a canvas confined to the boundaries of the screen or window
2. Level 2+ grids incorrectly drew a full-screen canvas with shaded areas outside the selection
3. This caused visual inconsistency and could block content on other parts of the screen
4. It also created interaction issues when using clicks to navigate through the grid on secondary monitors

## Changes Made

The fix modifies the `createNextLevelGrid` function to match the behavior of the first level grid:

1. Instead of creating a canvas covering the entire screen, we now create a canvas that fits exactly to the dimensions of the selected cell
2. The canvas is positioned at the absolute coordinates of the selection
3. All drawing is done relative to the canvas boundaries (0,0 is top-left of the selection)
4. Mouse clicks are converted from canvas-relative to absolute screen coordinates

## Technical Implementation Details

Key changes to the `createNextLevelGrid` function:

```lua
-- Before: Create canvas covering the entire screen
dragonGridCanvas = hs.canvas.new(screenFrame)

-- After: Create canvas with exact dimensions of the selection area
dragonGridCanvas = hs.canvas.new({
    x = currentSelection.x,
    y = currentSelection.y,
    w = currentSelection.w,
    h = currentSelection.h
})
```

For click handling:

```lua
-- Before: Use raw x,y coordinates
dragonGridCanvas:mouseCallback(function(canvas, event, id, x, y)
    if event == "mouseUp" then
        DragonGrid.handleGridClick(x, y)
    end
end)

-- After: Convert canvas-relative coordinates to absolute screen coordinates
dragonGridCanvas:mouseCallback(function(canvas, event, id, x, y)
    if event == "mouseUp" then
        local absX = x + currentSelection.x
        local absY = y + currentSelection.y
        DragonGrid.handleGridClick(absX, absY)
    end
end)
```

## Benefits

1. **Consistent Visual Experience**: All grid levels now behave the same way
2. **Non-blocking UI**: Grids only appear where needed rather than covering the entire screen
3. **Improved Multi-Screen Support**: Interactions work correctly even when navigating across monitors
4. **Better Performance**: The canvas covers a smaller area, potentially improving rendering performance

## Testing

The fix has been tested with:
- Multiple monitors with different resolutions and positions
- Grid operations spanning monitors
- Drag operations starting on one monitor and ending on another
- Different grid sizes and levels of precision 
