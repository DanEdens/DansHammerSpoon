hs.loadSpoon("ModalMgr")
local __FILE__ = 'loadConfig.lua'

-- Logger for Spoon loading
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('SpoonLoader')

log:d('Initializing Spoon loading system', __FILE__, 7)

-- Monkey-patch the standard hs.logger.new function to use our HyperLogger instead
-- This ensures that all Spoons using hs.logger will actually use our styled HyperLogger
log:i('Replacing standard hs.logger.new with HyperLogger for consistent styling', __FILE__, 11)

-- Store the original hs.logger.new function
local originalLoggerNew = hs.logger.new

-- Replace with our wrapper that returns a HyperLogger instance
hs.logger.new = function(namespace, loglevel)
    log:d('Intercepted logger creation for: ' .. (namespace or "unnamed"), __FILE__, 17)

    -- Create a HyperLogger instance instead
    local hyperLogger = HyperLogger.new(namespace, loglevel)

    -- Return the HyperLogger instance
    return hyperLogger
end

-- Define default Spoons which will be loaded
local hspoon_list = {
    "AClock",
    "EmmyLua",
    "ClipShow",
    "ClipboardTool",
    "DragonGrid",
    "Layouts",
    -- Disabled/Optional Spoons (uncomment to enable)
    -- "BingDaily",
    -- "CircleClock",
    -- "CountDown",
    -- "HammerGhost",
    -- "HSKeybindings",
    -- "SpoonInstall",
    -- "HCalendar",
    -- "HSaria2",
    -- "HSearch",
    -- "SpeedMenu",
    -- "WinWin",
    -- "FnMate",
}

log:d('Loading Spoons', __FILE__, 45)

-- Load Spoons with error handling
local loaded_spoons = {}
local failed_spoons = {}

for _, spoon_name in pairs(hspoon_list) do
    log:d('Attempting to load Spoon: ' .. spoon_name, __FILE__, 52)
    local success, error_msg = pcall(function() hs.loadSpoon(spoon_name) end)

    if success and spoon[spoon_name] then
        table.insert(loaded_spoons, spoon_name)
        log:d('Successfully loaded Spoon: ' .. spoon_name, __FILE__, 57)
    else
        table.insert(failed_spoons, spoon_name)
        log:e('Failed to load Spoon: ' .. spoon_name .. (error_msg and (' - ' .. error_msg) or ''), __FILE__, 60)
    end
end

log:i('Loaded ' .. #loaded_spoons .. ' Spoons, ' .. #failed_spoons .. ' failed', __FILE__, 64)

-- Start each spoon that has a start function
local started_spoons = {}
for _, spoon_name in pairs(loaded_spoons) do
    if spoon[spoon_name] and type(spoon[spoon_name].start) == "function" then
        log:d('Starting Spoon: ' .. spoon_name, __FILE__, 70)
        local success, error_msg = pcall(function() spoon[spoon_name]:start() end)

        if success then
            table.insert(started_spoons, spoon_name)
            log:d('Successfully started Spoon: ' .. spoon_name, __FILE__, 75)
        else
            log:e('Failed to start Spoon: ' .. spoon_name .. (error_msg and (' - ' .. error_msg) or ''), __FILE__, 77)
        end
    end
end

log:i('Started ' .. #started_spoons .. ' Spoons', __FILE__, 81)

-- Restore the original logger function (but at this point all Spoons already have HyperLogger instances)
hs.logger.new = originalLoggerNew

-- Return loaded spoons for reference in other modules
return {
    loaded = loaded_spoons,
    failed = failed_spoons,
    started = started_spoons
}
