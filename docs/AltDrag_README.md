# Alt-Drag Window Management

A powerful window management system that allows you to move and resize windows from anywhere on the window surface, similar to Linux window managers and Windows utilities like "alt-drag".

## Features

- **Alt + Left-Click + Drag**: Move windows by clicking and dragging anywhere on the window (not just the title bar)
- **Alt + Right-Click + Drag**: Resize windows by clicking and dragging anywhere on the window
- **Configurable modifiers**: Customize which keys to use for different operations
- **Automatic window focus**: Windows are automatically brought to the front when dragging/resizing
- **Smooth operation**: Animations are disabled during drag operations for responsive feel

## Usage

### Basic Operations

1. **Move a window**: Hold `Alt` and left-click anywhere on a window, then drag to move it
2. **Resize a window**: Hold `Alt` and right-click anywhere on a window, then drag to resize it
3. **Release modifier**: Let go of the `Alt` key or mouse button to stop the operation

### Hotkeys

- **Cmd+Ctrl+Alt+A**: Toggle Alt-Drag functionality on/off
- **Cmd+Shift+Ctrl+Alt+A**: Show Alt-Drag status and current operation info

## Configuration

The Alt-Drag system can be configured through the `AltDragManager.setConfig()` function:

```lua
AltDragManager.setConfig({
    moveModifier = {"alt"},        -- Keys for moving windows
    resizeModifier = {"alt"},      -- Keys for resizing windows
    enabled = true,                -- Enable/disable the system
    sensitivity = 1.0,             -- Drag sensitivity multiplier
    minWindowSize = {w = 100, h = 100} -- Minimum window size when resizing
})
```

### Available Modifiers

- `"alt"` - Alt/Option key
- `"cmd"` - Command key
- `"ctrl"` - Control key
- `"shift"` - Shift key

You can use combinations like `{"alt", "shift"}` for more complex modifier requirements.

## Technical Details

The Alt-Drag system uses Hammerspoon's `hs.eventtap` to intercept mouse events and check for modifier keys. When the correct combination is detected:

1. The system identifies the window under the mouse cursor
2. Brings the window to focus
3. Tracks mouse movement to update window position or size
4. Stops when modifiers are released or mouse button is released

## Compatibility

- Works with most macOS applications
- Automatically handles window boundaries and minimum sizes
- Integrates seamlessly with existing Hammerspoon window management
- Compatible with multi-monitor setups

## Troubleshooting

**Alt-Drag not working:**

- Check if the system is enabled with `Cmd+Shift+Ctrl+Alt+A`
- Restart Hammerspoon if needed
- Verify accessibility permissions are granted to Hammerspoon

**Performance issues:**

- Reduce sensitivity if dragging feels too fast
- Check for conflicts with other event taps or mouse utilities

**Window not responding:**

- Some applications may prevent window manipulation
- Try with different applications to verify functionality
- Check Console.app for any error messages

## Integration with Other Modules

The Alt-Drag system works alongside other Hammerspoon window management modules:

- **WindowManager**: Provides layout and positioning functions
- **WindowMenu**: Includes Alt-Drag status in window management menus
- **DragonGrid**: Precision mouse positioning for detailed window work

## Inspiration

This functionality is inspired by:

- Linux window managers (like i3, bspwm, etc.)
- [Windows utilities like "alt-drag"](https://stefansundin.github.io/altdrag/)
- Raspbian desktop environment features

The goal is to bring the convenience of Linux-style window management to macOS through Hammerspoon.
