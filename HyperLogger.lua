-- HyperLogger.lua
-- A custom logger for Hammerspoon that creates clickable log messages with file and line information

local HyperLogger = {}
local __FILE__ = 'HyperLogger.lua'
-- Create a self-logger for the HyperLogger module itself
-- Table to store all logger instances
local loggers = {}

-- Registry of creation stacks to help track where loggers are created
local creationStacks = {}

-- Define colors for different log levels
local LOG_COLORS = {
    info = { red = 0.3, green = 0.7, blue = 1.0 },    -- Light blue for info
    debug = { white = 0.8 },                          -- Light gray for debug
    warning = { red = 0.9, green = 0.7, blue = 0.0 }, -- Orange for warnings
    error = { red = 1.0, green = 0.3, blue = 0.3 }    -- Light red for errors
}

-- Helper to get a formatted stack trace for logging creation points
local function getStackTrace()
    local stack = {}
    for i = 3, 10 do -- Skip the first 2 levels (this function and caller)
        local info = debug.getinfo(i, "Sl")
        if not info then break end
        table.insert(stack, string.format("%s:%d", info.short_src, info.currentline))
    end
    return table.concat(stack, " <- ")
end

-- Create a colored styled text for non-clickable logs
local function createColoredLog(message, file, line, levelColor)
    -- Define standard font styles to match console settings in init.lua
    local MESSAGE_FONT = { name = "Menlo", size = 18 }
    local FILE_INFO_FONT = { name = "Menlo", size = 14 }
    -- Safely stringify the message to handle nil values or other data types
    local safeMessage = ""
    if message == nil then
        safeMessage = "[nil]"
    elseif type(message) == "table" then
        -- Try to use hs.inspect if available, otherwise fall back to tostring
        local success, result = pcall(function() return hs.inspect(message) end)
        safeMessage = success and result or tostring(message)
    elseif type(message) == "function" or type(message) == "userdata" or type(message) == "thread" then
        safeMessage = "[" .. type(message) .. "]"
    else
        -- For numbers, booleans, or strings
        safeMessage = tostring(message)
    end

    -- Ensure file and line are strings
    local safeFile = tostring(file or "unknown")
    local safeLine = tostring(line or 0)

    -- Message with color based on log level - wrapped in pcall for safety
    local messageText
    local success, result = pcall(function()
        return hs.styledtext.new(safeMessage, {
            font = MESSAGE_FONT,
            color = levelColor or { white = 0.9 }
        })
    end)

    if success then
        messageText = result
    else
        -- Fallback if styling fails
        messageText = hs.styledtext.new(safeMessage)
    end

    -- File and line info with a distinct color - also wrapped in pcall
    local fileInfoText
    success, result = pcall(function()
        return hs.styledtext.new(" [" .. safeFile .. ":" .. safeLine .. "]", {
            font = FILE_INFO_FONT,
            color = { red = 0.4, green = 0.7, blue = 1.0 }
        })
    end)

    if success then
        fileInfoText = result
    else
        -- Fallback if styling fails
        fileInfoText = hs.styledtext.new(" [" .. safeFile .. ":" .. safeLine .. "]")
    end

    -- Combine them safely
    return fileInfoText .. ": " .. messageText
end

-- Create a styled log for internal initialization messages (without using a logger)
local function printStyledInit(message, isError)
    local color = isError and { red = 1.0, green = 0.3, blue = 0.3 } or { white = 0.8 }
    local styledText = hs.styledtext.new("[HyperLogger] " .. message, {
        font = { name = "Menlo", size = 18 },
        color = color
    })
    pcall(function() hs.console.printStyledtext(styledText) end)
