# DragonGrid for Hammerspoon

DragonGrid is a mouse positioning grid system for [Hammerspoon](https://www.hammerspoon.org/) that enables precise mouse control using keyboard shortcuts.

## Features

- **Multi-level Grid System**: Navigate through multiple layers of grids to achieve increasingly precise mouse positioning
- **Configurable Grid Layers**: Set how many levels of precision you want (default is 2)
- **Click Actions**: Perform various mouse clicks (left, right, middle, double)
- **Drag Operations**: Easily perform drag operations by setting start and end points
- **Window or Screen Mode**: Choose to operate on the current window or the entire screen
- **Multi-Screen Support**: Seamlessly use DragonGrid across multiple displays with proper coordinate handling

## Usage

1. Press ⌘X to display the grid
2. Use ⌘1-9 to select a grid cell
3. Continue selecting cells at each level until you reach your desired precision
4. Use ⌘Space to click at the final position

### Keyboard Shortcuts

When the grid is active:
- **⌘1-9**: Select grid cell
- **⌘Space**: Left click
- **⌘R**: Right click
- **⌘Esc**: Cancel operation
- **⌘U**: Go back one level
- **⌘W**: Toggle window/screen mode
- **⌘M**: Mark position for drag
- **⌘D**: Complete drag operation

## Configuration

You can configure DragonGrid in your Hammerspoon init.lua file:

```lua
local dragonGrid = hs.loadSpoon("DragonGrid")

-- Configure with 3 levels of precision and a 4x4 grid
dragonGrid:setConfig({
    gridSize = 4,      -- Grid dimension (4x4)
    maxLayers = 3,     -- 3 levels of precision
})

-- Bind hotkeys
dragonGrid:bindHotkeys({
    toggle = {{"cmd"}, "x"}
})
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| gridSize | 3 | Grid dimension (3x3, 4x4, etc.) |
| maxLayers | 3 | Number of grid levels for precision |
| colors | (predefined) | Color configuration for visual elements |

## How It Works

DragonGrid uses a multi-level approach to precise mouse positioning:

1. **First Level**: Divides the screen or window into a grid (default 3x3)
2. **Second Level**: Each selected cell becomes another grid with 9 more cells
3. **Third Level**: Allows for even finer selection within the second level cell
4. **Final Level**: Upon final selection, the mouse is positioned at the center of the chosen cell

This allows for exponentially increasing precision with each level. With a 3x3 grid and 3 levels, you can position the mouse at one of 27 (3³) distinct positions.

## Multi-Screen Capabilities

DragonGrid fully supports multi-screen setups with the following features:

- **Automatic Screen Detection**: Determines which screen contains the mouse cursor
- **Click-Based Screen Selection**: Click on any screen to activate the grid there
- **Proper Coordinate Handling**: Maintains accurate positioning across screens of different sizes
- **Visual Position Indicators**: Displays current screen coordinates in the grid header
- **Cross-Screen Drag Operations**: Start a drag on one screen and complete it on another

For more detailed information about multi-screen functionality, see the [DragonGrid Multi-Screen documentation](docs/DragonGrid-MultiScreen.md).

Recent fixes for multi-screen support can be found in the [Multi-Screen Fix documentation](docs/DragonGrid-MultiScreen-Fix.md).

## Installation

1. Copy the DragonGrid.lua file to your Hammerspoon Spoons directory (~/.hammerspoon/Spoons/)
2. Add the following to your Hammerspoon init.lua:

```lua
hs.loadSpoon("DragonGrid")
spoon.DragonGrid:bindHotkeys({toggle = {{"cmd"}, "x"}})
``` 
