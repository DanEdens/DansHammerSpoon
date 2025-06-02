# TouchBar Solutions for Hammerspoon

This document explains the two TouchBar solutions we've developed for different hardware scenarios.

## Overview

We've created two distinct Spoons to address TouchBar functionality across all Mac hardware configurations:

1. **TouchBar.spoon** - Real TouchBar control for MacBooks with physical TouchBar hardware
2. **CustomControlBar.spoon** - Virtual TouchBar alternative for all other Macs

## Hardware Compatibility

### MacBook Models with TouchBar (2016-2021)
- MacBook Pro 13" (2016-2020)
- MacBook Pro 15" (2016-2019) 
- MacBook Pro 16" (2019-2021)

**Use**: TouchBar.spoon

### All Other Macs
- Mac Pro (all models)
- Mac Studio
- Mac mini
- MacBook Air (all models)
- iMac (all models)
- MacBooks without TouchBar

**Use**: CustomControlBar.spoon

## Solution Comparison

| Feature | TouchBar.spoon | CustomControlBar.spoon |
|---------|----------------|------------------------|
| **Hardware** | Physical TouchBar only | Any Mac |
| **Display** | Native TouchBar | Floating panel on screen |
| **Integration** | Native macOS TouchBar system | Canvas-based UI |
| **Performance** | Hardware accelerated | Software rendered |
| **Positioning** | Fixed TouchBar location | Customizable (top/bottom/left/right/custom) |
| **Sizing** | Fixed TouchBar dimensions | Configurable width/height |
| **Theme Support** | Limited TouchBar styling | Full color/transparency customization |
| **Dependencies** | Requires hs._asm.undocumented.touchbar | Pure Hammerspoon (no external deps) |
| **Setup Complexity** | Requires extension installation | Works out of the box |
| **Visual Feedback** | TouchBar visual changes | On-screen panel |
| **Use Case** | MacBook TouchBar owners | Desktop users, non-TouchBar MacBooks |

## TouchBar.spoon (Real TouchBar)

### Key Features
- **Native TouchBar Integration**: Uses actual TouchBar hardware
- **System-Level Control**: Integrates with macOS TouchBar system
- **Hardware Performance**: Leverages native TouchBar rendering
- **Context Switching**: Automatic app-based TouchBar layouts

### Installation Requirements
1. MacBook with physical TouchBar hardware
2. Install `hs._asm.undocumented.touchbar` extension
3. macOS 10.12.1 or later

### Example Usage
```lua
hs.loadSpoon("TouchBar")

-- Add Safari profile
spoon.TouchBar:addAppProfile("com.apple.Safari", {
    items = {
        {id = "back", title = "←", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "[") 
        end},
        {id = "forward", title = "→", callback = function() 
            hs.eventtap.keyStroke({"cmd"}, "]") 
        end}
    }
})

spoon.TouchBar:start()
```

### Advantages
- True TouchBar experience
- No screen real estate used
- Native system integration
- Hardware-accelerated rendering

### Limitations
- Requires specific MacBook models
- Extension dependency
- Limited customization options
- Potential memory issues with frequent reloads

## CustomControlBar.spoon (Virtual TouchBar)

### Key Features
- **Universal Compatibility**: Works on any Mac
- **Visual Customization**: Full theme and positioning control
- **Screen Integration**: Floating panel that integrates with desktop
- **Flexible Sizing**: Configurable dimensions and placement

### Installation Requirements
- Any Mac running macOS
- Hammerspoon (no additional extensions needed)

### Example Usage
```lua
hs.loadSpoon("CustomControlBar")

-- Configure appearance
spoon.CustomControlBar.position = "bottom"
spoon.CustomControlBar.size = {w = 800, h = 60}

-- Add Safari profile
spoon.CustomControlBar:addAppProfile("com.apple.Safari", {
    buttons = {
        {icon = "⬅", action = "cmd+[", tooltip = "Back"},
        {icon = "➡", action = "cmd+]", tooltip = "Forward"}
    }
})

spoon.CustomControlBar:start()
```

