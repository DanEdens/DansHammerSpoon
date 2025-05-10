# HyperLogger

A powerful logging system for Hammerspoon with clickable log messages that open directly in your preferred editor.

## Overview

HyperLogger enhances the standard Hammerspoon logging system by adding clickable hyperlinks to log messages. When you click on these links in the Hammerspoon console, they open the source file at the exact line where the log message was generated, making debugging significantly easier.

## Features

- Creates logs with file and line information automatically
- Displays clickable hyperlinks in the Hammerspoon console
- Opens files in your preferred editor ($EDITOR) when clicked
- Supports multiple popular editors with correct line number syntax
- Compatible with all standard log levels (debug, info, warning, error)
- Multiple logger instances with different namespaces
- Preserves all functionality of the standard hs.logger

## Editor Integration

HyperLogger now supports opening files in your preferred editor as defined by the `$EDITOR` environment variable. If `$EDITOR` is not set, it defaults to "cursor".

Supported editors with special handling:
- Vim/Vi/Neovim: `vim +<line> <file>`
- Emacs: `emacs +<line> <file>`
- VS Code: `code --goto <file>:<line>`
- Cursor: `open -a cursor <file>:<line>`
- Nano/Pico: `nano +<line> <file>`
- Sublime Text: `subl <file>:<line>`

For other editors, HyperLogger attempts to open the file with a generic command format.

## Important Notes About Clickable Links

The clickable hyperlinks in HyperLogger will **only work when viewed in the actual Hammerspoon console**. Due to limitations in how text is displayed in other contexts:

1. Links will NOT be clickable when viewing logs in:
   - Terminal output
   - IDE consoles
   - Redirected output
   
2. To use the clickable links, you must:
   - Open the Hammerspoon console (press Command+Option+Control+C or run `hs.toggleConsole()`)
   - View the logs directly in this window
   - Click on the highlighted file/line references

This is a limitation of how styled text and hyperlinks work in macOS, not a bug in HyperLogger itself.

## Testing the Links

To verify that the hyperlinks are working correctly:

1. Open the Hammerspoon console
2. Run: `dofile("test_hyperlinks.lua")`
3. Try clicking on the various links displayed in the console

## Usage

### Basic Usage

```lua
-- Load the module
local HyperLogger = require("HyperLogger")

-- Create a new logger with a namespace
local logger = HyperLogger.new("MyModule", "debug")

-- Log messages at different levels
logger:i("This is an info message")
logger:d("This is a debug message")
logger:w("This is a warning message")
logger:e("This is an error message")
```

### Setting Log Level

```lua
-- Create with default level (info)
local logger = HyperLogger.new("MyModule")

-- Change log level later
logger:setLogLevel("debug")

-- Get current log level
local level = logger:getLogLevel()
```

### Manual File and Line Information

You can also provide explicit file and line information if needed:

```lua
logger:i("This message has custom file and line info", "my_file.lua", 42)
```

## Testing

A test script is provided to verify that the editor integration works correctly:

```lua
-- Run the test script
dofile("test_hyperlinks.lua")
```

This will generate several log messages in the Hammerspoon console that you can click on to test the functionality.

## Implementation Details

HyperLogger works by:

1. Creating a styled text message with file and line information
2. Adding a special `hammerspoon://` URL to the styled text
3. Registering a URL handler that opens the file in your preferred editor
4. Determining the appropriate command-line syntax based on your editor
5. Executing the command to open the file at the specific line

## Configuration

No additional configuration is required. To change the editor used, simply set the `$EDITOR` environment variable in your shell profile:

```sh
# In your .bashrc, .zshrc, etc.
export EDITOR="code"  # for VS Code
# or
export EDITOR="vim"   # for Vim
# etc.
```

Remember to reload your shell or restart Hammerspoon for changes to take effect. 
