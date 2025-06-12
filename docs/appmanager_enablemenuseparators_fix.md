# AppManager EnableMenuSeparators Flag Implementation

## Issue
The `enableMenuSeparators` flag was not consistently implemented throughout all chooser functions in AppManager.lua. Additionally, there were syntax errors due to missing `end` statements.

## Changes Made

### 1. Fixed Syntax Errors
- Added missing `end` statement in `launchGitHubWithProjectSelection()` function
- Fixed indentation and structure issues

### 2. Implemented enableMenuSeparators Flag Consistently

#### In `launchOrFocusWithWindowSelection()`:
- ✅ Already properly implemented
- Added additional check in query filtering logic

#### In `launchGitHubWithProjectSelection()`:
- ✅ Now properly checks `enableMenuSeparators` before adding separators
- Fixed both branches (when app is not running and when app is running)
- Added flag check in query filtering logic

#### In `launchCursorWithGitHubDesktop()`:
- ✅ Now properly checks `enableMenuSeparators` before adding separators
- Fixed both branches (when Cursor is not running and when Cursor is running)
- Removed hardcoded separator that was always added
- Added flag check in query filtering logic

### 3. Enhanced Query Filtering
In all chooser query callbacks, added proper checking for the `enableMenuSeparators` flag when deciding whether to include separators in filtered results:

```lua
-- Add separator if we have any matches and menu separators are enabled
if hasMatches and separatorChoice and enableMenuSeparators then
    table.insert(filteredChoices, separatorChoice)
end
```

### 4. Updated Validation Script
- Fixed `validate.sh` to work with luajit which doesn't support `-c` flag
- Now uses `-b /dev/null` for luajit syntax checking

## Configuration
The flag is controlled by this variable at the top of AppManager.lua:
```lua
local enableMenuSeparators = true
```

Set to `false` to disable separators, `true` to enable them.

## Impact
- When `enableMenuSeparators = true`: Separators appear between windows and projects sections
- When `enableMenuSeparators = false`: No separators are shown, creating a cleaner, more compact menu
- All chooser functions now behave consistently regarding separators
- Syntax errors are resolved and the module loads correctly

## Testing
- Syntax validation passes: `luajit -b AppManager.lua /dev/null`
- All functions now properly respect the `enableMenuSeparators` configuration
- Query filtering maintains separator behavior based on the flag setting

## Files Modified
- `AppManager.lua`: Fixed syntax and implemented flag consistently
- `validate.sh`: Updated for luajit compatibility 
