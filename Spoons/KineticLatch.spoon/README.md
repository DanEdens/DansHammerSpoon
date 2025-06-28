# KineticLatch.spoon

> *The Mad Tinker's Window Manipulation Contraption* 🔧⚡

A kinetic window latching system for Hammerspoon that allows you to grab and manipulate windows from anywhere on their surface using modifier keys - just like those fancy Linux window managers and Windows utilities, but with more **MADNESS**!

## Features

- **Kinetic Window Latching**: Alt + Left-Click + Drag to move windows from any point
- **Kinetic Window Reshaping**: Alt + Right-Click + Drag to resize windows from any point
- **Configurable Modifiers**: Customize modifier keys and mouse buttons
- **Smooth Operation**: Lag-free, responsive window manipulation
- **Auto-Focus**: Automatically brings manipulated windows to the foreground
- **Sensitivity Control**: Fine-tune the responsiveness of kinetic movements
- **Minimum Window Size**: Prevents windows from becoming too small
- **Mad Science Debug Mode**: Enable detailed logging for troubleshooting

## Installation

### Method 1: Git Clone

```bash
cd ~/.hammerspoon/Spoons
git clone https://github.com/hammerspoon/Spoons/raw/master/Spoons/KineticLatch.spoon.zip
unzip KineticLatch.spoon.zip
```

### Method 2: Manual Download

1. Download the spoon files
2. Place in `~/.hammerspoon/Spoons/KineticLatch.spoon/`

### Configuration

1. Copy the example config file (optional):

   ```bash
   cp ~/.hammerspoon/Spoons/KineticLatch.spoon/.config.example ~/.hammerspoon/.config
   ```

2. Edit the configuration or use `hs.settings` for programmatic configuration.

## Usage

### Basic Setup

```lua
-- Load and start the KineticLatch spoon
hs.loadSpoon("KineticLatch")
spoon.KineticLatch:start()
```

### Configuration Examples

```lua
-- Custom configuration before starting
spoon.KineticLatch.config.moveModifier = { "cmd", "alt" }
spoon.KineticLatch.config.resizeModifier = { "cmd", "alt" }
spoon.KineticLatch.config.sensitivity = 1.5
spoon.KineticLatch.config.debug = true

spoon.KineticLatch:start()
```

### Programmatic Configuration via hs.settings

```lua
-- Set configuration via Hammerspoon settings
hs.settings.set("KINETIC_LATCH_MOVE_MODIFIER", "cmd,alt")
hs.settings.set("KINETIC_LATCH_SENSITIVITY", 1.2)
hs.settings.set("KINETIC_LATCH_DEBUG", true)

-- Then load the spoon
hs.loadSpoon("KineticLatch")
spoon.KineticLatch:start()
```

## How It Works

### Kinetic Window Latching (Moving)

1. Hold down the configured modifier keys (default: `Alt`)
2. Left-click and drag on any part of a window
3. The window will kinetically follow your mouse movement
4. Release to disengage the kinetic latch

### Kinetic Window Reshaping (Resizing)

1. Hold down the configured modifier keys (default: `Alt`)
2. Right-click and drag on any part of a window
3. The window will kinetically resize based on your mouse movement
4. Release to disengage the kinetic reshape

### Mad Science Behind the Scenes

KineticLatch uses Hammerspoon's event tap system to intercept mouse events before they reach applications. When the configured modifier keys are pressed and a mouse button is clicked on a window, the spoon:

1. **Latches onto the window** - Captures the initial window frame and mouse position
2. **Applies kinetic transformations** - Calculates position/size changes based on mouse movement
3. **Updates window geometry** - Smoothly applies changes with disabled animations
4. **Disengages** - Releases the kinetic latch when mouse button is released

## API Reference

### Methods

#### `KineticLatch:init()`

Initializes the KineticLatch spoon and loads configuration.

#### `KineticLatch:start()`

Starts the kinetic latch system and enables window manipulation.

- Returns: `true` if successful, `false` otherwise

#### `KineticLatch:stop()`

Stops the kinetic latch system and disables window manipulation.

#### `KineticLatch:toggle()`

Toggles the kinetic latch system on/off.

- Returns: `true` if now enabled, `false` if disabled

#### `KineticLatch:isEnabled()`

Checks if the kinetic latch system is currently enabled.

- Returns: `true` if enabled, `false` otherwise

#### `KineticLatch:showStatus()`

Shows the current status of the kinetic latch system.

#### `KineticLatch:diagnose()`

Runs kinetic diagnostics and shows system information.

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `moveModifier` | `{ "alt" }` | Modifier keys for kinetic window latching |
| `resizeModifier` | `{ "alt" }` | Modifier keys for kinetic window reshaping |
| `moveButton` | `"left"` | Mouse button for kinetic window latching |
| `resizeButton` | `"right"` | Mouse button for kinetic window reshaping |
| `enabled` | `true` | Enable/disable the kinetic contraption |
| `sensitivity` | `1.0` | Kinetic sensitivity multiplier |
| `minWindowSize` | `{ w = 100, h = 100 }` | Minimum window dimensions |
| `debug` | `false` | Enable mad scientist debug mode |
| `autoStart` | `true` | Auto-engage the contraption on load |

## Configuration via Environment/Settings

You can configure KineticLatch through `hs.settings` or config files:

```bash
# Via hs.settings
hs.settings.set("KINETIC_LATCH_ENABLED", true)
hs.settings.set("KINETIC_LATCH_MOVE_MODIFIER", "cmd,alt")
hs.settings.set("KINETIC_LATCH_SENSITIVITY", 1.5)
hs.settings.set("KINETIC_LATCH_DEBUG", true)
```

## Troubleshooting

### Kinetic Latch Not Working

1. Check if accessibility permissions are enabled for Hammerspoon
2. Verify the modifier keys are configured correctly
3. Enable debug mode to see detailed logs: `spoon.KineticLatch.config.debug = true`
4. Check Hammerspoon console for error messages

### Performance Issues

- Disable debug mode if enabled: `spoon.KineticLatch.config.debug = false`
- Reduce sensitivity: `spoon.KineticLatch.config.sensitivity = 0.8`
- Check for conflicting event taps or other Hammerspoon spoons

### Windows Not Responding

- Some applications may override or block window manipulation
- Try using the spoon with different applications
- Check if the target window is actually resizable/movable

## Integration with Hammerspoon

KineticLatch is designed to work seamlessly with other Hammerspoon modules:

```lua
-- Works great with window management hotkeys
hs.hotkey.bind(hammer, "a", "Toggle KineticLatch", function() 
    spoon.KineticLatch:toggle() 
end)

hs.hotkey.bind(hyper, "a", "KineticLatch Status", function() 
    spoon.KineticLatch:showStatus() 
end)
```

## Contributing

The kinetic contraption welcomes mad contributions! Please see the main repository for contribution guidelines.

## License

MIT License - See LICENSE file for details.

---

*"In the workshop of the mad tinker, windows dance to the rhythm of kinetic energy, bending reality to the will of those brave enough to embrace the madness of perfect window control."* 🧙‍♂️⚡️