end
-- Create a new logger instance or return an existing one with the given namespace
function HyperLogger.new(namespace, loglevel)
    -- Safety: ensure namespace is a string and provide a more specific default
    namespace = namespace or "HammerspoonLogger"
    namespace = tostring(namespace)
    loglevel = tostring(loglevel or "debug")
    -- Check if the logger already exists and return it
    if loggers[namespace] then
        local existingLogger = loggers[namespace]
        -- Verify the logger is valid, recreate if _baseLogger is nil
        if not existingLogger._baseLogger then
            -- Create a new base logger
            local newBaseLogger = hs.logger.new(namespace, loglevel or "debug")
            -- Disable standard console output from the base logger
            newBaseLogger.setLogLevel('nothing')
            existingLogger._baseLogger = newBaseLogger
            printStyledInit("Repaired broken logger: " .. namespace)
        end

        -- Update log level if a different one was requested
        local existingLevel = existingLogger:getLogLevel()
        if loglevel and loglevel ~= existingLevel and existingLevel ~= "unknown" then
            existingLogger:setLogLevel(loglevel)
        end

        return existingLogger
    end

    -- No existing logger found, create a new one
    printStyledInit("Creating new HyperLogger instance: " .. namespace)

    -- Create a standard logger as the base
    local baseLogger = hs.logger.new(namespace, loglevel or "debug")
    -- Disable standard console output from the base logger
    -- This prevents duplicate logs with timestamps
    baseLogger.setLogLevel('nothing')

    -- Create our custom logger object
    local logger = {
        _namespace = namespace,
        _baseLogger = baseLogger
    }

    -- Define log levels with file/line tracking and colors
    logger.i = function(self, message, file, line)
        -- Safely get caller info with pcall
        if not file or not line then
            local success, f, l = pcall(function()
                local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
                if not info then
                    return "unknown", 0
                end
                return info.short_src or "unknown", info.currentline or 0
            end)

            if success then
                file, line = f, l
            else
                file, line = "unknown", 0
            end
        end

        -- Safely create and print the styled text
        local success, coloredText = pcall(function()
            return createColoredLog(message, file, line, LOG_COLORS.info)
        end)

        if success then
            pcall(function() hs.console.printStyledtext(coloredText) end)
        else
            -- Fallback if styling fails completely - print a plain message
            pcall(function()
                print(string.format("[INFO] %s [%s:%s]",
                    tostring(message), tostring(file), tostring(line)))
            end)
        end

        return self
    end

    logger.d = function(self, message, file, line)
        -- Safely get caller info with pcall
        if not file or not line then
            local success, f, l = pcall(function()
                local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
                if not info then
                    return "unknown", 0
                end
                return info.short_src or "unknown", info.currentline or 0
            end)

            if success then
                file, line = f, l
            else
                file, line = "unknown", 0
            end
        end

        -- Safely create and print the styled text
        local success, coloredText = pcall(function()
            return createColoredLog(message, file, line, LOG_COLORS.debug)
        end)

        if success then
            pcall(function() hs.console.printStyledtext(coloredText) end)
        else
            -- Fallback if styling fails completely - print a plain message
            pcall(function()
                print(string.format("[DEBUG] %s [%s:%s]",
                    tostring(message), tostring(file), tostring(line)))
            end)
        end

        return self
    end

    logger.w = function(self, message, file, line)
        -- Safely get caller info with pcall
        if not file or not line then
            local success, f, l = pcall(function()
                local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
                if not info then
                    return "unknown", 0
                end
                return info.short_src or "unknown", info.currentline or 0
            end)

            if success then
                file, line = f, l
            else
                file, line = "unknown", 0
            end
        end

        -- Safely create and print the styled text
        local success, coloredText = pcall(function()
            return createColoredLog(message, file, line, LOG_COLORS.warning)
        end)

        if success then
            pcall(function() hs.console.printStyledtext(coloredText) end)
        else
            -- Fallback if styling fails completely - print a plain message
            pcall(function()
                print(string.format("[WARNING] %s [%s:%s]",
                    tostring(message), tostring(file), tostring(line)))
            end)
        end

        return self
    end

    logger.e = function(self, message, file, line)
        -- Safely get caller info with pcall
        if not file or not line then
            local success, f, l = pcall(function()
                local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
                if not info then
                    return "unknown", 0
                end
                return info.short_src or "unknown", info.currentline or 0
            end)

            if success then
                file, line = f, l
            else
                file, line = "unknown", 0
            end
        end

        -- Safely create and print the styled text
        local success, coloredText = pcall(function()
            return createColoredLog(message, file, line, LOG_COLORS.error)
        end)

        if success then
            pcall(function() hs.console.printStyledtext(coloredText) end)
        else
            -- Fallback if styling fails completely - print a plain message
            pcall(function()
                print(string.format("[ERROR] %s [%s:%s]",
                    tostring(message), tostring(file), tostring(line)))
            end)
        end

        return self
    end

    -- Set log level
    logger.setLogLevel = function(self, loglevel)
        if self._baseLogger then
            self._baseLogger.setLogLevel(loglevel)
        else
            -- Just silently ignore if baseLogger is nil
            local errorText = hs.styledtext.new(
                "Error: Cannot set log level - _baseLogger is nil in " .. self._namespace, {
                    color = LOG_COLORS.error
                })
            hs.console.printStyledtext(errorText)
        end
        return self
    end

    logger.getLogLevel = function(self)
        if self._baseLogger then
            return self._baseLogger.getLogLevel()
        else
            -- Return a default level when baseLogger is nil
            return "unknown"
        end
    end

    -- Store the logger
    loggers[namespace] = logger
    return logger
