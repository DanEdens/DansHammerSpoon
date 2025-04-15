# DragonGrid Multi-Screen Capabilities

DragonGrid has been enhanced to fully support multi-screen setups, allowing for seamless mouse positioning across all connected displays.

## Key Features

### Screen Detection
- **Automatic Current Screen** - DragonGrid automatically detects the screen where the mouse cursor is currently located
- **Click-Based Screen Selection** - Clicking on any screen during grid operation will activate the grid on that screen
- **Support for Window or Full-Screen Modes** - Grid can operate either on the current window or the entire screen

### Multi-Level Grids Across Screens
- **Proper Screen Boundaries** - Grid cells are properly calculated using the actual screen coordinates
- **Position Awareness** - Status indicators show the current absolute screen coordinates
- **Screen-Specific Canvas** - Each grid level creates a canvas specific to the correct screen

### Navigation and Position Display
- **Visual Screen Positioning** - Shows current screen position coordinates in the grid header
- **Clear Grid Levels** - Displays which level of precision you're currently at (e.g., "LEVEL 2 OF 3")
- **Intelligent Click Handling** - Properly processes clicks based on absolute screen coordinates

## How It Works

1. **Initial Grid Creation**
   - When activated, DragonGrid determines the current screen by mouse position
   - Creates a grid overlay at the exact position and dimensions of the screen

2. **Multi-Level Selection**
   - Each level accurately narrows down the selection area
   - The system tracks which screen contains the selection
   - Creates the next level grid with proper screen-relative positioning

3. **Multi-Screen Drag Operations**
   - Start a drag operation on one screen
   - Complete it on another screen with pixel-perfect accuracy
   - Maintains proper coordinates across screens of different sizes and positions

## Under the Hood

DragonGrid uses several Hammerspoon APIs to enable multi-screen functionality:

- `hs.mouse.getCurrentScreen()` - Gets the screen containing the mouse cursor
- `hs.screen.allScreens()` - Retrieves all connected screens
- Screen frame properties (`x`, `y`, `w`, `h`) - Used for precise positioning

## Recent Improvements

- Fixed grid positioning across multiple monitors
- Added visual indicators showing absolute screen position
- Improved screen detection based on mouse and click position
- Fixed undo/back functionality when moving between screens
- Enhanced outer area shading to work correctly across monitors

## Usage Tips for Multi-Screen Setups

- Use Window Mode (`⌘W`) when focusing on applications spanning multiple screens
- The grid header shows your current screen position to help with orientation
- Undo (`⌘U`) works properly across screens, maintaining context
- Click directly on any screen to activate the grid there

By properly handling coordinates across all displays, DragonGrid now provides a consistent and accurate mouse positioning system regardless of your monitor setup. 
