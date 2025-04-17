-- HyperLogger.lua
-- A custom logger for Hammerspoon that creates clickable log messages with file and line information

local HyperLogger = {}

-- Table to store all logger instances
local loggers = {}

-- URL encode a string
local function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end
-- Create a styled text string with a clickable link
local function createClickableLog(message, file, line)
    -- Create a string that will be clickable and open the file at the specified line
    local clickableText = hs.styledtext.new(
        message .. " [" .. file .. ":" .. line .. "]",
        {
            font = { name = "Menlo", size = 12 },
            color = { red = 0.5, green = 0.7, blue = 1.0 },
            underlineStyle = "single",
            underlineColor = { red = 0.5, green = 0.7, blue = 1.0 }
        }
    )

    -- Add metadata to make it clickable with properly encoded URL
    clickableText = clickableText:setStyle({
        link = "hammerspoon://openFile?file=" .. urlEncode(file) .. "&line=" .. line
    }, #message + 2, #clickableText)

    return clickableText
end

-- Create a new logger with the given namespace
function HyperLogger.new(namespace, loglevel)
    -- Check if the logger already exists
    if loggers[namespace] then
        return loggers[namespace]
    end

    -- Create a standard logger as the base
    local baseLogger = hs.logger.new(namespace, loglevel or "info")

    -- Create our custom logger object
    local logger = {
        _namespace = namespace,
        _baseLogger = baseLogger
    }

    -- Store logger for reuse
    loggers[namespace] = logger

    -- Helper function to get caller info
    local function getCallerInfo()
        local info = debug.getinfo(3, "Sl") -- 3 levels up: getCallerInfo > log function > caller
        return info.short_src, info.currentline
    end

    -- Define log levels with file/line tracking
    logger.i = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end

        -- Base logger for console output and regular logging
        self._baseLogger.i(message)

        -- Create clickable styled text and print to console
        local styledText = createClickableLog(message, file, line)
        hs.console.printStyledtext(styledText)

        return self
    end

    logger.d = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end

        self._baseLogger.d(message)
        local styledText = createClickableLog(message, file, line)
        hs.console.printStyledtext(styledText)

        return self
    end

    logger.w = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end

        self._baseLogger.w(message)
        local styledText = createClickableLog(message, file, line)
        hs.console.printStyledtext(styledText)

        return self
    end

    logger.e = function(self, message, file, line)
        if not file or not line then
            file, line = getCallerInfo()
        end

        self._baseLogger.e(message)
        local styledText = createClickableLog(message, file, line)
        hs.console.printStyledtext(styledText)

        return self
    end

    -- Set log level
    logger.setLogLevel = function(self, loglevel)
        self._baseLogger.setLogLevel(loglevel)
        return self
    end

    logger.getLogLevel = function(self)
        return self._baseLogger.getLogLevel()
    end

    return logger
end

-- Register a URL handler to open files
hs.urlevent.bind("openFile", function(eventName, params)
    if params.file and params.line then
        local editor = "cursor" -- Default editor
        local file = params.file
        local line = params.line

        -- Check if the file exists
        if hs.fs.attributes(file) then
            -- For cursor, we can specify the line number in the URL
            local cmd = string.format("/usr/bin/open -a %s \"%s\":%s", editor, file, line)
            hs.execute(cmd)
        else
            hs.alert.show("Could not find file: " .. file)
        end
    end
end)

return HyperLogger
