# Hammerspoon Configuration

![Hammerspoon Logo](https://www.hammerspoon.org/images/hammerspoon.png)

A powerful, customized Hammerspoon configuration for macOS automation and window management.

## Overview

This Hammerspoon configuration provides a comprehensive set of tools for macOS automation, featuring:

- Advanced window management with multiple layouts and precise positioning
- KineticLatch system for intuitive alt-drag window manipulation
- DragonGrid system for pixel-perfect mouse control
- Smart application launching with window selection
- File and project management
- Device connection handling
- Enhanced debugging with clickable-ish logs
- Automatic Spoon loading and initialization

The configuration is modular, customizable, and designed for power users seeking to streamline their workflow.

## Core Modules

### KineticLatch

**The Mad Tinker's Window Manipulation Contraption** 🔧⚡

A kinetic window latching system that allows you to grab and manipulate windows from anywhere on their surface using modifier keys - just like those fancy Linux window managers and Windows utilities, but with more MADNESS!

- **Alt + Left-Click + Drag**: Move windows from any point on their surface
- **Alt + Right-Click + Drag**: Resize windows from any point
- **Configurable Modifiers**: Customize keys and mouse buttons
- **Smooth Operation**: Lag-free, responsive window manipulation
- **Auto-Focus**: Automatically brings manipulated windows to the foreground
- **Sensitivity Control**: Fine-tune responsiveness of kinetic movements

See `Spoons/KineticLatch.spoon/README.md` for complete details.

### DragonGrid

A precision mouse positioning system that displays an interactive grid overlay, allowing for pixel-perfect mouse control.

- Multi-level grid system for increasing precision
- Window or screen modes
- Click and drag operations
- Visual feedback and customizable appearance
- Multi-screen support

See [DragonGrid Documentation](docs/DragonGrid.md) for complete details.

### WindowManager

Comprehensive window management with predefined layouts and precise positioning.

- Move windows to specific screen positions (corners, halves, etc.)
- Apply predefined layouts for different workflow scenarios
- Save and restore window positions
- Multi-screen support with easy window movement between displays

### AppManager

Smart application launching with window selection and project integration.

- Launch applications or focus existing windows
- Select between multiple windows of the same application
- Open applications with specific projects
- Integration with FileManager for project selection

### FileManager

File and project management capabilities for quick access to commonly used files and projects.

- Quick access to frequently edited configuration files
- Project directory management
- Editor selection for opening files
- Recent file tracking

### ProjectManager

Job/project management system to track and manage development projects.

- Create, edit, and delete project definitions with paths and descriptions
- Set and track active project for current work context
- Open projects in Finder, Terminal, or code editors
- Persistent storage of project data between sessions
- Quick access via keyboard shortcuts

See [ProjectManager_README.md](docs/ProjectManager_README.md) for complete details.

### HyperLogger

Enhanced logging system with clickable log messages for easier debugging.

- File and line information for each log message
- Clickable links in the console to open source files
- Compatible with Hammerspoon's standard logging system
- Automatic caller information tracking

## Key Keyboard Shortcuts

Shortcuts use these modifier combinations:
- **hammer** = Cmd+Ctrl+Alt
- **hyper** = Cmd+Shift+Ctrl+Alt

### Window Management

| Shortcut | Action |
|----------|--------|
| hammer+1 | Move window to top-left corner |
| hammer+2 | Move window to top-right corner |
| hammer+3 | Full screen window |
| hammer+4 | Left wide layout |
| hammer+6 | Small left side |
| hammer+7 | Toggle between small right side and right half layouts |
| hammer+0 | Horizontal split |
| hyper+0 | Vertical split |
| hammer+left/right/up/down | Move window in that direction |
| hyper+left | Move window to previous screen |
| hyper+right | Move window to next screen |
| hammer+F6 | Save window position |
| hammer+F7 | Restore window position |

### Applications

| Shortcut | Action |
|----------|--------|
| hammer+p | Open PyCharm |
| hyper+p | Open Cursor |
| hammer+b | Open Arc browser |
| hyper+b | Open Chrome |
| hammer+s | Open Slack |
| hammer+g | Open GitHub Desktop |
| hammer+\` | Open Cursor |
| hyper+\` | Open VS Code |

### KineticLatch (Alt-Drag Window Control)

| Shortcut | Action |
|----------|--------|
| hammer+a | Toggle KineticLatch on/off |
| hyper+a | Show KineticLatch status |
| meta+a | Run KineticLatch diagnostics |

**Usage:**

- **Alt + Left-Click + Drag**: Move windows from any point
- **Alt + Right-Click + Drag**: Resize windows from any point

### DragonGrid

| Shortcut | Action |
|----------|--------|
| hammer+x | Toggle DragonGrid |
| hyper+x | Show DragonGrid settings |

### Project Management

| Shortcut | Action |
|----------|--------|
| hammer+j | Show project manager UI |
| hyper+j  | Show active project info |

### File Management

| Shortcut | Action |
|----------|--------|
| hammer+e | Show file menu |
| hyper+e | Show editor menu |
| hammer+i | Open most recent image |

### Application Management
- **Quick App Switching & Project Launching**: Launch applications or focus them if already running
  - For programming tools like Cursor and GitHub Desktop, also shows project selection menu
  - **Search functionality** to filter projects and windows by typing
  - Support for entering custom paths directly in search field
  - List of projects comes from both the ProjectManager and a configurable source

## Setup and Installation

1. Install Hammerspoon from [hammerspoon.org](https://www.hammerspoon.org/) or via Homebrew:
   ```
   brew install --cask hammerspoon
   ```

2. Clone this repository to your Hammerspoon configuration directory:
   ```
   git clone https://github.com/yourusername/hammerspoon-config.git ~/.hammerspoon
   ```

3. Launch Hammerspoon or reload your configuration if already running

### Docker Setup for Development and Deployment

For development, testing, and deployment support, a Docker setup is available:

- **Development Environment**: A Docker container for validating and testing Hammerspoon configuration
- **Deployment Script**: For installing the configuration on actual macOS systems

See [DOCKER_SETUP.md](docs/DOCKER_SETUP.md) for detailed instructions.

## Customization

The configuration can be customized by editing the following files:

- `init.lua` - Main configuration file
- `hotkeys.lua` - Keyboard shortcut definitions
- `FileManager.lua` - Customize file and project lists
- `*.lua` modules - Each module can be customized for specific functionality

## Recent Improvements

Several improvements have been made to the codebase:

1. **Logger Initialization and Singleton Pattern Fixes** - Resolved issues with multiple logger instances
   - Centralized logger initialization in init.lua with global AppLogger
   - Updated modules to use the shared global logger
   - Improved HyperLogger module with better namespace defaults
   - Created diagnostic tools to identify and resolve logger issues
   - Fixed potential memory leaks from excessive logger creation
   - See [logger_fixes.md](logger_fixes.md) for complete details

2. **Enhanced HyperLogger with $EDITOR Integration** - Improved clickable log links to work with any editor
   - Now uses the $EDITOR environment variable to determine which editor to use
   - Supports common editors including Vim, Emacs, VS Code, Cursor, Nano, and Sublime Text
   - Automatically resolves editor paths using `which` command
   - Different syntax for different editors (line number formatting)
   - Provides robust error handling for file not found or editor launch failures
   - Makes debugging significantly easier with direct navigation to log source locations
   - **Fixed duplicate logging issue that caused every message to appear twice in the console**

3. **MCP Client Integration for Centralized Project Management** - Replaced hardcoded project references with dynamic calls to Omnispindle MCP server
   - **New MCPClient.lua module** providing HTTP client functionality for MCP server communication
   - **Centralized project management** - Single source of truth for project data from MCP server
   - **Intelligent fallback system** - Automatically uses hardcoded project list if MCP server unavailable
   - **Performance optimizations** - 5-minute caching to reduce server load and improve responsiveness
   - **Enhanced FileManager.lua** with MCP integration and new functions:
     - `refreshProjectsList()` - Force refresh projects from MCP server
     - `testMCPConnection()` - Test connectivity to MCP server
   - **Configuration via secrets** - MCP server URL, timeout, and port configurable through secrets file
   - **Comprehensive testing** - Integration tests to verify MCP functionality
   - **Transparent operation** - Existing functionality works unchanged, with centralized data when available
   - **Error handling and logging** - Graceful degradation with detailed logging for troubleshooting
   - See [mcp_integration_summary.md](mcp_integration_summary.md) for complete implementation details

4. **FileManager Most Recent Image Fix** - Fixed broken path handling in openMostRecentImage function
   - Fixed string trimming issue where `hs.execute` output contained trailing newlines
   - Added proper path escaping to handle filenames with spaces
   - Expanded image format support beyond PNG to include JPG, JPEG, GIF, BMP, and TIFF
   - Improved error handling with better logging and status checking
   - Used `find` command instead of `ls` for more robust file discovery
   - Added proper command execution status validation

5. **HammerGhost.spoon Critical Interaction Functions Fix** - Resolved missing core UI interaction functions
   - Implemented missing `configureItem`, `moveItem`, `showContextMenu`, and `cancelEdit` functions
   - Added proper URL event watcher initialization for JavaScript-to-Lua communication
   - Enhanced navigation callback to handle all expected URL schemes including drag-and-drop operations
   - Added comprehensive test suite to verify all interaction functions are working
   - Fixed the core issue where all UI interactions (select, edit, delete, move) were failing silently
   - Restored full functionality to the EventGhost-like macro editor interface
   - Added `testURLHandling()` function for debugging URL scheme communication
   - See [FIX_URL_HANDLING.md](Spoons/HammerGhost.spoon/FIX_URL_HANDLING.md) for technical details

6. **Merge Error Resolution** - Fixed critical initialization failure from merge conflict
   - Resolved runtime error: "attempt to index a nil value (global 'config')"
   - Removed 67 lines of incorrectly merged HammerGhost spoon code from main init.lua
   - Restored proper code organization: spoon code confined to Spoons/ directory
   - Fixed invalid function calls and undefined variable references
   - Maintained all existing functionality while ensuring clean initialization
   - See [fix_merge_error_summary.md](fix_merge_error_summary.md) for complete analysis

7. **Automatic Spoon Initialization** - Enhanced the Spoon loading system to automatically start Spoons
   - Automatically detects and calls the `start()` method for each loaded Spoon
   - Eliminates the need for manually starting individual Spoons in configuration
   - Provides visual feedback with alerts when Spoons are successfully started
   - Makes adding new Spoons to the configuration simpler and more consistent

8. **Window Position Toggling by Title** - Added WindowToggler module for toggling window positions by title
   - Remembers window positions by window title rather than just window ID
   - Allows toggling between custom positions and the nearlyFull layout
   - Works across application restarts as long as window titles remain the same
   - Provides hotkeys for toggling (hammer+w), listing saved positions (hyper+w), and clearing positions (hammer+q)
   - See [WindowToggler_README.md](docs/WindowToggler_README.md) for details

9. **Dynamic Hotkey Management** - Added smart dynamic hotkey display system
   - Automatically tracks and categorizes all hotkey bindings
   - Excludes temporary/placeholder functions from the hotkey list
   - Groups hotkeys into logical categories for easier reference
   - **Enhanced with persistent, toggleable window display**
   - **Wider, more readable layout with styled HTML and color coding**
   - **Fixed webview indexing errors with comprehensive error handling**
   - **Implemented multi-layered protection against resource leaks**
   - See [HotkeyManager_README.md](docs/HotkeyManager_README.md) for details

10. **HammerGhost URL Event Handling Fix** - Fixed WebKit-based communication in HammerGhost.spoon
    - Initialized the URL event watcher server that was missing
    - Added detailed URL parameter parsing and logging
    - Implemented testing utilities for URL event handling
    - See [Spoons/HammerGhost.spoon/FIX_URL_HANDLING.md](Spoons/HammerGhost.spoon/FIX_URL_HANDLING.md) for details

11. **DragonGrid Multi-Screen Support** - Fixed UI issues with the precision grid system when operating across multiple monitors
    - See [DragonGrid-MultiScreen-Fix.md](docs/DragonGrid-MultiScreen-Fix.md) for details
    - Enables seamless grid-based mouse positioning across all connected displays
    - Maintains consistent UI behavior between grid levels

12. **HyperLogger for Debugging** - Enhanced logging system with clickable log messages
    - Automatically captures file and line information
    - Displays clickable hyperlinks in the console
    - Makes debugging much easier by linking logs to source code

13. **GitHub Desktop Enhancements** - Specialized project selection when opening GitHub Desktop
    - Choose between existing GitHub Desktop windows
    - Open different projects even when GitHub Desktop is already running
    - Enter custom paths directly in the selection UI

14. **Hammerspoon OS Version Compatibility Fix** - Fixed error with operating system version reporting
    - Updated to handle the table return format of `hs.host.operatingSystemVersion()`
    - Properly formats version as string using major.minor.patch format
    - Prevents "attempt to concatenate a table value" errors during initialization

15. **Hotkey Binding Fix** - Fixed error with missing Finder function
    - Added missing `open_finder` function to AppManager module
    - Resolves "At least one of pressedfn, releasedfn or repeatfn must be a function" error
    - Ensures hyper+F hotkey correctly opens or focuses Finder
    - See [Hotkey-Fix.md](docs/Hotkey-Fix.md) for details

16. **HammerGhost Multiple Windows Fix** - Fixed duplicate HammerGhost windows opening on configuration reload
    - Removed automatic initialization of HammerGhost during configuration loading
    - Changed to hotkey-only initialization (Cmd+Alt+Ctrl+H) for better user control
    - Prevents multiple HammerGhost instances when using `hs.reload()`
    - Improved logging to distinguish hotkey-triggered initialization
    - See [hammerghost_multiple_windows_fix.md](hammerghost_multiple_windows_fix.md) for complete details

17. **Hotkey Binding Consistency Refactoring** - Standardized all hotkey bindings to follow consistent pattern
    - Extracted inline function definitions from hotkey bindings to separate named functions
    - Changed inconsistent modifier key usage (`{ "ctrl", "alt", "cmd" }`) to standard `hammer` and `_hyper` patterns
    - Added missing description strings to all hotkey bindings for better documentation
    - Created three new functions: `saveLayoutWithDialog()`, `restoreLayoutChooser()`, and `deleteLayoutChooser()`
    - Improved maintainability by separating function logic from hotkey definitions
    - Enhanced debugging capabilities with meaningful function names in logs
    - Established consistent pattern: `hs.hotkey.bind(modifier, "key", "Description", function() ModuleName.functionName() end)`
    - See [hotkey_refactor_summary.md](hotkey_refactor_summary.md) for complete details

18. **Window Toggle Functions Refactoring** - Moved window layout toggle functions from hotkeys.lua to WindowManager.lua
    - Moved toggle state variables (`rightLayoutState`, `leftLayoutState`, `fullLayoutState`) to WindowManager module
    - Refactored three toggle functions: `toggleRightLayout()`, `toggleLeftLayout()`, and `toggleFullLayout()`
    - Added missing layout definitions: `splitVertical`, `splitHorizontal`, `centerScreen`, and `bottomHalf`
    - Updated hotkey bindings to call `WindowManager.toggleXXXLayout()` instead of local functions
    - Improved code organization by centralizing all window management functionality in one module
    - Enhanced maintainability through proper separation of concerns and state encapsulation
    - See [window_toggle_refactor_summary.md](window_toggle_refactor_summary.md) for complete details

19. **Scrcpy Special Handling** - Added specialized support for command-line tools like scrcpy

- Created dedicated `open_scrcpy()` function that handles scrcpy as a command-line tool rather than traditional app
- Smart window detection by title patterns (scrcpy, device models, resolutions)
- Intelligent behavior: launch new instance if none exist, focus single window, or show chooser for multiple instances
- Supports multiple scrcpy instances with user-friendly selection interface
- Updated hotkey binding (hammer+f) to use the specialized function
- See [scrcpy_special_handling_fix.md](scrcpy_special_handling_fix.md) for complete details

20. **KineticLatch.spoon - Alt-Drag Window Control** - Implemented advanced window manipulation system

- **Alt + Left-Click + Drag**: Move windows from any point on their surface (like Linux window managers)
- **Alt + Right-Click + Drag**: Resize windows from any point
- **Event Tap System**: Intercepts mouse events before applications for smooth operation
- **Configurable Controls**: Customize modifier keys, mouse buttons, and sensitivity
- **Auto-Focus**: Automatically brings manipulated windows to the foreground
- **Performance Optimized**: Minimal debug logging and disabled animations for smooth operation
- **Publication Ready**: Complete with LICENSE file, README, example config, and docs.json
- **Mad Tinker Themed**: Embraces the "Madness Interactive" project aesthetic with kinetic terminology
- See `Spoons/KineticLatch.spoon/README.md` for complete documentation

## Recent Updates

- **Added Cursor with GitHub Desktop Integration**: Open projects in both Cursor IDE and GitHub Desktop simultaneously with hyper+g, ensuring final focus on Cursor while also updating GitHub Desktop with the selected project path.
- **Fixed HyperLogger Duplicate Messages**: Eliminated duplicate log entries in the console by preventing the custom logger from sending messages to both the standard logger and the styled console output.

## Recent Changes

### Module Loading Improvements

- Fixed loadConfig.lua to properly work with require() by converting it to a proper module pattern
- Updated init.lua to use loadModuleGlobally for loading the loadConfig module
- Fixed string concatenation with tables by using table.concat for log messages

## Contributing

When contributing to this project:

1. Create a branch for each logical set of changes
2. Follow the existing code style
3. Add proper documentation for all changes
4. Test thoroughly before submitting

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Hammerspoon Configuration Improvement Plan

This repository contains a Hammerspoon configuration with plans for improvements and restructuring.

## Project Documentation

We've created several documents to guide the improvement process:

1. **[TODO.md](docs/TODO.md)**: Comprehensive list of tasks organized by category
2. **[PROJECT_ANALYSIS.md](docs/PROJECT_ANALYSIS.md)**: Detailed analysis of current structure and issues
3. **[IMPLEMENTATION_PRIORITY.md](docs/IMPLEMENTATION_PRIORITY.md)**: Prioritized implementation plan with complexity/impact assessments

## Key Findings

Our analysis of the codebase has identified several areas for improvement:

### Code Organization

- The `init.lua` file is too large (~800 lines) and contains functionality that should be modularized
- Multiple files have overlapping functionality (particularly window management)
- Lack of consistent coding style and documentation

### Redundant Functionality

- Clipboard management is split between `ExtendedClipboard.lua` and `ClipboardTool.spoon`
- Window management functions exist in both `init.lua` and `WindowManager.lua`
- Layout functionality may be duplicated between custom code and `Layouts.spoon`

### Configuration Management

- Limited user customization options
- Hardcoded values throughout the codebase
- Basic secrets management in `load_secrets.lua`

## Implementation Approach

We recommend a phased approach to improvements:

1. **Foundation Improvements** - Modularization and basic configuration system
2. **Functionality Improvements** - Standardize interfaces and enhance error handling
3. **User Experience Improvements** - Improve UI, documentation, and performance
4. **Future Enhancements** - Add advanced features like a plugin system

## Getting Started

To begin working on improvements:

1. Review the detailed documents in this repository
2. Start with high-priority, high-impact tasks as outlined in `IMPLEMENTATION_PRIORITY.md`
3. Make incremental changes rather than large rewrites
4. Maintain backward compatibility throughout the process

# DragonGrid for Hammerspoon

## Extended Hotkey Support for Larger Grids

We've added extended hotkey support for larger grid sizes:

- `⌘+1-9` selects cells 1-9
- `⌘+Shift+1-9` selects cells 10-18
- `⌘+Shift+Alt+1-9` selects cells 19-27

This allows for larger grid sizes (up to 5x5 = 25 cells) while maintaining keyboard accessibility.

The help text in the grid interface has been updated to show these new keyboard shortcuts.

## Features

- Grid-based mouse positioning with multiple precision layers
- Window mode or screen mode
- Drag and drop support
- Keyboard and mouse control
- Configurable grid size and layers

## GitHub Desktop Enhancements

GitHub Desktop now always shows a project selection menu when opened through Hammerspoon, rather than just focusing the existing window if one exists. This allows you to:

1. Choose between existing GitHub Desktop windows
2. Open a different project even if GitHub Desktop is already running
3. Enter a custom path to open with GitHub Desktop

This feature is implemented through a specialized function that overrides the normal application behavior specifically for GitHub Desktop.

# HyperLogger for Hammerspoon

## Overview

HyperLogger is a custom logging solution for Hammerspoon that adds clickable hyperlinks to log messages in the Hammerspoon console. When you click on a log message, it will open the source file at the exact line that generated the log message, making debugging much easier.

## Features

- Automatically captures file and line information for each log message
- Displays clickable hyperlinks in the Hammerspoon console
- Compatible with the standard Hammerspoon logger API
- Opens source files in Cursor editor at the correct line number
- Maintains all standard log levels (info, debug, warning, error)

## Installation

1. Place the `HyperLogger.lua` file in your Hammerspoon configuration directory.
2. Load it in your `init.lua` file:

```lua
local HyperLogger = require('HyperLogger')
```

## Usage

Replace standard logger calls with HyperLogger:

```lua
-- Create a new logger
local log = HyperLogger.new('MyFeature', 'debug')

-- Log messages with automatic file/line tracking
log:i('Initializing feature')
log:d('Debug information')
log:w('Warning message')
log:e('Error occurred')

-- You can also manually specify file and line
log:i('Custom location message', 'path/to/file.lua', 42)
```

## How It Works

1. HyperLogger wraps the standard Hammerspoon logger for basic logging functionality
2. It uses Lua's debug library to automatically capture source file and line information
3. Messages are displayed as styled text with clickable hyperlinks
4. When clicked, it uses a custom URL handler to open the file in the Cursor editor

## Customization

- Edit the `createClickableLog` function to change the styling of log messages
- Modify the URL handler to use a different editor

## HyperLogger

The HyperLogger module provides enhanced logging capabilities for Hammerspoon, including:

1. **Colored Log Messages** - Different log levels are displayed with distinct colors in the Hammerspoon console:
   - Info (blue): Regular informational messages
   - Debug (gray): Detailed debug information
   - Warning (orange/yellow): Warning messages that need attention
   - Error (red): Error messages indicating problems

2. **File and Line Information** - Each log message includes the source file and line number where it was generated.

### Usage

```lua
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('MyModule', 'debug')

-- Log messages with different levels
log:i("Information message")  -- Blue
log:d("Debug message")        -- Gray
log:w("Warning message")      -- Orange/yellow
log:e("Error message")        -- Red
```

To see the colored output in action, run the test script in the Hammerspoon console:

```lua
dofile("test_hyperlogger_colors.lua")
```

## Recent Changes

### Initialization Process Cleanup

The Hammerspoon initialization process has been refactored to improve:

1. **Loading Order** - Core components now load in a logical dependency order
2. **Error Handling** - Better error handling for Spoon loading
3. **Redundancy Removal** - Eliminated duplicate module initialization
4. **Performance** - Console setup operations now happen in parallel

Key improvements:

- Spoons now load with proper error handling and dependency management
- Fixed non-table modifiers warning in HotkeyManager
- Added test_init_flow.lua to monitor loading process and detect redundancies

## Debugging Tools

### Testing the Initialization Process

To test the initialization flow and identify potential issues, run:

```lua
dofile(hs.configdir .. "/test_init_flow.lua")
hs.reload()
```

This will track module loading order, timing, and detect any redundancies in the initialization process.

## WindowToggler Enhanced Features

The WindowToggler system has been significantly enhanced to provide advanced window position management with support for multiple save locations and intelligent window handling.

### Key Features

1. **Multiple Save Locations**: Save window positions to Location 1 and Location 2 for each window
2. **Smart Window Identification**: Uses app name + window title for unique identification (handles multiple Cursor windows, etc.)
3. **Window Selection Menu**: Automatically shows window picker when no window is focused
4. **Location Toggle Functionality**: Quickly cycle between Location 1 and Location 2 with a single hotkey

### Window Identification System

Windows are identified using the format: `AppName:WindowTitle`

- Example: `Cursor:my-project` vs `Cursor:another-project`
- This allows different windows from the same app to have separate saved positions
- Perfect for managing multiple Cursor windows, Terminal windows, etc.

### Hotkey Mappings

| Hotkey | Function | Description |
|--------|----------|-------------|
| `Cmd+Ctrl+Alt+W` | Toggle Between Locations | Cycle between Location 1 and Location 2, or save current position if none exist |
| `Cmd+Shift+Ctrl+Alt+W` | Window Locations Menu | Show interactive menu for window location management |
| `Cmd+Ctrl+Alt+O` | Save to Location 1 | Save current window position to Location 1 |
| `Cmd+Shift+Ctrl+Alt+O` | Restore to Location 1 | Restore window to saved Location 1 |
| `Cmd+Ctrl+Alt+N` | Save to Location 2 | Save current window position to Location 2 |
| `Cmd+Shift+Ctrl+Alt+N` | Restore to Location 2 | Restore window to saved Location 2 |
| `Cmd+Ctrl+Alt+F12` | List Saved Windows | Show all saved window positions and locations |
| `Cmd+Ctrl+Alt+Q` | Clear Toggle Positions | Clear all saved toggle positions |
| `Cmd+Shift+Ctrl+Alt+Q` | Clear All Locations | Clear all saved Location 1 and Location 2 positions |

### Usage Patterns

#### Basic Window Toggle

1. Position a window where you want it and press `Cmd+Ctrl+Alt+W` - this saves the position as Location 1
2. Move the window to a second position and press `Cmd+Ctrl+Alt+W` again - this saves the second position as Location 2
3. Press `Cmd+Ctrl+Alt+W` repeatedly to cycle between Location 1 and Location 2

#### Multiple Location Management

1. **Save Locations**:
   - Position window at desired location
   - Press `Cmd+Ctrl+Alt+O` for Location 1 or `Cmd+Ctrl+Alt+N` for Location 2
2. **Restore Locations**:
   - Press `Cmd+Shift+Ctrl+Alt+O` for Location 1 or `Cmd+Shift+Ctrl+Alt+N` for Location 2

#### Interactive Menu

- Press `Cmd+Shift+Ctrl+Alt+W` to open the Window Locations Menu
- Choose from available options based on current window's saved locations
- Menu shows different options based on what's available for the current window

### Window Selection Behavior

When no window is focused:

- System automatically shows a window picker menu
- Lists all visible, standard windows
- Format: "AppName - WindowTitle" with app subtitle
- Select any window to apply the action

### Multi-App Support

Perfect for managing multiple instances of the same application:

- **Multiple Cursor windows**: Each project maintains separate saved positions
- **Multiple Terminal windows**: Each terminal session has its own locations
- **Multiple Browser windows**: Different browser windows/profiles keep separate positions

### Technical Implementation

- **Singleton Pattern**: Module uses singleton to avoid re-initialization
- **Persistent Storage**: Window locations (Location 1 and Location 2) are automatically saved to `~/.hammerspoon/data/window_locations.json` and persist across Hammerspoon reloads
- **Error Handling**: Graceful handling of closed windows and missing applications
- **Smart Comparison**: Fuzzy position matching for "nearly full" detection (±10 pixel tolerance)
- **Automatic Persistence**: Locations are saved immediately when changed and restored on module initialization

## Configuration

### Secrets File

Create a `.secrets` file in your Hammerspoon configuration directory with the following optional settings:

```bash
# MCP Server Configuration (optional)
MCP_SERVER_URL=http://localhost:8000
MCP_TIMEOUT=10
MCP_PORT=8000

# Other secrets...
AWSIP=your-aws-ip
AWSIP2=your-other-aws-ip
```

### MCP Integration

The MCP (Model Context Protocol) integration provides centralized project management:

- **Server URL**: Configure via `MCP_SERVER_URL` in secrets (default: `http://localhost:8000`)
- **Timeout**: Configure via `MCP_TIMEOUT` in secrets (default: `10` seconds)
- **Fallback**: Automatically uses hardcoded project list if server unavailable
- **Caching**: 5-minute cache reduces server requests and improves performance

Test MCP integration:

```bash
hs -c "dofile(hs.configdir .. '/test_mcp_integration.lua')"
```