### Advantages
- Works on all Macs
- Highly customizable appearance
- No external dependencies
- Stable and reliable
- Better suited for desktop workflows

### Limitations
- Uses screen real estate
- Software-rendered (slightly less performant)
- Mouse interaction instead of touch

## Use Case Recommendations

### Choose TouchBar.spoon When:
- You have a MacBook with physical TouchBar
- You want native TouchBar integration
- You prefer hardware-based controls
- Screen real estate is important

### Choose CustomControlBar.spoon When:
- You have a Mac Pro, Mac Studio, or Mac mini
- You have a MacBook without TouchBar
- You want more visual customization
- You prefer mouse-friendly interfaces
- You need flexible positioning options

## Migration Path

If you have both types of Macs in your workflow:

1. **Dual Setup**: Configure both Spoons with similar profiles
2. **Conditional Loading**: Use machine detection to load appropriate Spoon
3. **Shared Profiles**: Create common configuration that works for both

### Conditional Loading Example
```lua
-- Check for TouchBar hardware
local hasTouchBar = false
pcall(function()
    local touchbar = require("hs._asm.undocumented.touchbar")
    hasTouchBar = touchbar.physical()
end)

if hasTouchBar then
    hs.loadSpoon("TouchBar")
    spoon.TouchBar:start()
else
    hs.loadSpoon("CustomControlBar")
    spoon.CustomControlBar:start()
end
```

## Application Profiles

Both Spoons support application-specific profiles. Here's how to create compatible profiles for both:

### Safari Profile (Both Spoons)
```lua
-- TouchBar.spoon
spoon.TouchBar:addAppProfile("com.apple.Safari", {
    items = {
        {id = "back", title = "←", callback = function() hs.eventtap.keyStroke({"cmd"}, "[") end},
        {id = "forward", title = "→", callback = function() hs.eventtap.keyStroke({"cmd"}, "]") end}
    }
})

-- CustomControlBar.spoon  
spoon.CustomControlBar:addAppProfile("com.apple.Safari", {
    buttons = {
        {icon = "⬅", action = "cmd+[", tooltip = "Back"},
        {icon = "➡", action = "cmd+]", tooltip = "Forward"}
    }
})
```

## Future Development

### TouchBar.spoon Roadmap
- Enhanced cleanup and memory management
- Support for more TouchBar UI elements (sliders, scrubbers)
- Better error handling and fallbacks
- Dynamic content updates

### CustomControlBar.spoon Roadmap
- Slider controls for system settings
- Widget system for system monitoring
- Animation and transition effects
- Multiple control bar instances

## Installation Scripts

### TouchBar.spoon Installation
```bash
# Install extension
cd ~/.hammerspoon
curl -L https://github.com/asmagill/hs._asm.undocumented.touchbar/raw/master/touchbar-v0.8.3.2alpha-universal.tar.gz | tar -xz

# Test installation
lua -e "require('hs._asm.undocumented.touchbar')"
```

### CustomControlBar.spoon Installation
```bash
# No additional dependencies needed
# Just copy Spoons/CustomControlBar.spoon/ to ~/.hammerspoon/Spoons/
```

## Testing Both Solutions

Use the provided test scripts to verify functionality:
- `test_real_touchbar.lua` - Tests TouchBar.spoon
- `test_custom_control_bar.lua` - Tests CustomControlBar.spoon

## Conclusion

Both solutions provide excellent TouchBar functionality for their respective target hardware. The choice between them should be based primarily on your hardware configuration, with TouchBar.spoon for MacBooks with physical TouchBars and CustomControlBar.spoon for all other Mac setups.

The dual approach ensures that all Mac users can benefit from TouchBar-like functionality regardless of their hardware, while providing optimized experiences for each platform. 