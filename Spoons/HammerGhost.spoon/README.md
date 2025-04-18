# HammerGhost Spoon

An EventGhost-like macro editor and automation GUI for Hammerspoon.

## Features

- Tree-based organization of macros and actions
- Visual macro editor with drag-and-drop support
- Dark theme matching EventGhost's UI
- Action & Trigger system for creating automations
- Support for hotkeys, timers, and watchers
- Custom action types with parameter support

## Installation

1. Download the latest release
2. Extract the ZIP file
3. Double-click the `HammerGhost.spoon` file to install
4. Add the following to your `init.lua` file:

```lua
hs.loadSpoon("HammerGhost")
```

## Usage

### Basic Setup

```lua
-- Load the spoon
hs.loadSpoon("HammerGhost")

-- Bind hotkeys
spoon.HammerGhost:bindHotkeys({
    toggle = { {"cmd", "alt", "ctrl"}, "g" },
    addAction = { {"cmd", "alt", "ctrl"}, "a" },
    addSequence = { {"cmd", "alt", "ctrl"}, "s" },
    addFolder = { {"cmd", "alt", "ctrl"}, "f" },
    showActions = { {"cmd", "alt", "ctrl"}, "e" }
})

-- Start the spoon
spoon.HammerGhost:start()
```

### Main Window

The main window shows a tree view of your macros, sequences, and actions. You can:

- Drag and drop items to reorganize
- Add new folders, actions, and sequences
- Edit properties of items
- Run actions or sequences

### Action Editor

The Action Editor provides an interface for creating and managing independent actions that can be triggered in various ways. You can:

- Create new actions
- Configure action parameters
- Add triggers (hotkeys, timers, etc.)
- Test actions
- Organize actions by category

## Advanced Usage

### Creating Custom Action Types

You can register custom action types by accessing the action system:

```lua
local actionSystem = dofile(hs.spoons.resourcePath("HammerGhost.spoon/scripts/action_system.lua"))

-- Register a custom action type
actionSystem:registerActionType("myCustomAction", {
    name = "My Custom Action",
    description = "Does something amazing",
    icon = "🚀",
    category = "Custom",
    parameters = {
        text = { type = "string", required = true },
        count = { type = "number", default = 1 }
    },
    handler = function(params)
        -- Implementation of your action
        for i = 1, params.count do
            hs.alert.show(params.text)
        end
        return true
    end
})
```

## Development Roadmap

- [ ] Improved sequence editor with visual flow
- [ ] Conditional logic in sequences
- [ ] Plugin system for extensions
- [ ] Import/export functionality
- [ ] API for other Spoons to register actions

## License

MIT License 
