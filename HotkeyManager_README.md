# HotkeyManager

The HotkeyManager module provides a smart, dynamic way to display and manage hotkeys in Hammerspoon.

## Features

- Automatically tracks all hotkey bindings created using `hs.hotkey.bind`
- Categorizes hotkeys into logical groups for better organization
- Excludes temporary/placeholder hotkeys from the display
- Provides a clean, toggleable display window for hotkeys
- Dynamically extracts meaningful descriptions from function callbacks
- Styled HTML display with category colors and visual enhancements

## How It Works

1. The module overrides the standard `hs.hotkey.bind` function to track all hotkey registrations
2. When hotkey list display is requested, it categorizes and formats the hotkeys
3. Hotkeys are grouped into categories like "Window Management", "Applications", etc.
4. Temporary functions (marked with `tempFunction()`) are automatically excluded
5. Results are displayed in a persistent, toggleable window that can be closed by:
   - Pressing the same hotkey again
   - Clicking anywhere in the window
   - Pressing the Escape key
   - Clicking the close button

## Usage

Simply require the module in your Hammerspoon configuration:

```lua
local HotkeyManager = require('HotkeyManager')
```

The module automatically replaces the global `showHammerList` and `showHyperList` functions with dynamic versions.

### Adding Descriptions to Hotkeys

For better organization, add explicit descriptions to your hotkey bindings:

```lua
-- Without description (will try to auto-detect)
hs.hotkey.bind(hammer, "w", function() WindowManager.moveWindow("up") end)

-- With description (preferred)
hs.hotkey.bind(hammer, "w", "Move Window Up", function() WindowManager.moveWindow("up") end)
```

### Displaying Hotkey Lists

Trigger the hotkey displays as usual - now they'll show in a persistent toggleable window:

```lua
hs.hotkey.bind(hammer, "Space", "Show Hammer Hotkeys", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", "Show Hyper Hotkeys", function() showHyperList() end)
```

### Customizing the Display Window

You can customize the appearance of the display window:

```lua
HotkeyManager.configureDisplay({
    width = 1000,          -- Width of the display window
    height = 700,          -- Height of the display window
    fadeInDuration = 0.3,  -- Fade-in animation time in seconds
    fadeOutDuration = 0.2, -- Fade-out animation time in seconds
    cornerRadius = 12,     -- Rounded corner radius
    fontSize = 14,         -- Base font size
    font = "Menlo",        -- Font family
    backgroundColor = {0.1, 0.1, 0.1, 0.9},  -- Dark background with some transparency
    textColor = {0.9, 0.9, 0.9, 1.0},        -- Light text color
    categoryColors = {
        ["Window Management"] = {0.2, 0.6, 0.8, 1.0},  -- Blue
        ["Applications"] = {0.8, 0.4, 0.2, 1.0},       -- Orange
        ["Files"] = {0.2, 0.8, 0.4, 1.0},              -- Green
        ["UI & Display"] = {0.6, 0.3, 0.8, 1.0},       -- Purple
        ["System"] = {0.8, 0.3, 0.3, 1.0},             -- Red
        ["Other"] = {0.7, 0.7, 0.7, 1.0}               -- Gray
    }
})
```

## Customization

The categories and display format can be customized by modifying the `showHotkeyList` function in the module. 

## Troubleshooting

### Webview Display Issues

If you encounter error messages like this:
```
attempt to index a hs.webview value (local 'webview')
```

This can happen due to timing issues with the webview component. The latest version has improved error handling to prevent these issues by:

1. Adding proper null checking throughout the code
2. Using safer reference handling for the webview object 
3. Adding verification timers to catch potential race conditions
4. Using pcall() for operations that might fail

If you still encounter webview-related errors, try reloading Hammerspoon or check for conflicts with other extensions that might interfere with webview operations.
