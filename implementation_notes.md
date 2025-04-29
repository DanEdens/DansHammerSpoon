# Dynamic Layout Capture System - Implementation Notes

## Overview

The Dynamic Layout Capture system allows users to define custom window layouts by simply clicking on screen positions rather than writing code. This makes it much more accessible for users to create personalized window layouts.

## Components

1. **Hotkey Integration**
   - `hammer+a` - Start layout capture mode
   - `_hyper+a` - List all custom layouts

2. **Mouse Event Capture**
   - Uses `hs.eventtap` to listen for mouse clicks during layout capture mode
   - Records click positions relative to screen coordinates
   - Translates absolute coordinates to percentages of screen size for better cross-screen compatibility

3. **Data Storage**
   - Primary: MongoDB database for persistent storage
   - Backup: Local JSON file (custom_layouts.json)
   - Layouts are stored as serialized functions for precise window positioning

4. **REST API Server**
   - Python Flask-based API server (custom_layouts_api.py)
   - Provides endpoints for CRUD operations on layouts
   - Automatically launched when Hammerspoon starts

## Implementation Details

### Layout Capture Process
1. User initiates capture with hotkey
2. A dialog prompts for layout name
3. User clicks top-left corner of desired area
4. User clicks bottom-right corner of desired area
5. System calculates relative coordinates and creates layout functions
6. Layout is saved to MongoDB and in-memory cache

### Layout Storage Format
Layouts are stored as function strings that can be deserialized:
```lua
{
  name = "custom_layout_name",
  functions = {
    x = "function(max) return max.x + (max.w * 0.25) end",
    y = "function(max) return max.y + (max.h * 0.1) end",
    w = "function(max) return max.w * 0.5 end",
    h = "function(max) return max.h * 0.8 end"
  }
}
```

### API Server Integration
The API server starts automatically with Hammerspoon and provides these endpoints:
- `GET /api/layouts` - List all layouts
- `POST /api/layouts` - Create new layout
- `GET /api/layouts/<string:layout_name>` - Get specific layout
- `DELETE /api/layouts/<string:layout_name>` - Delete layout
- `GET /api/health` - Health check

## Key Design Decisions

1. **Using MongoDB**
   - Allows for future remote syncing between devices
   - Provides robust query capabilities for future enhancements
   - Industry-standard database with good documentation

2. **Separate API Server**
   - Separates concerns between window management and data storage
   - Allows for future extensions like remote layout sharing
   - Makes testing easier with clear API boundaries

3. **Relative Coordinates**
   - Using percentages rather than absolute pixels makes layouts work across different screen sizes
   - Each layout function receives screen dimensions for adaptability

## Future Enhancements

1. **Layout Sharing**
   - Allow users to export/import layouts
   - Cloud sync between multiple devices

2. **Layout Templates**
   - Pre-defined templates for common arrangements
   - Categories for organization

3. **Layout Editor**
   - Visual editor to fine-tune saved layouts
   - Preview functionality before applying

4. **Layout Sequences**
   - Define sequences of layouts for complex window arrangements
   - Timeline-based animation for transitions 
