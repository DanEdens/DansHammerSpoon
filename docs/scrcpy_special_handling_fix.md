# Scrcpy Special Handling Implementation

## Problem
Scrcpy is a command-line tool rather than a traditional macOS application, which means it doesn't work well with the standard `launchOrFocusWithWindowSelection` function. The user requested special handling for scrcpy since they named the window consistently.

## Solution
Created a specialized `open_scrcpy()` function in `AppManager.lua` that:

1. **Window Detection**: Searches for existing scrcpy windows by title patterns:
   - Windows containing "scrcpy" (case-insensitive)
   - Device model patterns like "SM-A123" 
   - Resolution patterns like "1920x1080"

2. **Smart Behavior**:
   - If no scrcpy windows exist: Launch new scrcpy instance
   - If one scrcpy window exists: Focus it directly
   - If multiple scrcpy windows exist: Show chooser with options to focus existing windows or launch new instance

3. **Launch Command**: Uses `/opt/homebrew/bin/scrcpy &` to launch in background

## Changes Made

### AppManager.lua
- Replaced simple `launchOrFocusWithWindowSelection("scrcpy")` with specialized function
- Added window detection logic for command-line tools
- Added chooser interface for multiple scrcpy instances
- Added logging for debugging

### hotkeys.lua  
- Updated hotkey binding to use `AppManager.open_scrcpy()` instead of direct command execution

## Benefits
- Consistent behavior with other application launchers
- Ability to focus existing scrcpy windows
- Support for multiple scrcpy instances
- Fallback to launch new instance when none exist
- Better user experience with chooser interface

## Testing
- Function handles case when no scrcpy windows exist
- Function handles case with single scrcpy window
- Function handles case with multiple scrcpy windows
- Hotkey binding updated and tested

## Future Considerations
- Could extend pattern matching for other device types
- Could add configuration for scrcpy binary path
- Could add options for different scrcpy launch parameters 
