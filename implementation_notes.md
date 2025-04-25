# Cursor with GitHub Desktop Integration Implementation Notes

## Feature Overview

This feature enables users to open projects in both Cursor IDE and GitHub Desktop simultaneously, ensuring that:
1. The selected project path is sent to both applications
2. Final focus remains on Cursor IDE
3. GitHub Desktop is updated with the project path for version control context

## Implementation Details

The implementation follows the pattern of the existing `launchGitHubWithProjectSelection` function with modifications to:
- Send commands to open both applications with the same path
- Order the commands to ensure Cursor gets the final focus

### Key Components:

1. **New Function in AppManager.lua**: `launchCursorWithGitHubDesktop()`
   - Creates a project selection interface similar to existing GitHub Desktop selector
   - Modified to send open commands to both applications when a project is selected

2. **Application Launch Helper**: `open_cursor_with_github()`
   - Simple wrapper function to call the main implementation

3. **Hotkey Binding**: Added `_hyper+g` shortcut
   - Used an unused key combination that complements the existing GitHub shortcut (`hammer+g`)

## Design Considerations

1. **Order of Operations**:
   - GitHub Desktop is opened first, followed by Cursor
   - This sequence ensures final focus lands on Cursor

2. **User Experience**:
   - Maintains the familiar project selection interface
   - Provides a logical key binding that builds on existing GitHub shortcut

3. **Code Pattern**:
   - Follows the established pattern for application launchers in the codebase
   - Maintains consistency with existing implementations

## Lessons Learned

- Hammerspoon's HS.execute provides a simple way to chain application launches
- The ordering of commands is important for determining final application focus
- Reusing established patterns in the codebase made implementation straightforward

## Potential Future Enhancements

- Add configuration option to customize which applications are paired
- Save recently used project pairs for quicker access
- Extend to support more complex workflows (e.g., opening terminal in the same directory) 
