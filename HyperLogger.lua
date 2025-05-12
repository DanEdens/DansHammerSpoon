-- HyperLogger.lua
-- A custom logger for Hammerspoon that creates clickable log messages with file and line information

local HyperLogger = {}

-- Create a self-logger for the HyperLogger module itself
local selfLogger = hs.logger.new('HyperLogger', 'info')
selfLogger.d('Initializing HyperLogger module')
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
    -- Message with color based on log level
    local messageText = hs.styledtext.new(message, {
        font = { name = "Menlo", size = 12 },
        color = levelColor or { white = 0.9 }
    })

    -- File and line info with a distinct color
    local fileInfoText = hs.styledtext.new(" [" .. file .. ":" .. line .. "]", {
        font = { name = "Menlo", size = 12 },
        color = { red = 0.4, green = 0.7, blue = 1.0 }
    })

    -- Combine them
    return fileInfoText .. ": " .. messageText
end

-- Create a new logger instance or return an existing one with the given namespace
function HyperLogger.new(namespace, loglevel)
    -- Safety: ensure namespace is a string
    namespace = tostring(namespace or "Logger")
    loglevel = tostring(loglevel or "info")
    -- Check if the logger already exists and return it
    if loggers[namespace] then
        local existingLogger = loggers[namespace]
        -- Verify the logger is valid, recreate if _baseLogger is nil
        if not existingLogger._baseLogger then
            -- Create a new base logger
            local newBaseLogger = hs.logger.new(namespace, loglevel or "info")
            existingLogger._baseLogger = newBaseLogger
            print("Repaired broken logger: " .. namespace)
        end

        -- Update log level if a different one was requested
        local existingLevel = existingLogger:getLogLevel()
        if loglevel and loglevel ~= existingLevel and existingLevel ~= "unknown" then
            existingLogger:setLogLevel(loglevel)
        end

        return existingLogger
    end

    -- No existing logger found, create a new one
    print('Creating new HyperLogger instance: ' .. namespace)

    -- Create a standard logger as the base
    local baseLogger = hs.logger.new(namespace, loglevel or "info")

    -- Create our custom logger object
    local logger = {
        _namespace = namespace,
        _baseLogger = baseLogger
    }

    -- Helper function to get caller info
    local function getCallerInfo()
        local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
        if not info then
            return "unknown", 0
        end
        return info.short_src or "unknown", info.currentline or 0
    end

    -- Define log levels with file/line tracking and colors
    logger.i = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        -- Only create a styled text log message - don't use the baseLogger which causes duplication
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.info)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.d = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        -- Only create a styled text log message - don't use the baseLogger which causes duplication
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.debug)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.w = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        -- Only create a styled text log message - don't use the baseLogger which causes duplication
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.warning)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.e = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        -- Only create a styled text log message - don't use the baseLogger which causes duplication
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.error)
        hs.console.printStyledtext(coloredText)
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
    selfLogger.i('All loggers have been reset')
end

-- Function to get editor command based on $EDITOR environment variable
local function getEditorCommand(file, line)
    -- Get the editor from environment variable or use a default
    local editorEnv = hs.execute("echo $EDITOR"):gsub("%s+$", "")
    local editor = editorEnv ~= "" and editorEnv or "cursor"
    selfLogger.d('Using editor: ' .. editor)

    -- Get the full path to the editor if it's not an absolute path already
    local editorPath = editor
    if not editor:match("^/") and not editor:match("^open ") then
        -- Try to get the full path using 'which'
        local fullPath = hs.execute("which " .. editor):gsub("%s+$", "")
        if fullPath ~= "" then
            editorPath = fullPath
            selfLogger.d('Resolved editor path: ' .. editorPath)
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
    selfLogger.d('URL handler called with params: ' .. hs.inspect(params))
    if params.file and params.line then
        local file = params.file
        local line = params.line

        -- Check if the file exists
        if hs.fs.attributes(file) then
            selfLogger.i('Opening file in editor: ' .. file .. ':' .. line)
            -- Show a toast to indicate the link was clicked
            hs.alert.show("Opening " .. file .. ":" .. line, 1)
            -- Get the appropriate editor command
            local cmd = getEditorCommand(file, line)
            selfLogger.d('Executing command: ' .. cmd)

            local success, output, descriptor = hs.execute(cmd)
            if not success then
                selfLogger.e('Failed to open editor: ' .. (output or "Unknown error"))
                hs.alert.show("Failed to open file in editor")
            end
        else
            selfLogger.w('File not found: ' .. file)
            hs.alert.show("Could not find file: " .. file)
        end
    else
        selfLogger.e('Invalid URL parameters received')
    end
end)

selfLogger.d('HyperLogger module loaded successfully')
return HyperLogger
