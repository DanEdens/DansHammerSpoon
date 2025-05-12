hs.loadSpoon("ModalMgr")

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

-- Logger for Spoon loading
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('SpoonLoader', 'info')

log:d('Loading Spoons')

-- Load Spoons with error handling
local loaded_spoons = {}
local failed_spoons = {}

for _, spoon_name in pairs(hspoon_list) do
    log:d('Attempting to load Spoon: ' .. spoon_name)
    local success, error_msg = pcall(function() hs.loadSpoon(spoon_name) end)

    if success and spoon[spoon_name] then
        table.insert(loaded_spoons, spoon_name)
        log:d('Successfully loaded Spoon: ' .. spoon_name)
    else
        table.insert(failed_spoons, spoon_name)
        log:e('Failed to load Spoon: ' .. spoon_name .. (error_msg and (' - ' .. error_msg) or ''))
    end
end

log:i('Loaded ' .. #loaded_spoons .. ' Spoons, ' .. #failed_spoons .. ' failed')

-- Start each spoon that has a start function
local started_spoons = {}
for _, spoon_name in pairs(loaded_spoons) do
    if spoon[spoon_name] and type(spoon[spoon_name].start) == "function" then
        log:d('Starting Spoon: ' .. spoon_name)
        local success, error_msg = pcall(function() spoon[spoon_name]:start() end)

        if success then
            table.insert(started_spoons, spoon_name)
            log:d('Successfully started Spoon: ' .. spoon_name)
        else
            log:e('Failed to start Spoon: ' .. spoon_name .. (error_msg and (' - ' .. error_msg) or ''))
        end
    end
end

log:i('Started ' .. #started_spoons .. ' Spoons')

-- Return loaded spoons for reference in other modules
return {
    loaded = loaded_spoons,
    failed = failed_spoons,
    started = started_spoons
}
