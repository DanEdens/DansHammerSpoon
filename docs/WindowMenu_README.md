# Window Management Menu System

An awesome comprehensive window management interface inspired by DragonGrid, integrating all WindowManager and WindowToggler features into a unified, intuitive menu system.

## Features

🪟 **Unified Interface**: Single menu access to all window management functions
🎯 **DragonGrid-Style**: Organized, hierarchical menus with clear categories  
⚙️ **Dynamic Configuration**: Adjustable grid sizes, move steps, and animation settings
📱 **Monitor Awareness**: Automatically adapts to different monitor configurations
💾 **Persistent Storage**: Save and restore window layouts and positions
🔍 **Search Support**: Quick access via searchable menu interface

## Main Menu Structure

### 🚀 Quick Actions

- **Toggle Location 1 ⟷ 2**: Switch window between saved positions
- **Window Locations Menu**: Access individual location management

### 🎯 Layout Management

- **Quick Layouts**: Standard window layouts (full, half, corner positions)
- **Grid Layouts**: Configurable grid positioning with 2×2 to 5×5 options  
- **Window Movement**: Precise window movement controls

### 📋 Multi-Window Features

- **Layout Management**: Save/restore complete workspace layouts
- **Monitor Setup**: Monitor-aware position management
- **Status & Info**: Comprehensive system status display

## Hotkeys

| Key Combination | Action | Description |
|----------------|--------|-------------|
| `hammer + r` | **Show Window Menu** | Open the main window management interface |
| `hyper + r` | Reset Shuffle Counters | Reset all layout counters |
| `hammer + F12` | Window Status | Show comprehensive status information |

*Note: All existing WindowToggler and WindowManager hotkeys remain available*

## Menu Categories

### 📐 Quick Layouts

- **Full Screen Variants**
  - 🔲 Full Screen (with margin)
  - ⬜ Nearly Full (90%)
  - 📺 True Full (100%)  
  - 🎯 Centered (70%)

- **Split Layouts**
  - ◐ Left Half / ◑ Right Half
  - ⬇ Top Half / ⬆ Bottom Half

- **Corner Layouts**  
  - ↖ Top Left / ↗ Top Right
  - ↙ Bottom Left / ↘ Bottom Right

### ▦ Grid Layouts

- **Dynamic Grid Sizing**: 2×2, 3×3, 4×4, 5×5
- **Shuffle Functions**: Mini, Horizontal, Vertical shuffles
- **Reset Controls**: Clear all shuffle states

### ⇄ Window Movement

- **Directional Movement**: ← → ↑ ↓ with configurable step size
- **Mouse-Based**: Move to mouse center or corner
- **Step Size Settings**: 50px, 100px, 150px increments

### 📋 Layout Management

- **Multi-Window Layouts**: Save complete workspace arrangements
- **Position Memory**: Save/restore all window positions
- **Bulk Operations**: Clear all saved data with confirmation

### 🖥 Monitor Management

- **Configuration Detection**: Automatic laptop/dual/triple/multi setup
- **Cross-Monitor Movement**: Move windows between screens
- **Config Refresh**: Update monitor-aware settings

### ⚙️ Settings

- **Animation Control**: Toggle window movement animations
- **Gap Configuration**: Adjust spacing between grid positions
- **Reset Options**: Restore all settings to defaults

## Status Information

The status display shows:

- **Active Window**: Current window details and dimensions
- **Configuration**: Grid size, move step, gap settings
- **Monitor Info**: Screen count and configuration type
- **Saved Data**: Count of saved locations and layouts

## Implementation Details

### Menu Architecture

- **Hierarchical Structure**: Main menu with organized submenus
- **Chooser Interface**: Fast, searchable selection with `hs.chooser`
- **Back Navigation**: Easy return to parent menus
- **Icon System**: Visual indicators using Unicode symbols

### Integration Points

- **WindowManager**: All layout and movement functions
- **WindowToggler**: Location-based position management  
- **Monitor Detection**: Automatic configuration awareness
- **Persistent Storage**: JSON-based data persistence

### Configuration Sync

- **Real-time Updates**: Settings changes reflect immediately
- **Global State**: Synchronized with WindowManager/WindowToggler
- **Dynamic Display**: Menu text updates with current settings

## Usage Examples

### Quick Window Arrangement

1. Press `hammer + r` to open menu
2. Select "Quick Layouts ▶"
3. Choose desired layout (e.g., "◐ Left Half")

### Custom Grid Setup

1. Open menu → "Grid Layouts ▶"
2. Select "Set Grid Size 3×3"
3. Use "🔀 Mini Shuffle" to position windows

### Multi-Window Layout

1. Arrange windows as desired
2. Menu → "Layout Management ▶" → "📸 Save Multi-Window Layout"
3. Later: "📋 Restore Multi-Window Layout"

### Monitor Configuration

1. Connect/disconnect monitors
2. Menu → "Monitor Setup ▶" → "🔄 Refresh Monitor Config"
3. Saved positions automatically adapt

## Benefits

✅ **Unified Experience**: No need to remember dozens of hotkeys
✅ **Visual Organization**: Clear categorization of functions
✅ **Discoverable**: Browse available functions easily
✅ **Configurable**: Adjust behavior without code changes
✅ **Persistent**: Settings and layouts survive restarts
✅ **Smart**: Adapts to monitor configuration changes

## Technical Architecture

```lua
WindowMenu
├── Main Menu (createMainMenu)
├── Layout Submenus (createLayoutsSubmenu)
├── Grid Management (createGridSubmenu) 
├── Movement Controls (createMovementSubmenu)
├── Layout Management (createLayoutManagementSubmenu)
├── Monitor Config (createMonitorSubmenu)
├── Settings (createSettingsSubmenu)
└── Status Display (showStatus)
```

## Future Enhancements

- **Custom Layout Saving**: User-defined layout templates
- **Gesture Integration**: Touch/trackpad gesture support
- **Profile Management**: Different settings per project/context  
- **Automation**: Time-based or app-triggered layout changes
- **Cloud Sync**: Share layouts across devices

The Window Management Menu System represents the evolution of Hammerspoon window management from hotkey-heavy to menu-driven, making powerful features accessible and discoverable while maintaining the speed and flexibility of the underlying systems.
