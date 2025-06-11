# Dynamic Layouts Enhancement

## Overview

The WindowManager has been enhanced with a dynamic layout system that automatically adapts to different monitor configurations. Instead of using static layouts, the system now detects the current monitor setup and switches between different layout sets optimized for each configuration.

## Features

### Automatic Monitor Detection

- **Detects Screen Count**: Automatically identifies the number of connected monitors
- **Configuration Classification**: Classifies setups as:
  - `laptop` - Single built-in display
  - `dual_monitor` - Two monitors (typical desktop setup)
  - `triple_monitor` - Three monitors (advanced setup)
  - `multi_monitor` - Four or more monitors

### Configuration-Specific Layout Sets

#### Laptop Configuration

Optimized for single-screen productivity:

- **Compact Mini Layouts**: Smaller overlay windows that don't dominate the screen
- **Conservative Margins**: Smaller margins to maximize screen real estate
- **Half-Screen Focus**: Emphasis on left/right split layouts

#### Dual Monitor Configuration  

Optimized for typical desktop setups:

- **Wide/Narrow Splits**: 72% primary, 27% secondary layouts
- **Enhanced Mini Layouts**: Multiple positioning options for secondary displays
- **Primary Display Optimization**: Layouts that make full use of the main monitor

#### Triple Monitor Configuration

Optimized for advanced multi-monitor setups:

- **Third-Based Layouts**: Left/center/right third positioning
- **Two-Third Combinations**: Spanning layouts across multiple monitors
- **Advanced Mini Layouts**: Precise positioning across all three displays

## New Functions

### Core Functions

#### `WindowManager.detectMonitorConfiguration()`

Detects and analyzes the current monitor setup.

**Returns:**

```lua
{
    count = 2,
    type = "dual_monitor",
    primary = "Built-in Retina Display",
    screens = {
        {
            name = "Built-in Retina Display",
            uuid = "37D8832A-2D66-02CA-B9F7-8F30A301B230",
            frame = { x = 0, y = 0, w = 2880, h = 1800 },
            size = "2880x1800",
            position = "0,0"
        },
        -- ... additional screens
    }
}
```

#### `WindowManager.getCurrentLayouts()`

Returns the appropriate layout sets for the current configuration.

**Returns:**

```lua
miniLayouts, standardLayouts = WindowManager.getCurrentLayouts()
```

#### `WindowManager.refreshLayouts()`

Manually refreshes the layout system, useful when monitors are connected/disconnected.

#### `WindowManager.showMonitorInfo()`

Displays current monitor configuration information on screen.

### Layout Management

All existing layout functions continue to work but now use the appropriate layout set:

- `WindowManager.applyLayout(layoutName)` - Uses current configuration's layouts
- `WindowManager.miniShuffle()` - Cycles through current configuration's mini layouts

## New Hotkeys

| Key Combination | Function | Description |
|----------------|----------|-------------|
| `Hyper + F8` | Show Monitor Info | Display current monitor configuration |
| `Hyper + F9` | Refresh Layouts | Refresh layout system (useful after monitor changes) |
| `Hammer + F8` | Reset Shuffle Counters | Reset layout cycling counters |
| `Hammer + F9` | Half Shuffle | Grid-based window positioning |
| `Hammer + F10` | Mini Shuffle | Cycle through mini layouts |

## Available Layouts by Configuration

### Common Layouts (All Configurations)

- `fullScreen`, `trueFull`, `nearlyFull`
- `topHalf`, `bottomHalf`, `leftHalf`, `rightHalf`
- `topLeft`, `topRight`, `bottomLeft`, `bottomRight`
- `centerScreen`

### Laptop-Specific Layouts

- `leftSmall`, `rightSmall` - Compact 40% width windows

### Dual Monitor-Specific Layouts

- `leftWide` - 72% width for primary content
- `rightNarrow` - 27% width for secondary content

### Triple Monitor-Specific Layouts

- `leftThird`, `centerThird`, `rightThird` - Equal thirds
- `leftTwoThirds`, `rightTwoThirds` - Spanning layouts

## Usage Examples

### Basic Usage

The system works automatically - existing hotkeys and functions continue to work but now use appropriate layouts for your setup.

### Manual Monitor Detection

```lua
-- Check current configuration
local config = WindowManager.detectMonitorConfiguration()
print("Using " .. config.type .. " configuration with " .. config.count .. " screens")
```

### Refresh After Monitor Changes

```lua
-- After connecting/disconnecting monitors
WindowManager.refreshLayouts()
```

### Configuration-Specific Layout Application

```lua
-- These will use different layouts depending on your monitor setup
WindowManager.applyLayout("leftHalf")    -- Different behavior on laptop vs dual monitor
WindowManager.applyLayout("centerScreen") -- Adapts margins based on screen count
```

## Testing

Run the test script to verify functionality:

```lua
dofile(hs.configdir .. "/test_dynamic_layouts.lua")
```

The test script will:

1. Detect your current monitor configuration
2. List available layouts for your setup
3. Test layout application (if a window is focused)
4. Verify configuration-specific features
5. Test mini shuffle functionality
6. Display monitor information
7. Test layout refresh

## Implementation Details

### Architecture

- **Configuration Detection**: Uses `hs.screen.allScreens()` to detect monitors
- **Layout Sets**: Organized by configuration type with common layouts merged
- **Dynamic Loading**: Layout variables updated when configuration changes
- **Backward Compatibility**: All existing functions continue to work

### Performance

- **Lazy Loading**: Layouts only loaded when needed
- **Caching**: Configuration detected once and cached until refresh
- **Minimal Overhead**: Detection only runs on module load or manual refresh

## Troubleshooting

### Layouts Not Updating After Monitor Changes

Run `WindowManager.refreshLayouts()` or use `Hyper + F9` hotkey.

### Layout Not Available Error

Check if the layout exists for your current configuration:

```lua
local _, layouts = WindowManager.getCurrentLayouts()
print(hs.inspect(layouts))
```

### Monitor Detection Issues

Manually check detected configuration:

```lua
WindowManager.showMonitorInfo()  -- or use Hyper + F8
```

## Future Enhancements

- **Custom Layout Sets**: User-defined layouts for specific monitor configurations
- **Automatic Refresh**: Detect monitor changes automatically
- **Layout Profiles**: Save/restore different layout configurations
- **Screen-Specific Layouts**: Different layouts for different physical monitors

## Migration Notes

### From Static Layouts

- All existing hotkeys continue to work
- Layout names remain the same where possible
- New layouts available based on your monitor configuration
- No configuration changes required

### Performance Impact

- Minimal impact on existing functionality
- Slight delay on first layout application while configuration is detected
- Subsequent operations use cached configuration data

## Configuration Files

The system automatically saves layout configuration in:

- Monitor configuration cached in `WindowManager.currentMonitorConfig`
- Layout sets stored in `WindowManager.layoutSets`
- No external configuration files required

This enhancement provides a much more intelligent and adaptive window management system that automatically optimizes for your specific monitor setup while maintaining full backward compatibility with existing functionality.
