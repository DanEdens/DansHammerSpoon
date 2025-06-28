# KineticLatch.spoon - The Mad Tinker's Window Manipulation Contraption! 🔧⚡

**A kinetic window latching system that allows you to grab and manipulate windows from anywhere on their surface using modifier keys - just like those fancy Linux window managers and Windows utilities, but with more MADNESS!**

## Mad Science Features ⚡

- **Alt + Left-Click + Drag**: Latch onto windows and drag them around from any point
- **Alt + Right-Click + Drag**: Kinetically reshape windows from any point  
- **Configurable modifiers**: Customize which keys unleash the kinetic forces
- **Smooth, lag-free operation**: Optimized for mad tinkering with minimal debug logging
- **Auto-focusing**: Windows automatically come to the foreground for kinetic manipulation
- **Kinetic feedback**: Visual alerts and status messages for the contraption

## Installation & Usage 🔧

### Automatic Start (Default)

KineticLatch engages automatically when Hammerspoon loads! No manual intervention required for the mad science to begin.

### Hotkey Controls

- **`Cmd+Ctrl+Alt+A`**: Toggle the kinetic contraption on/off
- **`Cmd+Shift+Ctrl+Alt+A`**: Show detailed status of the kinetic system
- **`Cmd+Shift+Alt+A`**: Run kinetic diagnostics for troubleshooting

### Basic Kinetic Operations

1. **Latch and Move**: Hold `Alt` and left-click anywhere on a window, then drag to move it around
2. **Kinetic Reshaping**: Hold `Alt` and right-click anywhere on a window, then drag to resize it
3. **Release**: Simply release the mouse button to disengage the kinetic latch

## Configuration 🛠️

You can configure KineticLatch through Lua:

```lua
-- Configure kinetic parameters
spoon.KineticLatch:configure({
    moveModifier = {"alt"},              -- Keys for kinetic latching
    resizeModifier = {"alt"},            -- Keys for kinetic reshaping
    sensitivity = 1.0,                   -- Kinetic sensitivity multiplier
    minWindowSize = {w = 100, h = 100}, -- Minimum window dimensions
    debug = false                        -- Mad scientist debug mode
})
```

## Mad Tinker API 🔬

### Core Methods

- `spoon.KineticLatch:start()` - Engage the kinetic contraption
- `spoon.KineticLatch:stop()` - Disengage the kinetic contraption  
- `spoon.KineticLatch:toggle()` - Toggle kinetic engagement
- `spoon.KineticLatch:isRunning()` - Check contraption status
- `spoon.KineticLatch:showStatus()` - Display kinetic status alert
- `spoon.KineticLatch:diagnose()` - Run kinetic diagnostics

### Configuration Methods

- `spoon.KineticLatch:configure(config)` - Update kinetic parameters
- `spoon.KineticLatch:getConfig()` - Get current configuration
- `spoon.KineticLatch:getStatus()` - Get detailed status information

## Troubleshooting ⚠️

### Common Issues

1. **"KineticLatch FAILED! Check accessibility permissions"**
   - Open System Preferences → Security & Privacy → Privacy → Accessibility
   - Add Hammerspoon to the list and enable it
   - Restart Hammerspoon

2. **Windows don't respond to kinetic manipulation**
   - Run diagnostics: `Cmd+Shift+Alt+A`
   - Check the Hammerspoon console for kinetic event messages
   - Ensure accessibility permissions are granted

3. **Kinetic latch feels sluggish**
   - Disable debug mode: `spoon.KineticLatch:configure({debug = false})`
   - Adjust sensitivity: `spoon.KineticLatch:configure({sensitivity = 1.5})`

### Debug Mode

Enable mad scientist debug mode for detailed kinetic analysis:

```lua
spoon.KineticLatch:configure({debug = true})
```

## The Mad Science Behind It 🧪

KineticLatch uses Hammerspoon's event tap system to intercept mouse events and apply kinetic transformations to window geometry in real-time. When you engage the kinetic latch (Alt+drag), the contraption:

1. **Intercepts** mouse events before they reach applications
2. **Calculates** kinetic deltas from the initial latch point
3. **Applies** smooth geometric transformations to window frames
4. **Disables** animations for responsive kinetic feedback

The result? Buttery-smooth window manipulation that feels like telekinesis! ⚡

---

*Part of the Madness Interactive project - Where AI meets window management chaos!* 🤖✨
