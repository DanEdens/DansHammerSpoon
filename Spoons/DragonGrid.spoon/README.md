# DragonGrid.spoon

Precision mouse movement and control using a multi-level grid system for Hammerspoon.

## Overview

DragonGrid is a powerful Hammerspoon Spoon that allows you to navigate your screen precisely using keyboard or mouse input through a multi-level grid system. It's especially useful for:

- Precise mouse positioning without needing a physical mouse or trackpad
- Performing click and drag operations via keyboard commands
- Working with applications that require precise mouse positioning
- Operating across multiple displays
- Quickly moving the mouse cursor to exact screen locations

## Features

- Multi-level grid system (configurable up to 4 levels) for increasing precision
- Screen mode and window mode operation
- Keyboard-driven operation with hotkeys
- Click and drag functionality 
- Visual interface with cell numbers and help text
- Easy configuration via menubar

## Installation

1. Download and copy the folder `DragonGrid.spoon` to `~/.hammerspoon/Spoons/` folder.
2. In your `~/.hammerspoon/init.lua` add the following code:

```lua
hyper = {"cmd", "alt", "ctrl", "shift"}  -- Your preferred modifier combination
hs.loadSpoon('DragonGrid')
spoon.DragonGrid:bindHotKeys({
  show = {hyper, "g"}  -- Use your preferred key combination
}):start()
```

## Usage

### Basic Operation

1. Trigger DragonGrid with your assigned hotkey (e.g., hyper+g)
2. A grid will appear over your screen (or focused window in window mode)
3. Select a cell by:
   - Using keyboard: ⌘+number keys
   - Clicking directly on a numbered cell
4. For higher precision, select cells in subsequent grid levels
5. On the final level selection, your mouse cursor will be positioned

### Keyboard Commands

When the grid is active:
- ⌘1-9: Select cells 1-9
- ⌘⇧1-9: Select cells 10-18
- ⌘⇧⌥1-9: Select cells 19-27
- ⌘Space: Perform left click at current position
- ⌘R: Perform right click at current position
- ⌘M: Mark position for drag start
- ⌘D: Complete drag operation (after setting mark)
- ⌘W: Toggle between screen mode and window mode
- ⌘U: Undo last selection (go back to previous level)
- ⌘Escape: Cancel and close the grid

### Drag and Drop

1. Activate DragonGrid
2. Press ⌘M to mark the start position for dragging
3. Select a cell to mark the start position
4. Navigate to the desired destination using the grid
5. Press ⌘D to complete the drag operation

### Menubar Options

The DragonGrid menubar icon provides access to:
- Show/hide the grid
- Toggle window/screen mode
- Adjust grid size (2x2 up to 5x5)
- Configure the number of grid levels (1-4)

## Configuration

DragonGrid can be configured when loading:

```lua
hs.loadSpoon('DragonGrid')
spoon.DragonGrid.config.gridSize = 4  -- Change grid size (default: 3)
spoon.DragonGrid.config.maxLayers = 2  -- Change max layers (default: 2)
spoon.DragonGrid:start()
```

## License

MIT - See LICENSE file for details. 
