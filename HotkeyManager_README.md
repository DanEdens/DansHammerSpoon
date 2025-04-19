# HotkeyManager

The HotkeyManager module provides a smart, dynamic way to display and manage hotkeys in Hammerspoon.

## Features

- Automatically tracks all hotkey bindings created using `hs.hotkey.bind`
- Categorizes hotkeys into logical groups for better organization
- Excludes temporary/placeholder hotkeys from the display
- Provides a clean, organized view of hotkeys when triggered
- Dynamically extracts meaningful descriptions from function callbacks

## How It Works

1. The module overrides the standard `hs.hotkey.bind` function to track all hotkey registrations
2. When hotkey list display is requested, it categorizes and formats the hotkeys
3. Hotkeys are grouped into categories like "Window Management", "Applications", etc.
4. Temporary functions (marked with `tempFunction()`) are automatically excluded

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

Trigger the hotkey displays as usual:

```lua
hs.hotkey.bind(hammer, "Space", "Show Hammer Hotkeys", function() showHammerList() end)
hs.hotkey.bind(_hyper, "Space", "Show Hyper Hotkeys", function() showHyperList() end)
```

## Customization

The categories and display format can be customized by modifying the `showHotkeyList` function in the module. 
