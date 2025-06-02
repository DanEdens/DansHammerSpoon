# TouchBar Spoon

A real TouchBar controller for MacBooks with physical TouchBar hardware. This Spoon uses the `hs._asm.undocumented.touchbar` extension to provide native TouchBar manipulation capabilities.

## Features

- **Hardware TouchBar Control**: Works with actual TouchBar hardware on supported MacBooks
- **Context-Aware Switching**: Different TouchBar layouts based on active applications
- **Customizable Items**: Buttons with custom actions, colors, and callbacks
- **Application Profiles**: Define TouchBar layouts for specific applications
- **System Integration**: Proper integration with macOS TouchBar system
- **Robust Error Handling**: Graceful fallbacks and cleanup

## Requirements

- MacBook with physical TouchBar (2016-2021 models)
- macOS 10.12.1 or later
- `hs._asm.undocumented.touchbar` extension installed

## Installation

### Step 1: Install TouchBar Extension

First, install the TouchBar extension:

```bash
cd ~/.hammerspoon
curl -L https://github.com/asmagill/hs._asm.undocumented.touchbar/raw/master/touchbar-v0.8.3.2alpha-universal.tar.gz | tar -xz
```

### Step 2: Install TouchBar Spoon

1. Copy the `TouchBar.spoon` directory to `~/.hammerspoon/Spoons/`
2. Add to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("TouchBar")
spoon.TouchBar:start()
```

## Basic Usage

### Quick Start

```lua
-- Load and start with defaults
hs.loadSpoon("TouchBar")
spoon.TouchBar:start()
```

This will create a basic TouchBar with:
- Current time display
- Volume mute toggle
- Hammerspoon reload button

### Custom Default Items

```lua
hs.loadSpoon("TouchBar")

-- Set custom default items
spoon.TouchBar:setDefaultItems({
    {id = "time", title = os.date("%H:%M"), color = "white"},
    {id = "volume", title = "🔊", callback = function() 
        local device = hs.audiodevice.defaultOutputDevice()
        device:setMuted(not device:muted())
    end},
    {id = "brightness", title = "☀️", callback = function()
        hs.brightness.set(hs.brightness.get() > 50 and 25 or 75)
    end}
})

