# Changes - Docker Setup for Development and Deployment

## Summary
Added Docker configuration for development, testing, and deployment of the Hammerspoon configuration.

## Feature Details
- **Development Environment**: A Docker container based on Alpine Linux for code validation
  - Includes Lua 5.3, LuaRocks, and code linting tools
  - Provides a consistent environment for testing and validation
  - Integrated with Docker Compose for easy usage
- **Deployment Script**: A macOS-specific script to install Hammerspoon configuration
  - Installs Homebrew and Hammerspoon if needed
  - Backs up existing configurations
  - Handles special cases like projects.json
  - Reloads or starts Hammerspoon after installation
- **CI/CD Integration**: GitHub Actions workflow for automated validation
  - Runs validation checks on PRs and pushes to main branch
  - Builds the Docker image and runs the validation script

## Changes to Existing Files
- `README.md`: Updated with Docker setup information
- Added `.dockerignore` to exclude unnecessary files from the Docker context

## New Files
- `docker/dev/Dockerfile`: Defines the development environment
- `docker/dev/docker-compose.yml`: Simplifies working with the Docker environment
- `docker/deploy/install_macos.sh`: Script for macOS deployment
- `docker/README.md`: Documentation for the Docker setup
- `DOCKER_SETUP.md`: Comprehensive documentation for the Docker setup
- `validate.sh`: Script to validate Lua syntax
- `.github/workflows/validate.yml`: GitHub Actions workflow configuration

## Implementation Notes
- Docker cannot run macOS containers due to licensing restrictions
- The development environment is primarily for code validation
- The deployment script handles the actual installation on macOS
- Used Alpine Linux for a small, efficient container

## Lessons Learned
- Separate development and deployment concerns
- Provide scripts for both local development and CI/CD environments
- Consider non-Docker users with detailed documentation

## Next Steps
- Add additional testing capabilities
- Consider integration with other CI/CD platforms
- Add support for Spoon validation

# Changes - ProjectManager FileManager Integration

## Summary
Added integration between ProjectManager and FileManager to share project definitions and provide a seamless project management experience.

## Feature Details
- **Automatic Import**: Projects are automatically imported from FileManager on first run
  - ProjectManager checks for existing saved projects first
  - If no projects exist, it imports from FileManager's projects_list
- **Manual Import**: Added UI option to import projects from FileManager at any time
  - Accessible from the main Project Manager menu
  - Skips projects that already exist in ProjectManager
- **Export Functionality**: Added placeholder for future bidirectional integration
  - Projects can be exported to FileManager (currently just shows a message)
  - Prepares for future complete integration

## Changes to Existing Files
- `ProjectManager.lua`: 
  - Added FileManager import at the top of the file
  - Added importFromFileManager function to populate from FileManager's list
  - Added exportActiveToFileManager function (placeholder for future integration)
  - Updated init function to automatically import on first run
  - Added UI options for importing and exporting
- `ProjectManager_README.md`: 
  - Updated documentation to include FileManager integration features
  - Added section specifically for FileManager integration
  - Updated changelog with v1.2.0 details

## Implementation Notes
- The integration is currently one-way (FileManager to ProjectManager)
- The export functionality is a placeholder for future bidirectional sync
- Projects are imported with a default description of "Imported from FileManager"
- Duplicate project names are skipped during import

## Lessons Learned
- Reusing existing data structures prevents duplication and provides consistency
- Placeholder functions for future integration make it easier to add functionality later

## Next Steps
- Implement bidirectional sync between ProjectManager and FileManager
- Add export of all projects (not just active)
- Consider merging the project lists entirely in a future update

# Changes - ProjectManager UI Control Improvements

## Summary
Added UI control functions to the ProjectManager module to prevent stuck windows and provide better user control over the interface.

## Feature Details
- **UI State Tracking**: Added comprehensive state tracking for all UI elements
  - Tracks project chooser, webview, and actions chooser instances
  - Prevents duplicate UI elements from being created
  - Maintains visibility state for toggle functionality
- **UI Control Functions**:
  - Added `toggleProjectManager()` - Shows/hides UI based on current state
  - Added `hideUI()` - Hides all UI elements without destroying them
  - Added `resetUI()` - Completely resets UI state by closing all windows
  - Updated `showProjectManager()` - Now checks for existing UI state

## New Hotkeys
- `hammer+k` (Cmd+Ctrl+Alt+K): Reset Project Manager UI
- `hyper+k` (Cmd+Shift+Ctrl+Alt+K): Hide Project Manager UI
- Updated `hammer+j` to toggle the UI instead of just showing it

## Changes to Existing Files
- `ProjectManager.lua`: Added UI state tracking and control functions
- `hotkeys.lua`: Updated hotkeys for ProjectManager to use new functions
- `ProjectManager_README.md`: Updated documentation with new UI control features

