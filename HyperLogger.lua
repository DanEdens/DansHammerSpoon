-- HyperLogger.lua
-- A custom logger for Hammerspoon that creates clickable log messages with file and line information

local HyperLogger = {}

-- Create a self-logger for the HyperLogger module itself
-- local selfLogger = hs.logger.new('HyperLogger', 'debug')
local selfLogger = hs.logger.new('HyperLogger', 'info')
selfLogger.i('Initializing HyperLogger module')
-- Table to store all logger instances
local loggers = {}

-- Define colors for different log levels
local LOG_COLORS = {
    info = { red = 0.3, green = 0.7, blue = 1.0 },    -- Light blue for info
    debug = { white = 0.8 },                          -- Light gray for debug
    warning = { red = 0.9, green = 0.7, blue = 0.0 }, -- Orange for warnings
    error = { red = 1.0, green = 0.3, blue = 0.3 }    -- Light red for errors
}
-- URL encode a string
local function urlEncode(str)
    if str then
        selfLogger.d('URL encoding string')
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

-- Create a styled text string with a clickable link (CURRENTLY WORK IN PROGRESS. Links are not clickable)
local function createClickableLog(message, file, line, levelColor)
    selfLogger.d('Creating clickable log for file: ' .. file .. ' line: ' .. line)
    -- First, the main message part
    local messageText = hs.styledtext.new(message, {
        font = { name = "Menlo", size = 12 },
        color = levelColor or { white = 0.9 }
    })

    -- Then, create a highly visible link part that looks distinctly like a link
    local linkText = hs.styledtext.new(" [📄 " .. file .. ":" .. line .. "]", {
        font = { name = "Menlo", size = 12 },
        color = { red = 0.4, green = 0.7, blue = 1.0 },
        underlineStyle = "single",
        underlineColor = { red = 0.4, green = 0.7, blue = 1.0 },
        backgroundColor = { red = 0.1, green = 0.1, blue = 0.2 },
        link = "hammerspoon://openFile?file=" .. urlEncode(file) .. "&line=" .. line
    })

    -- Add a separator between message and link
    local separatorText = hs.styledtext.new(" ", {
        font = { name = "Menlo", size = 12 },
        color = { white = 0.8 }
    })

    -- Combine them into one styled text object
    local combinedText = messageText .. separatorText .. linkText

    return combinedText
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
    return messageText .. fileInfoText
end
-- Create a new logger with the given namespace
function HyperLogger.new(namespace, loglevel)
    selfLogger.i('Creating new HyperLogger instance for namespace: ' .. namespace)
    -- Check if the logger already exists
    if loggers[namespace] then
        selfLogger.d('Returning existing logger for namespace: ' .. namespace)
        return loggers[namespace]
    end

    -- Create a standard logger as the base
    local baseLogger = hs.logger.new(namespace, loglevel or "info")
    selfLogger.d('Created base logger with level: ' .. (loglevel or "info"))

    -- Create our custom logger object
    local logger = {
        _namespace = namespace,
        _baseLogger = baseLogger
    }

    -- Store logger for reuse
    loggers[namespace] = logger
    selfLogger.d('Stored logger for namespace: ' .. namespace)

    -- Helper function to get caller info
    local function getCallerInfo()
        local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
        selfLogger.d('Retrieved caller info: ' .. info.short_src .. ':' .. info.currentline)
        return info.short_src, info.currentline
    end

    -- Define log levels with file/line tracking and colors
    logger.i = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        local logMsg = string.format("%s [%s:%s]", message, file, line)
        self._baseLogger.i(logMsg)

        -- Print with color
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.info)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.d = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        local logMsg = string.format("%s [%s:%s]", message, file, line)
        self._baseLogger.d(logMsg)

        -- Print with color
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.debug)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.w = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        local logMsg = string.format("%s [%s:%s]", message, file, line)
        self._baseLogger.w(logMsg)

        -- Print with color
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.warning)
        hs.console.printStyledtext(coloredText)
        return self
    end

    logger.e = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end
        local logMsg = string.format("%s [%s:%s]", message, file, line)
        self._baseLogger.e(logMsg)

        -- Print with color
        local coloredText = createColoredLog(message, file, line, LOG_COLORS.error)
        hs.console.printStyledtext(coloredText)
        return self
    end

    -- Set log level
    logger.setLogLevel = function(self, loglevel)
        selfLogger.d('Setting log level for ' .. self._namespace .. ' to: ' .. loglevel)
        self._baseLogger.setLogLevel(loglevel)
        return self
    end

    logger.getLogLevel = function(self)
        return self._baseLogger.getLogLevel()
    end

    return logger
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

selfLogger.i('HyperLogger module loaded successfully')
return HyperLogger
