# ProjectManager Module for Hammerspoon

The ProjectManager module provides a convenient way to manage your projects/jobs and quickly access them. It allows you to define, track, and switch between different project workspaces.

## Features

- **Project Management UI**: Easily create, edit, and delete projects using a user-friendly interface
- **Active Project System**: Set the currently active project for quick reference
- **Project Actions**: Open projects in different applications (Finder, Terminal, Code editors)
- **Persistent Storage**: Project data automatically saved and loaded between sessions
- **Keyboard Shortcuts**: Quick access to project management functionality
- **UI Control**: Toggle, show, hide, and reset UI functions to prevent stuck windows

## Usage

### Keyboard Shortcuts

- `Cmd+Ctrl+Alt+J`: Toggle the Project Manager UI (show/hide)
- `Cmd+Shift+Ctrl+Alt+J`: Show information about the active project
- `Cmd+Ctrl+Alt+K`: Reset Project Manager UI (closes stuck windows)
- `Cmd+Shift+Ctrl+Alt+K`: Hide Project Manager UI

### UI Control Functions

If you encounter a stuck project window or need to programmatically control the UI:

1. **Toggle UI**: `ProjectManager.toggleProjectManager()` - Shows UI if hidden, hides if shown
2. **Show UI**: `ProjectManager.showProjectManager()` - Shows the project manager UI
3. **Hide UI**: `ProjectManager.hideUI()` - Hides all UI elements without deleting them
4. **Reset UI**: `ProjectManager.resetUI()` - Completely resets UI state, closing all windows

### Project Definition

Each project includes:
- **Name**: Descriptive name for the project
- **Path**: Directory path where the project is located
- **Description**: Optional description of the project

### Managing Projects

1. **Create a Project**:
   - Press `Cmd+Ctrl+Alt+J` to toggle the Project Manager
   - Select "Create New Project" 
   - Fill in the details and save

2. **Set Active Project**:
   - Press `Cmd+Ctrl+Alt+J` to toggle the Project Manager
   - Select a project from the list
   - Choose "Set as Active Project"

3. **View Project Info**:
   - Press `Cmd+Shift+Ctrl+Alt+J` to see the active project information

4. **Edit Project**:
   - Press `Cmd+Ctrl+Alt+J` to toggle the Project Manager
   - Select a project from the list
   - Choose "Edit Project Details"

5. **Delete Project**:
   - Press `Cmd+Ctrl+Alt+J` to toggle the Project Manager
   - Select a project from the list
   - Choose "Delete Project"

6. **If UI Gets Stuck**:
   - Press `Cmd+Ctrl+Alt+K` to reset the Project Manager UI

## Project Actions

For any project, you can:
- Open the project folder in Finder
- Open the project in a code editor
- Open a terminal session in the project directory

## Implementation Details

The ProjectManager module uses:
- `hs.chooser` for selection menus
- `hs.webview` for dialogs
- `hs.json` for persistent storage
- `hs.dialog` for file selection and confirmation

Project data is stored in `~/.hammerspoon/projects.json`.

## Future Enhancements

Possible future improvements:
- Project templates
- Project-specific window layouts
- Integration with version control systems
- Custom actions per project
- Recently opened projects list
- Project statistics and activity tracking

## Changelog

### v1.1.0
- Added UI control functions to prevent stuck windows
- Added toggle, show, hide, and reset functionality
- Added keyboard shortcuts for UI control
- Improved state tracking for UI elements

### v1.0.0
- Initial implementation
- Project management UI with create/edit/delete functionality
- Active project system
- Project actions (open in Finder/Editor/Terminal)
- Persistent storage of project data 
