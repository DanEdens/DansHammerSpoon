# DragonGrid.lua Summary

## Overview
DragonGrid is a Hammerspoon module that provides a customizable grid interface for precise window management and screen navigation. It allows users to select areas of the screen through an interactive grid overlay that supports multiple precision layers for increasingly granular selections.

## Key Components

### Configuration and Setup
- Configurable grid size (2x2 to 5x5)
- Adjustable precision layers (1-4)
- Customizable colors for grid elements
- Two operating modes: Screen Mode and Window Mode
- Configurable background opacity (10%-50%)

### Core Functionality
1. **Grid Creation and Display**
   - Creates a canvas overlay with grid cells
   - Supports both full screen and window-specific targeting
   - Displays numbered cells for selection via keyboard or mouse

2. **Navigation System**
   - Multiple precision layers for increasingly fine-grained selection
   - Each selection zooms into the chosen cell to create a sub-grid
   - Status indicators showing current position and layer

3. **Interaction Methods**
   - Number key selection (supports up to 27 cells with modifier combinations)
   - Mouse click selection
   - Drag mode for continuous selection
   - Escape key to cancel selection

4. **Settings Management**
   - Menu bar interface for configuration
   - Runtime configuration changes
   - Persistent settings

## User Interface
- Interactive grid overlay with numbered cells
- Visual feedback for hover and selection states
- Status indicators for current layer and position

## Hotkey System
- Configurable hotkeys for launching the grid
- Automatically binds number keys when grid is active
- Special key combinations for cells beyond 1-9:
  - Cmd+[1-9] for cells 1-9
  - Cmd+Shift+[1-9] for cells 10-18
  - Cmd+Shift+Alt+[1-9] for cells 19-27

## Implementation Details
- Modular design with clear separation of concerns
- Event-driven architecture for handling user interactions
- Advanced canvas drawing for visual elements
- Cleanup system to prevent resource leaks

## Usage
The module can be loaded in Hammerspoon's init.lua and configured with custom settings and hotkeys.

```lua
-- Example usage
local DragonGrid = hs.loadSpoon("DragonGrid")
DragonGrid:setConfig({
    gridSize = 3,
    maxLayers = 2,
    colors = {
        background = { red = 0, green = 0, blue = 0, alpha = 0.3 }
    }
})
DragonGrid:bindHotkeys({
    toggle = {{"cmd", "alt"}, "g"},
    settings = {{"cmd", "alt", "shift"}, "g"}
})
``` 