## Implementation Notes
- The UI state tracking allows for proper cleanup of UI elements
- Reset function ensures users can recover from any stuck UI state
- Toggle functionality provides better UX than separate show/hide functions

## Lessons Learned
- UI elements in Hammerspoon need proper state tracking to avoid leaks
- Providing explicit reset functionality helps users recover from UI issues
- Toggle patterns are more intuitive than separate show/hide functions

## Next Steps
- Consider adding a global hotkey to force-reset all Hammerspoon UI elements
- Explore adding timeout auto-hide functionality to prevent abandoned UIs
- Add visual indicators for active project status in the menu bar

# Changes - Project Management System

## Summary
Added a new ProjectManager module that provides a UI for managing projects/jobs and setting an active project for easy access to tools and scripts.

## Feature Details
- **ProjectManager Module**: A new module for managing projects/job workspaces
  - Create, edit, and delete project definitions with paths and descriptions
  - Set and track active project for current work context
  - Open projects in Finder, Terminal, or code editors
  - Persistent storage of project data between sessions
  - Web-based UI for creating and editing projects
  - Quick access via keyboard shortcuts

## New Files
- `ProjectManager.lua`: Core module implementation
- `ProjectManager_README.md`: Documentation for the feature
- `projects.json`: Auto-generated file for storing project data (ignored in git)

## Changes to Existing Files
- `hotkeys.lua`: Added import for ProjectManager module and hotkeys for the new functionality
  - `hammer+j`: Show project manager UI
  - `hyper+j`: Show active project info
- `init.lua`: Updated to load the ProjectManager module on startup
- `README.md`: Updated to include information about the new ProjectManager module

## Implementation Notes
- Uses HTML/CSS for creating clean UI dialogs with `hs.webview`
- Projects data is stored using `hs.json` for persistence
- Implements URL-based communication between webview and Hammerspoon
- Uses the chooser UI for project selection and actions
- Integration with system dialogs for file path selection

## Lessons Learned
- WebView provides a powerful way to create rich UIs in Hammerspoon
- URL-based communication with query parameters works well for form submissions
- The chooser UI is excellent for presenting lists of actions and items

## Next Steps
- Add project templates for quick creation of common project types
- Implement project-specific window layouts
- Add integration with version control systems
- Create custom actions per project
- Track recently opened projects

# Changes - Window Toggle by Title

## Summary
Added a new WindowToggler module that allows toggling windows between their current position and the "nearlyFull" layout with positions remembered by window title.

## Feature Details
- **WindowToggler Module**: A new module for toggling window positions by title
  - Saves position when toggling to "nearlyFull" layout
  - Restores saved position when toggling again
  - Tracks windows by title, allowing recognition of the same window across application restarts
  - Detects if a window is already in the "nearlyFull" layout position (with margin of error)

## New Files
- `WindowToggler.lua`: Core module implementation
- `WindowToggler_README.md`: Documentation for the feature

## Changes to Existing Files
- `hotkeys.lua`: Added import for WindowToggler module and hotkeys for the new functionality
  - `hammer+w`: Toggle current window position
  - `hyper+w`: List saved window positions
  - `hammer+q`: Clear all saved window positions
- `README.md`: Updated to include information about the new WindowToggler module

## Implementation Notes
- Positions are stored in a table keyed by window title
- The module checks if a window is in "nearlyFull" layout by comparing its position to the nearlyFull layout dimensions with a small margin of error
- Used HyperLogger for consistent logging

## Lessons Learned
- Window titles offer a more persistent way to track windows than window IDs, which change when applications restart
- Position comparison with a margin of error is necessary due to small variations in window positioning
- This approach could be extended to other layout types in the future

## Next Steps
- Consider adding persistence between Hammerspoon restarts by saving positions to a JSON file
- Add support for multiple remembered positions per window title
- Consider integrating with the existing WindowManager module more deeply 

# Changelog

## [Unreleased]

### Added
- Enhanced search functionality in the application chooser dialogs
  - Typing in the search box now filters the project and window options
  - If no matches are found, a custom path option is shown
  - Maintains existing behavior for custom path handling starting with / or ~
- Dynamic Layout Capture System
  - New hammer+a hotkey to start layout capture mode
  - New _hyper+a hotkey to list custom layouts
  - Added MongoDB storage for custom layouts
  - Simple REST API for storing and retrieving layouts
  - Custom layouts can be created by clicking corner points

## 2023-04-21

### Added
- DragonGrid Spoon improvements
  - Better multi-screen handling
  - Improved grid selection UI
  - Fixed memory leaks when redrawing grid

### Fixed
- Window positioning accuracy across external displays
- Invalid index errors when saving window positions

## 2023-04-01
