# Hammerspoon Configuration Improvement Plan

This repository contains a Hammerspoon configuration with plans for improvements and restructuring.

## Project Documentation

We've created several documents to guide the improvement process:

1. **[TODO.md](TODO.md)**: Comprehensive list of tasks organized by category
2. **[PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md)**: Detailed analysis of current structure and issues
3. **[IMPLEMENTATION_PRIORITY.md](IMPLEMENTATION_PRIORITY.md)**: Prioritized implementation plan with complexity/impact assessments

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

## Recent Improvements

Several improvements have been made to the codebase:

1. **DragonGrid Multi-Screen Support** - Fixed UI issues with the precision grid system when operating across multiple monitors
   - See [DragonGrid-MultiScreen-Fix.md](docs/DragonGrid-MultiScreen-Fix.md) for details
   - Enables seamless grid-based mouse positioning across all connected displays
   - Maintains consistent UI behavior between grid levels

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

## Contributing

When contributing to this project:

1. Create a branch for each logical set of changes
2. Follow the existing code style (or the new one if defined)
3. Add proper documentation for all changes
4. Test thoroughly before submitting 

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
