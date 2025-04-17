# Hammerspoon Hotkey Fix

## Issue
An error was occurring during Hammerspoon initialization:

```
*** ERROR: ...merspoon.app/Contents/Resources/extensions/hs/hotkey.lua:435: At least one of pressedfn, releasedfn or repeatfn must be a function
```

This error was happening because the `init.lua` file was binding a hotkey to `AppManager.open_finder`, but that function didn't exist in the AppManager module:

```lua
hs.hotkey.bind(hyper, "F", AppManager.open_finder)
```

## Fix
Added the missing `open_finder` function to the AppManager module:

```lua
function AppManager.open_finder()
    AppManager.launchOrFocusWithWindowSelection("Finder")
end
```

This function follows the same pattern as the other application launcher functions, using the `launchOrFocusWithWindowSelection` function to either:
1. Focus an existing Finder window
2. Present a chooser if multiple Finder windows are open
3. Launch Finder if it's not running

## Implementation
The fix was implemented by:
1. Creating a new branch `fix/missing-finder-function`
2. Adding the missing function to `AppManager.lua`
3. Following the existing pattern for application launcher functions
4. Testing that the hyper+F hotkey now works correctly

## Additional Notes
- The error occurred because when binding a hotkey in Hammerspoon, at least one of the callback functions must be defined
- When the function is `nil` or doesn't exist, Hammerspoon throws the error shown above
- This type of error can happen when hotkeys reference functions that:
  - Have typos in their names
  - Are defined in modules that haven't been loaded
  - Haven't been implemented yet 
