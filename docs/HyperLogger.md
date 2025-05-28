# HyperLogger

A Hammerspoon logger module that enhances the standard logger with file/line information and colored output.

## Overview

HyperLogger enhances the standard Hammerspoon logging system by adding file and line number information to each log message. This makes it easier to trace where logs are coming from in your code.

## Features

1. **Enhanced Log Messages**
   - Includes file and line information for easy debugging
   - Color-coded by log level in the Hammerspoon console
   - Uses standard logger interface for compatibility

2. **Log Levels**
   - `info` - Blue - Regular information messages
   - `debug` - Gray - Detailed debug information
   - `warning` - Orange/Yellow - Warnings that need attention
   - `error` - Red - Error messages indicating problems

3. **File Information**
   - Each log message includes file and line information
   - Format: `message [filename:line]`

## Example Output

```
This is an info message [init.lua:42]
This is a debug message [my_module.lua:10]
```

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

Run the test script to see the colored output in the Hammerspoon console:

```lua
dofile("test_hyperlogger_colors.lua")
```

## Implementation Details

HyperLogger works by:

1. Capturing the file and line number of the caller using Lua's debug library
2. Formatting the log message as: `message [file:line]`
3. Printing the message to both the Hammerspoon logger and the console

## Configuration

No additional configuration is required.