spoon.TouchBar:start()
```

## Application Profiles

Create custom TouchBar layouts for specific applications:

### Safari Profile
```lua
spoon.TouchBar:addAppProfile("com.apple.Safari", {
    items = {
        {id = "back", title = "←", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "[") 
        end},
        {id = "forward", title = "→", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "]") 
        end},
        {id = "reload", title = "⟳", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "r") 
        end},
        {id = "bookmark", title = "🔖", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "d") 
        end}
    }
})
```

### Terminal Profile
```lua
spoon.TouchBar:addAppProfile("com.apple.Terminal", {
    items = {
        {id = "new_tab", title = "⊞", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "t") 
        end},
        {id = "close_tab", title = "✕", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "w") 
        end},
        {id = "clear", title = "🧹", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "k") 
        end},
        {id = "interrupt", title = "⏹", callback = function() 
            hs.eventtap.keyStroke({"ctrl"}, "c") 
        end}
    }
})
```

### VS Code Profile
```lua
spoon.TouchBar:addAppProfile("com.microsoft.VSCode", {
    items = {
        {id = "save", title = "💾", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "s") 
        end},
        {id = "find", title = "🔍", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "f") 
        end},
        {id = "run", title = "▶️", callback = function() 
            hs.eventtap.keyStroke({}, "F5") 
        end},
        {id = "debug", title = "🐛", callback = function() 
            hs.eventtap.keyStroke({}, "F9") 
        end},
        {id = "terminal", title = "⌨️", callback = function() 
            hs.eventtap.keyStroke({"ctrl"}, "`") 
        end}
    }
})
```

## Finding Bundle IDs

To find an application's bundle ID for profiles:

1. Open the Hammerspoon Console
2. Launch the target application
3. Run: `hs.application.frontmostApplication():bundleID()`

Common bundle IDs:
- Safari: `com.apple.Safari`
- Terminal: `com.apple.Terminal`
- VS Code: `com.microsoft.VSCode`
- Finder: `com.apple.finder`
- Chrome: `com.google.Chrome`
- Firefox: `org.mozilla.firefox`

## API Reference

### Methods

#### `TouchBar:start()`
Starts the TouchBar system and creates the default bar.

#### `TouchBar:stop()`
Stops the TouchBar system and cleans up resources.

#### `TouchBar:addAppProfile(bundleID, profile)`
Adds a TouchBar profile for a specific application.

**Parameters:**
- `bundleID` (string): Application bundle identifier
- `profile` (table): Profile configuration with items

#### `TouchBar:setDefaultItems(items)`
Sets the default TouchBar items shown when no app profile is active.

**Parameters:**
- `items` (table): Array of item configurations

### Item Configuration

Each TouchBar item is configured with:

```lua
{
    id = "unique_identifier",     -- Required: Unique identifier
    title = "Button Text",        -- Required: Display text or emoji
    callback = function() end,    -- Optional: Function to execute on press
    color = "white"              -- Optional: Text color
}
```

## Advanced Usage

### System Monitoring Items

```lua
spoon.TouchBar:setDefaultItems({
    {id = "cpu", title = function() 
        return "CPU: " .. math.floor(hs.host.cpuUsage().overall) .. "%"
    end},
    {id = "memory", title = function()
        local stats = hs.host.vmStat()
        local used = stats.memActive + stats.memWired
        local total = used + stats.memFree
        return "RAM: " .. math.floor(used/total*100) .. "%"
    end},
    {id = "battery", title = function()
        local bat = hs.battery.percentage()
        return bat and ("🔋 " .. bat .. "%") or "🔌"
    end}
})
```

### Conditional Items

```lua
spoon.TouchBar:addAppProfile("com.spotify.client", {
    items = {
        {id = "prev", title = "⏮", callback = function() 
            hs.spotify.previous() 
        end},
        {id = "play_pause", title = function()
            return hs.spotify.isPlaying() and "⏸" or "▶️"
        end, callback = function() 
            hs.spotify.playpause() 
        end},
        {id = "next", title = "⏭", callback = function() 
            hs.spotify.next() 
        end},
        {id = "track", title = function()
            local track = hs.spotify.getCurrentTrack()
            return track and (track.artist .. " - " .. track.name) or "No Track"
        end}
    }
})
```

## Troubleshooting

### TouchBar Not Appearing
- Verify your MacBook has a physical TouchBar
- Check that `hs._asm.undocumented.touchbar` is installed
- Ensure macOS version is 10.12.1 or later

### Extension Not Found
```lua
-- Test if extension is available
local success, touchbar = pcall(require, "hs._asm.undocumented.touchbar")
if not success then
    print("TouchBar extension not found")
end
```

### Items Not Responding
- Check that callback functions are valid
- Verify application bundle IDs are correct
- Look for console errors in Hammerspoon

### Memory Issues
The TouchBar extension has some known cleanup issues. If you experience:
- Memory leaks after repeated reloads
- Crashes during Hammerspoon restart

Try:
1. Fully quit and restart Hammerspoon instead of reloading
2. Use minimal TouchBar configurations during development
3. Monitor system resources

## Differences from CustomControlBar

| Feature | TouchBar.spoon | CustomControlBar.spoon |
|---------|----------------|------------------------|
| Hardware | Physical TouchBar | Any Mac (virtual display) |
| Integration | Native TouchBar system | Canvas-based floating panel |
| Performance | Hardware accelerated | Software rendered |
| Positioning | Fixed TouchBar location | Customizable positioning |
| Compatibility | TouchBar MacBooks only | All Macs |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test on actual TouchBar hardware
4. Follow existing code style
5. Submit pull request

## Known Issues

- Memory leaks possible with frequent reloads (extension limitation)
- Some complex UI elements not yet supported
- Cleanup on Hammerspoon exit needs improvement

## License

MIT License - see LICENSE file for details.

## Credits

- Based on `hs._asm.undocumented.touchbar` by @asmagill
- Inspired by TouchBar discussions in Hammerspoon community
- Special thanks to TouchBar hardware testers 