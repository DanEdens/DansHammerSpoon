# CustomControlBar Spoon

A TouchBar-like control panel for Mac Pro and other Macs without TouchBar hardware. This Spoon provides customizable floating control panels with context-aware buttons and widgets.

## Features

- **Context-Aware Controls**: Different button sets automatically appear based on the active application
- **Customizable Positioning**: Place the control bar at top, bottom, left, right, or custom coordinates
- **Rich Control Types**: Buttons, text displays, and future support for sliders and widgets
- **Theme Support**: Customizable colors, transparency, and styling
- **Keyboard Shortcuts**: Toggle visibility with configurable hotkeys
- **Multiple Monitors**: Works across multiple screens

## Installation

1. Copy the `CustomControlBar.spoon` directory to `~/.hammerspoon/Spoons/`
2. Add to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("CustomControlBar")
spoon.CustomControlBar:start()
```

## Basic Usage

### Quick Start

```lua
-- Load and start with defaults
hs.loadSpoon("CustomControlBar")
spoon.CustomControlBar:start()

-- Toggle with Cmd+Ctrl+T (default hotkey)
```

### Customization

```lua
-- Load the spoon
hs.loadSpoon("CustomControlBar")

-- Configure position and size
spoon.CustomControlBar.position = "bottom"  -- or "top", "left", "right", {x=100, y=100}
spoon.CustomControlBar.size = {w = 800, h = 60}

-- Customize theme
spoon.CustomControlBar.theme.background = {red = 0.2, green = 0.2, blue = 0.2, alpha = 0.9}

-- Start the control bar
spoon.CustomControlBar:start()
```

## Application Profiles

Add custom controls for specific applications using their bundle IDs:

### Safari Profile
```lua
spoon.CustomControlBar:addAppProfile("com.apple.Safari", {
    buttons = {
        {icon = "⬅", action = "cmd+[", tooltip = "Back"},
        {icon = "➡", action = "cmd+]", tooltip = "Forward"}, 
        {icon = "🔄", action = "cmd+r", tooltip = "Reload"},
        {icon = "🔖", action = "cmd+d", tooltip = "Bookmark"},
        {icon = "🏠", action = "cmd+shift+h", tooltip = "Home"}
    }
})
```

### Finder Profile
```lua
spoon.CustomControlBar:addAppProfile("com.apple.finder", {
    buttons = {
        {icon = "⬆", action = "cmd+up", tooltip = "Up Directory"},
        {icon = "📁", action = "cmd+shift+n", tooltip = "New Folder"},
        {icon = "🗑", action = "cmd+delete", tooltip = "Move to Trash"},
        {icon = "👁", action = "cmd+1", tooltip = "Icon View"},
        {icon = "📋", action = "cmd+2", tooltip = "List View"}
    }
})
```

### Custom Actions
```lua
spoon.CustomControlBar:addAppProfile("com.example.MyApp", {
    buttons = {
        {
            icon = "🎵", 
            action = function() 
                hs.spotify.playpause() 
            end, 
            tooltip = "Play/Pause Spotify"
        },
        {
            icon = "📊", 
            action = function() 
                hs.alert.show("CPU: " .. hs.host.cpuUsage().overall .. "%") 
            end,
            tooltip = "Show CPU Usage"
        }
    }
})
```

## Finding Bundle IDs

To find an application's bundle ID:

1. Open the Hammerspoon Console
2. Launch the target application
3. Run in console: `hs.application.frontmostApplication():bundleID()`

Common bundle IDs:
- Safari: `com.apple.Safari`
- Finder: `com.apple.finder`
- Terminal: `com.apple.Terminal`
- VS Code: `com.microsoft.VSCode`
- Chrome: `com.google.Chrome`
- Firefox: `org.mozilla.firefox`

## Configuration Options

### Position
```lua
spoon.CustomControlBar.position = "bottom"     -- Bottom center
spoon.CustomControlBar.position = "top"        -- Top center  
spoon.CustomControlBar.position = "left"       -- Left center
spoon.CustomControlBar.position = "right"      -- Right center
spoon.CustomControlBar.position = {x=100, y=50} -- Custom coordinates
```

### Size
```lua
spoon.CustomControlBar.size = {w = 800, h = 60}  -- Width and height in pixels
```

### Theme
```lua
spoon.CustomControlBar.theme = {
    background = {red = 0.1, green = 0.1, blue = 0.1, alpha = 0.9},
    buttonNormal = {red = 0.3, green = 0.3, blue = 0.3, alpha = 1.0},
    buttonHover = {red = 0.5, green = 0.5, blue = 0.5, alpha = 1.0},
    buttonActive = {red = 0.7, green = 0.7, blue = 0.7, alpha = 1.0},
    text = {red = 1.0, green = 1.0, blue = 1.0, alpha = 1.0},
    cornerRadius = 8
}
```

## API Reference

### Methods

#### `CustomControlBar:start()`
Starts the control bar, creating UI and watchers.

#### `CustomControlBar:stop()`
Stops the control bar and cleans up resources.

#### `CustomControlBar:toggle()`
Toggles the visibility of the control bar.

#### `CustomControlBar:show()`
Shows the control bar.

#### `CustomControlBar:hide()`
Hides the control bar.

#### `CustomControlBar:addAppProfile(bundleID, profile)`
Adds or updates an application profile.

**Parameters:**
- `bundleID` (string): Application bundle identifier
- `profile` (table): Profile configuration with controls

### Control Types

#### Button
```lua
{
    type = "button",        -- Optional, defaults to button
    icon = "🔄",           -- Emoji or text to display
    title = "Reload",      -- Alternative to icon
    action = "cmd+r",      -- Keyboard shortcut string
    tooltip = "Reload Page" -- Tooltip text
}
```

#### Custom Function Button
```lua
{
    icon = "🎵",
    action = function() 
        hs.spotify.playpause() 
    end,
    tooltip = "Play/Pause"
}
```

#### Text Display
```lua
{
    type = "text",
    title = "Time",
    value = function() return os.date("%H:%M") end,
    tooltip = "Current Time"
}
```

### Default Hotkey

- **Cmd+Ctrl+T**: Toggle control bar visibility

## Global Controls

The control bar includes default global controls:
- Media play/pause button
- System mute toggle
- Current time display

These appear alongside application-specific controls.

## Troubleshooting

### Control bar not appearing
- Check that `spoon.CustomControlBar:start()` was called
- Verify position settings don't place it off-screen
- Try toggling with Cmd+Ctrl+T

### Application profiles not switching
- Verify the bundle ID is correct
- Check that the application is actually focused
- Look for console errors in Hammerspoon

### Buttons not working
- Check that action strings are valid keyboard shortcuts
- Test custom functions for errors
- Verify the target application accepts the shortcuts

## Future Enhancements

- Slider controls for volume, brightness, etc.
- Widget system for system monitoring
- Multiple control bar support
- Configuration GUI
- Icon library and custom icons
- Animation and transition effects

## License

MIT License - see LICENSE file for details.

## Contributing

Issues and pull requests welcome! Please follow the existing code style and include tests for new features. 