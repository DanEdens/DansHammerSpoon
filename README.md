# Hammerspoon Configuration

![Hammerspoon Logo](https://www.hammerspoon.org/images/hammerspoon.png)

A powerful, customized Hammerspoon configuration for advanced macOS automation and window management.

## Overview

This Hammerspoon configuration provides a comprehensive set of tools for macOS automation, featuring:

- Advanced window management with multiple layouts and precise positioning
- DragonGrid system for pixel-perfect mouse control
- Smart application launching with window selection
- File and project management
- Device connection handling
- Enhanced debugging with clickable logs

The configuration is modular, customizable, and designed for power users seeking to streamline their workflow.

## Core Modules

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

See [ProjectManager_README.md](ProjectManager_README.md) for complete details.

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

See [DOCKER_SETUP.md](DOCKER_SETUP.md) for detailed instructions.

## Customization

The configuration can be customized by editing the following files:

- `init.lua` - Main configuration file
- `hotkeys.lua` - Keyboard shortcut definitions
- `FileManager.lua` - Customize file and project lists
- `*.lua` modules - Each module can be customized for specific functionality

## Recent Improvements

Several improvements have been made to the codebase:

1. **Window Position Toggling by Title** - Added WindowToggler module for toggling window positions by title
   - Remembers window positions by window title rather than just window ID
   - Allows toggling between custom positions and the nearlyFull layout
   - Works across application restarts as long as window titles remain the same
   - Provides hotkeys for toggling (hammer+w), listing saved positions (hyper+w), and clearing positions (hammer+q)
   - See [WindowToggler_README.md](WindowToggler_README.md) for details

2. **Dynamic Hotkey Management** - Added smart dynamic hotkey display system
   - Automatically tracks and categorizes all hotkey bindings
   - Excludes temporary/placeholder functions from the hotkey list
   - Groups hotkeys into logical categories for easier reference
   - **Enhanced with persistent, toggleable window display**
   - **Wider, more readable layout with styled HTML and color coding**
   - **Fixed webview indexing errors with comprehensive error handling**
   - **Implemented multi-layered protection against resource leaks**
   - See [HotkeyManager_README.md](HotkeyManager_README.md) for details

3. **HammerGhost URL Event Handling Fix** - Fixed WebKit-based communication in HammerGhost.spoon
   - Initialized the URL event watcher server that was missing
   - Added detailed URL parameter parsing and logging
   - Implemented testing utilities for URL event handling
   - See [Spoons/HammerGhost.spoon/FIX_URL_HANDLING.md](Spoons/HammerGhost.spoon/FIX_URL_HANDLING.md) for details

4. **DragonGrid Multi-Screen Support** - Fixed UI issues with the precision grid system when operating across multiple monitors
   - See [DragonGrid-MultiScreen-Fix.md](docs/DragonGrid-MultiScreen-Fix.md) for details
   - Enables seamless grid-based mouse positioning across all connected displays
   - Maintains consistent UI behavior between grid levels

5. **HyperLogger for Debugging** - Enhanced logging system with clickable log messages
   - Automatically captures file and line information
   - Displays clickable hyperlinks in the console
   - Makes debugging much easier by linking logs to source code

6. **GitHub Desktop Enhancements** - Specialized project selection when opening GitHub Desktop
   - Choose between existing GitHub Desktop windows
   - Open different projects even when GitHub Desktop is already running
   - Enter custom paths directly in the selection UI

7. **Hammerspoon OS Version Compatibility Fix** - Fixed error with operating system version reporting
   - Updated to handle the table return format of `hs.host.operatingSystemVersion()`
   - Properly formats version as string using major.minor.patch format
   - Prevents "attempt to concatenate a table value" errors during initialization

8. **Hotkey Binding Fix** - Fixed error with missing Finder function
   - Added missing `open_finder` function to AppManager module
   - Resolves "At least one of pressedfn, releasedfn or repeatfn must be a function" error
   - Ensures hyper+F hotkey correctly opens or focuses Finder
   - See [Hotkey-Fix.md](docs/Hotkey-Fix.md) for details

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

1. **[TODO.md](TODO.md)**: Comprehensive list of tasks organized by category
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

# Hammerspoon Configuration

This repository contains the custom Hammerspoon configuration for managing hotkeys, window arrangements, and other productivity enhancements.

## Features

- **Hotkey Management**: HotkeyManager module provides a consistent interface for managing and displaying hotkeys.
- **Alert-based Display**: Shows pressed hotkeys in an elegant alert window with configurable appearance.
- **Category-based Organization**: Hotkeys are organized by categories with custom colors for better visual grouping.

## Configuration

The HotkeyManager can be configured through the `HotkeyManager.config` table in `HotkeyManager.lua`. Key settings include:

### Display Settings
- `width`: Width of the hotkey display (default: 800)
- `height`: Height of the hotkey display (default: 600)
- `cornerRadius`: Corner radius for the hotkey display (default: 10)
- `font`: Font for the hotkey display (default: "Menlo")
- `fontSize`: Font size for the hotkey display (default: 14)
- `fadeInDuration`: Duration of fade in animation (default: 0.3s)
- `fadeOutDuration`: Duration of fade out animation (default: 0.3s)

### Alert Settings
- `alertDuration`: Duration to show the hotkey alert (default: 7s)
- `alertFontSize`: Font size for the alert text (default: 16)
- `alertTextColor`: Text color for alerts (default: white)
- `alertBackgroundColor`: Background color for alerts (default: semi-transparent dark)

### Category Colors
Custom colors can be defined for different categories of hotkeys to provide visual distinction.

## Usage

Press configured hotkeys to trigger actions and see them displayed in the alert window.
