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
