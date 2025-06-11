# Monitor-Aware Window Locations

## Overview

The WindowToggler system has been enhanced to automatically use different window location files based on your monitor configuration. This allows you to have separate saved window positions for:

- **Laptop** - Single built-in display (on the go)
- **Dual Monitor** - Two monitors (typical home/office desk)
- **Triple Monitor** - Three monitors (advanced workstation)
- **Multi Monitor** - Four or more monitors

## Features

### Automatic Configuration Detection

- **Monitor Count Detection**: Automatically detects the number of connected monitors
- **Configuration-Specific Files**: Uses separate files for each monitor setup:
  - `window_locations_laptop.json` - Single monitor setup
  - `window_locations_dual_monitor.json` - Two monitor setup  
  - `window_locations_triple_monitor.json` - Three monitor setup
  - `window_locations_multi_monitor.json` - Four+ monitor setup

### Seamless Switching

- **Automatic Migration**: Existing `window_locations.json` automatically migrated to current configuration
- **Hot Switching**: When monitors are connected/disconnected, saved positions automatically switch
- **Configuration Persistence**: Each monitor setup maintains its own saved window positions

## New Functions

### Core Functions

#### `WindowToggler.refreshConfiguration()`

Manually checks for monitor configuration changes and switches to appropriate window locations file.

#### `WindowToggler.showConfigurationInfo()`

Displays current monitor configuration and saved window counts.

### Existing Functions (Enhanced)

All existing WindowToggler functions now work with configuration-specific files:

- `WindowToggler.saveToLocation1()` - Saves to current configuration's file
- `WindowToggler.saveToLocation2()` - Saves to current configuration's file  
- `WindowToggler.restoreToLocation1()` - Restores from current configuration's file
- `WindowToggler.restoreToLocation2()` - Restores from current configuration's file
- `WindowToggler.toggleWindowPosition()` - Uses current configuration's saved positions

## New Hotkeys

| Key Combination | Function | Description |
|----------------|----------|-------------|
| `Hammer + F11` | Show Window Config Info | Display current configuration and saved window counts |
| `Hyper + F11` | Refresh Window Config | Check for monitor changes and switch configurations |

## Usage Examples

### Basic Usage

The system works automatically - when you connect/disconnect monitors, it switches to the appropriate saved window positions.

### Manual Configuration Check

Use `Hammer + F11` to see your current monitor setup and how many windows you have saved.

### Force Configuration Refresh

Use `Hyper + F11` after connecting/disconnecting monitors to manually refresh the configuration.

### Multi-Environment Workflow

#### At Home (Dual Monitor)

1. Position your windows where you want them
2. Save positions using `Hammer + O` (Location 1) and `Hammer + N` (Location 2)
3. These are saved to `window_locations_dual_monitor.json`

#### At Office (Triple Monitor)  

1. Connect to your office setup (3 monitors)
2. System automatically switches to `window_locations_triple_monitor.json`
3. Position windows for your office layout
4. Save positions - they're stored separately from your home setup

#### On the Go (Laptop Only)

1. Disconnect external monitors
2. System automatically switches to `window_locations_laptop.json`
3. Use compact window layouts optimized for single screen
4. Save positions for mobile productivity

### Window Position Management

#### Save Positions for Current Setup

```lua
-- These save to configuration-specific files automatically
WindowToggler.saveToLocation1()    -- Current window to Location 1
WindowToggler.saveToLocation2()    -- Current window to Location 2
```

#### Restore Positions

```lua
-- These restore from current configuration's file
WindowToggler.restoreToLocation1()  -- Go to Location 1
WindowToggler.restoreToLocation2()  -- Go to Location 2
WindowToggler.toggleWindowPosition() -- Smart toggle between locations
```

## File Structure

The system creates separate files in `~/.hammerspoon/data/`:

```
data/
├── window_locations_laptop.json        # Single monitor positions
├── window_locations_dual_monitor.json  # Two monitor positions  
├── window_locations_triple_monitor.json # Three monitor positions
├── window_locations_multi_monitor.json # 4+ monitor positions
└── window_locations.json.backup        # Backup of original file
```

## Migration

### Automatic Migration

- Existing `window_locations.json` automatically migrated to current configuration on first load
- Original file backed up as `window_locations.json.backup`
- No user action required

### Manual Migration

If you want to copy saved positions between configurations:

```bash
# Copy laptop positions to dual monitor setup
cp data/window_locations_laptop.json data/window_locations_dual_monitor.json
```

## Technical Details

### Configuration Detection

- Uses `hs.screen.allScreens()` to count connected monitors
- Runs on module load and when manually refreshed
- Cached until configuration changes

### File Management

- JSON format for human-readable saved positions
- Atomic saves to prevent data corruption
- Graceful handling of missing files

### Performance

- Minimal overhead - detection only on load or manual refresh
- File switching happens only when monitor configuration changes
- Existing window operations unchanged in performance

## Troubleshooting

### Positions Not Loading After Monitor Change

Use `Hyper + F11` to manually refresh the configuration.

### Wrong Configuration Detected

Check configuration with `Hammer + F11`. If incorrect, try refreshing with `Hyper + F11`.

### Missing Saved Positions

Use `Hammer + F11` to see current file and saved window counts. Positions are configuration-specific.

### Restore Original Behavior

The original `window_locations.json.backup` file contains your pre-migration data if needed.

## Use Cases

### Developer Workflow

- **Home**: Dual monitor with IDE on main screen, terminal/browser on secondary
- **Office**: Triple monitor with IDE on center, documentation left, testing right  
- **Travel**: Laptop with compact split-screen development setup

### Content Creator Workflow

- **Studio**: Triple monitor with timeline on center, media browser left, export preview right
- **Home**: Dual monitor with editing on main, preview/tools on secondary
- **Mobile**: Laptop with timeline maximized and floating tool panels

### Business User Workflow  

- **Office**: Dual monitor with email/calendar on secondary, documents on primary
- **Home**: Single monitor with compact window arrangements
- **Conference Room**: Projector setup with presentation-optimized layouts

This system provides seamless window management across different work environments while maintaining the same simple hotkeys and familiar workflow.