end

-- Create self-logger with a specific namespace instead of default
local selfLogger = HyperLogger.new('HyperLoggerInternal', 'debug')
-- Function to get all registered loggers
function HyperLogger.getLoggers()
    local result = {}
    for namespace, _ in pairs(loggers) do
        table.insert(result, namespace)
    end
    return result
end

-- Function to get creation stack for a logger
function HyperLogger.getCreationStack(namespace)
    return creationStacks[namespace]
end
-- Function to reset all loggers (useful for testing)
function HyperLogger.resetLoggers()
    loggers = {}
    creationStacks = {}
    printStyledInit('All loggers have been reset')
end

-- Function to get editor command based on $EDITOR environment variable
local function getEditorCommand(file, line)
    -- Get the editor from environment variable or use a default
    local editorEnv = hs.execute("echo $EDITOR"):gsub("%s+$", "")
    local editor = editorEnv ~= "" and editorEnv or "cursor"
    selfLogger.d('Using editor: ' .. editor, __FILE__, 326)

    -- Get the full path to the editor if it's not an absolute path already
    local editorPath = editor
    if not editor:match("^/") and not editor:match("^open ") then
        -- Try to get the full path using 'which'
        local fullPath = hs.execute("which " .. editor):gsub("%s+$", "")
        if fullPath ~= "" then
            editorPath = fullPath
            selfLogger.d('Resolved editor path: ' .. editorPath, __FILE__, 335)
        end
    end

    -- Handle different editors with their specific line number syntax
    if editor:match("v[si][m]?$") then -- vim, vi, nvim
        return string.format("%s +%s \"%s\"", editorPath, line, file)
    elseif editor:match("emacs") then
        return string.format("%s +%s \"%s\"", editorPath, line, file)
    elseif editor:match("code") or editor:match("vscode") then
        return string.format("%s --goto \"%s\":%s", editorPath, file, line)
    elseif editor:match("cursor") then
        -- For cursor, we can use the macOS open -a with the line number in the URL
        return string.format("open -a %s \"%s\":%s", editor, file, line)
    elseif editor:match("nano") or editor:match("pico") then
        return string.format("%s +%s \"%s\"", editorPath, line, file)
    elseif editor:match("sublime") or editor:match("subl") then
        return string.format("%s \"%s\":%s", editorPath, file, line)
    else
        -- Generic fallback - try to open the file and hope the editor can handle it
        return string.format("%s \"%s\"", editorPath, file)
    end
end

-- Register a URL handler to open files
hs.urlevent.bind("openFile", function(eventName, params)
    selfLogger.d('URL handler called with params: ' .. hs.inspect(params), __FILE__, 361)
    if params.file and params.line then
        local file = params.file
        local line = params.line

        -- Check if the file exists
        if hs.fs.attributes(file) then
            selfLogger.i('Opening file in editor: ' .. file .. ':' .. line, __FILE__, 368)
            -- Show a toast to indicate the link was clicked
            hs.alert.show("Opening " .. file .. ":" .. line, 1)
            -- Get the appropriate editor command
            local cmd = getEditorCommand(file, line)
            selfLogger.d('Executing command: ' .. cmd, __FILE__, 373)

            local success, output, descriptor = hs.execute(cmd)
            if not success then
                selfLogger.e('Failed to open editor: ' .. (output or "Unknown error"), __FILE__, 375)
                hs.alert.show("Failed to open file in editor")
            end
        else
            selfLogger.w('File not found: ' .. file, __FILE__, 381)
            hs.alert.show("Could not find file: " .. file)
        end
    else
        selfLogger.e('Invalid URL parameters received', __FILE__, 384)
    end
end)

selfLogger.d('HyperLogger module loaded successfully', __FILE__, 393)
printStyledInit('HyperLogger module loaded successfully')
return HyperLogger
