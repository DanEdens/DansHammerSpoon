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

## WebView Implementations
### Main WebView Implementations

The main WebView implementations in the codebase are:

#### HammerGhost.spoon

The most comprehensive WebView implementation in the codebase.
- Uses `hs.webview.new()` to create both the main application window and an action editor window
- Implements a navigation callback that handles custom URL scheme (`hammerspoon://...`) for communication between Lua and JavaScript
- Includes HTML, CSS, and JavaScript assets for UI components
- Uses `hs.webview.toolbar` to create a native macOS toolbar
- Implements two-way communication between the WebView and Lua code

#### HSKeybindings.spoon

A simpler WebView implementation.
- Creates a WebView to display keybindings in an HTML format
- Generates HTML content dynamically from registered hotkeys
- Simpler UI with no interactive elements requiring callbacks

#### Omniscribe

Not directly WebView-related, but includes HyperLogger which uses URL handlers to create clickable links in the Hammerspoon console.

### WebView-related APIs Used

- `hs.webview.new()`: Creates a WebView window with specified dimensions and options
- `webview:windowTitle()`: Sets the window title
- `webview:windowStyle()`: Sets window appearance using `hs.webview.windowMasks.*` flags
- `webview:allowTextEntry()`: Controls whether text input is allowed
- `webview:darkMode()`: Toggles dark mode appearance
- `webview:navigationCallback()`: Sets up a callback to handle URL navigation events
- `webview:html()`: Sets the HTML content of the WebView
- `webview:evaluateJavaScript()`: Executes JavaScript in the WebView context
- `hs.webview.toolbar.new()`: Creates a toolbar for the WebView
- `webview:attachedToolbar()`: Attaches a toolbar to the WebView
- `webview:show()/hide()`: Controls visibility of the WebView

The HammerGhost implementation is the most feature-rich example, using a custom protocol scheme for bidirectional communication between Lua and JavaScript:
- Lua sends data to JavaScript via `webview:evaluateJavaScript()`
- JavaScript sends data to Lua via navigation to URLs like `hammerspoon://someAction?data`
- The `navigationCallback` parses these URLs to extract commands and parameters
