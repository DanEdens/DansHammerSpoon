-- WindowToggler.lua - Advanced Window Toggling Functions
-- Using singleton pattern to avoid multiple initializations

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.WindowToggler then
    log:d('Returning existing WindowToggler module')
    return _G.WindowToggler
end

log:i('Initializing window toggler system')

local WindowManager = require('WindowManager')

-- Define the persistence file path
local LOCATIONS_FILE = os.getenv("HOME") .. "/.hammerspoon/data/window_locations.json"
local WindowToggler = {
    -- Store positions by unique window identifier (app_name:window_title)
    savedPositions = {},
    -- Store specific save locations (location1, location2) by window identifier
    location1 = {},
    location2 = {}
}

-- Helper function to ensure data directory exists
local function ensureDataDirectory()
    local dataDir = os.getenv("HOME") .. "/.hammerspoon/data"
    hs.execute("mkdir -p '" .. dataDir .. "'")
end

-- Helper function to convert geometry object to plain table
local function geometryToTable(geom)
    if not geom then return nil end
    return {
        x = geom.x,
        y = geom.y,
        w = geom.w,
        h = geom.h
    }
end

-- Helper function to convert plain table to geometry object
local function tableToGeometry(tbl)
    if not tbl then return nil end
    return hs.geometry.rect(tbl.x, tbl.y, tbl.w, tbl.h)
end

-- Helper function to convert locations table to serializable format
local function prepareLocationsForSaving(locations)
    local serializable = {}
    for windowId, frame in pairs(locations) do
        serializable[windowId] = geometryToTable(frame)
    end
    return serializable
end

-- Helper function to convert loaded locations back to geometry objects
local function prepareLocationsAfterLoading(locations)
    local withGeometry = {}
    for windowId, frameTable in pairs(locations) do
        withGeometry[windowId] = tableToGeometry(frameTable)
    end
    return withGeometry
end
-- Save locations to persistent storage
local function saveLocations()
    ensureDataDirectory()

    local data = {
        location1 = prepareLocationsForSaving(WindowToggler.location1),
        location2 = prepareLocationsForSaving(WindowToggler.location2),
        savedAt = os.time()
    }

    local success, result = pcall(function()
        local jsonString = hs.json.encode(data)
        local file = io.open(LOCATIONS_FILE, "w")
        if file then
            file:write(jsonString)
            file:close()
            return true
        end
        return false
    end)

    if success and result then
        log:d('Window locations saved to:', LOCATIONS_FILE)
    else
        log:e('Failed to save window locations:', result)
    end
end

-- Load locations from persistent storage
local function loadLocations()
    local success, result = pcall(function()
        local file = io.open(LOCATIONS_FILE, "r")
        if not file then
            return nil
        end

        local jsonString = file:read("*all")
        file:close()

        if jsonString and jsonString ~= "" then
            return hs.json.decode(jsonString)
        end
        return nil
    end)

    if success and result then
        -- Restore the locations, converting back to geometry objects
        WindowToggler.location1 = prepareLocationsAfterLoading(result.location1 or {})
        WindowToggler.location2 = prepareLocationsAfterLoading(result.location2 or {})

        local loc1Count = 0
        local loc2Count = 0
        for _ in pairs(WindowToggler.location1) do loc1Count = loc1Count + 1 end
        for _ in pairs(WindowToggler.location2) do loc2Count = loc2Count + 1 end

        log:i('Loaded window locations - Location 1:', loc1Count, 'Location 2:', loc2Count)
    else
        log:d('No saved window locations found or failed to load')
        WindowToggler.location1 = {}
        WindowToggler.location2 = {}
    end
end

-- Helper function to get unique window identifier
local function getWindowIdentifier(win)
    if not win then return nil end
    local app = win:application()
    local appName = app and app:name() or "Unknown"
    local title = win:title() or "Untitled"
    return appName .. ":" .. title
end

-- Helper function to get or select a window
local function getTargetWindow(callback)
    local win = hs.window.focusedWindow()
    if win then
        callback(win)
        return
    end

    -- No focused window, show window picker
    local allWindows = hs.window.allWindows()
    local visibleWindows = {}

    for _, w in ipairs(allWindows) do
        if w:isVisible() and w:isStandard() then
            local app = w:application()
            local appName = app and app:name() or "Unknown"
            local title = w:title() or "Untitled"
            table.insert(visibleWindows, {
                window = w,
                text = appName .. " - " .. title,
                subText = "App: " .. appName
            })
        end
    end

    if #visibleWindows == 0 then
        hs.alert.show("No available windows found")
        return
    end

    local chooser = hs.chooser.new(function(choice)
        if choice and choice.window then
            callback(choice.window)
        end
    end)

    chooser:placeholderText("Select a window...")
    chooser:choices(visibleWindows)
    chooser:show()
end

-- Toggle a window between Location 1 and Location 2
function WindowToggler.toggleWindowPosition()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        local currentFrame = win:frame()
        local app = win:application()
        local appName = app and app:name() or "Unknown"

        local hasLocation1 = WindowToggler.location1[windowId] ~= nil
        local hasLocation2 = WindowToggler.location2[windowId] ~= nil

        -- Helper function to check if current position matches a saved location (within tolerance)
        local function positionMatches(savedFrame, tolerance)
            if not savedFrame then return false end
            tolerance = tolerance or 10
            return math.abs(currentFrame.x - savedFrame.x) < tolerance and
                math.abs(currentFrame.y - savedFrame.y) < tolerance and
                math.abs(currentFrame.w - savedFrame.w) < tolerance and
                math.abs(currentFrame.h - savedFrame.h) < tolerance
        end

        -- Determine toggle behavior based on current position and available locations
        if hasLocation1 and hasLocation2 then
            -- Both locations exist - cycle between them
            if positionMatches(WindowToggler.location1[windowId]) then
                -- Currently at Location 1, move to Location 2
                WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location2[windowId])
                log:i('Toggled from Location 1 to Location 2 for window:', windowId)
                hs.alert.show(appName .. ": Location 1 → Location 2")
            elseif positionMatches(WindowToggler.location2[windowId]) then
                -- Currently at Location 2, move to Location 1
                WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location1[windowId])
                log:i('Toggled from Location 2 to Location 1 for window:', windowId)
                hs.alert.show(appName .. ": Location 2 → Location 1")
            else
                -- Not at either location, go to Location 1 by default
                WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location1[windowId])
                log:i('Moved to Location 1 from unknown position for window:', windowId)
                hs.alert.show(appName .. ": → Location 1")
            end
        elseif hasLocation1 then
            -- Only Location 1 exists
            if positionMatches(WindowToggler.location1[windowId]) then
                -- Currently at Location 1, save current position as Location 2 and move there
                WindowToggler.location2[windowId] = currentFrame
                saveLocations()
                hs.alert.show(appName .. ": Saved current position as Location 2")
                log:i('Saved current position as Location 2 for window:', windowId)
            else
                -- Not at Location 1, move to Location 1
                WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location1[windowId])
                log:i('Moved to Location 1 for window:', windowId)
                hs.alert.show(appName .. ": → Location 1")
            end
        elseif hasLocation2 then
            -- Only Location 2 exists
            if positionMatches(WindowToggler.location2[windowId]) then
                -- Currently at Location 2, save current position as Location 1 and move there
                WindowToggler.location1[windowId] = currentFrame
                saveLocations()
                hs.alert.show(appName .. ": Saved current position as Location 1")
                log:i('Saved current position as Location 1 for window:', windowId)
            else
                -- Not at Location 2, move to Location 2
                WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location2[windowId])
                log:i('Moved to Location 2 for window:', windowId)
                hs.alert.show(appName .. ": → Location 2")
            end
        else
            -- No saved locations exist, save current position as Location 1
            WindowToggler.location1[windowId] = currentFrame
            saveLocations()
            log:i('Saved current position as Location 1 for window:', windowId)
            hs.alert.show(appName .. ": Saved current position as Location 1")
        end
    end)
end

-- Save current window position to location 1
function WindowToggler.saveToLocation1()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        local currentFrame = win:frame()
        WindowToggler.location1[windowId] = currentFrame
        saveLocations() -- Persist to file
        local app = win:application()
        local appName = app and app:name() or "Unknown"
        log:i('Saved location 1 for window:', windowId)
        hs.alert.show("Saved " .. appName .. " to Location 1")
    end)
end

-- Save current window position to location 2
function WindowToggler.saveToLocation2()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        local currentFrame = win:frame()
        WindowToggler.location2[windowId] = currentFrame
        saveLocations() -- Persist to file
        local app = win:application()
        local appName = app and app:name() or "Unknown"
        log:i('Saved location 2 for window:', windowId)
        hs.alert.show("Saved " .. appName .. " to Location 2")
    end)
end

-- Restore window to location 1
function WindowToggler.restoreToLocation1()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        if WindowToggler.location1[windowId] then
            WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location1[windowId])
            local app = win:application()
            local appName = app and app:name() or "Unknown"
            log:i('Restored location 1 for window:', windowId)
            hs.alert.show("Restored " .. appName .. " to Location 1")
        else
            hs.alert.show("No saved Location 1 for this window")
        end
    end)
end

-- Restore window to location 2
function WindowToggler.restoreToLocation2()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        if WindowToggler.location2[windowId] then
            WindowManager.setFrameInScreenWithRetry(win, WindowToggler.location2[windowId])
            local app = win:application()
            local appName = app and app:name() or "Unknown"
            log:i('Restored location 2 for window:', windowId)
            hs.alert.show("Restored " .. appName .. " to Location 2")
        else
            hs.alert.show("No saved Location 2 for this window")
        end
    end)
end

-- Clear all saved positions
function WindowToggler.clearSavedPositions()
    WindowToggler.savedPositions = {}
    log:i('Cleared all saved window positions')
    hs.alert.show("Cleared all saved window positions")
end

-- Clear saved locations for a specific window or all
function WindowToggler.clearSavedLocations(clearAll)
    if clearAll then
        WindowToggler.location1 = {}
        WindowToggler.location2 = {}
        saveLocations() -- Persist to file
        log:i('Cleared all saved window locations')
        hs.alert.show("Cleared all saved locations")
    else
        getTargetWindow(function(win)
            local windowId = getWindowIdentifier(win)
            WindowToggler.location1[windowId] = nil
            WindowToggler.location2[windowId] = nil
            saveLocations() -- Persist to file
            local app = win:application()
            local appName = app and app:name() or "Unknown"
            log:i('Cleared saved locations for window:', windowId)
            hs.alert.show("Cleared locations for " .. appName)
        end)
    end
end

-- List all saved window titles and locations
function WindowToggler.listSavedWindows()
    local result = "Saved window positions:\n\n"
    local count = 0

    -- Regular toggle positions
    for windowId, _ in pairs(WindowToggler.savedPositions) do
        result = result .. "Toggle: " .. windowId .. "\n"
        count = count + 1
    end

    -- Location 1 positions
    for windowId, _ in pairs(WindowToggler.location1) do
        result = result .. "Loc 1: " .. windowId .. "\n"
        count = count + 1
    end

    -- Location 2 positions
    for windowId, _ in pairs(WindowToggler.location2) do
        result = result .. "Loc 2: " .. windowId .. "\n"
        count = count + 1
    end

    if count == 0 then
        result = "No saved window positions or locations"
    end

    log:i('Listed saved windows:', count)
    hs.alert.show(result, 4)
end

-- Show window locations menu
function WindowToggler.showLocationsMenu()
    getTargetWindow(function(win)
        local windowId = getWindowIdentifier(win)
        local app = win:application()
        local appName = app and app:name() or "Unknown"

        local hasLocation1 = WindowToggler.location1[windowId] ~= nil
        local hasLocation2 = WindowToggler.location2[windowId] ~= nil
        local hasTogglePos = WindowToggler.savedPositions[windowId] ~= nil

        local menuItems = {
            {
                text = "Save to Location 1",
                subText = hasLocation1 and "Overwrite existing" or "New location"
            },
            {
                text = "Save to Location 2",
                subText = hasLocation2 and "Overwrite existing" or "New location"
            }
        }

        if hasLocation1 then
            table.insert(menuItems, {
                text = "Restore to Location 1",
                subText = "Go to saved location 1"
            })
        end

        if hasLocation2 then
            table.insert(menuItems, {
                text = "Restore to Location 2",
                subText = "Go to saved location 2"
            })
        end

        if hasLocation1 or hasLocation2 then
            table.insert(menuItems, {
                text = "Clear This Window's Locations",
                subText = "Remove saved locations for " .. appName
            })
        end

        local chooser = hs.chooser.new(function(choice)
            if not choice then return end

            if choice.text == "Save to Location 1" then
                WindowToggler.saveToLocation1()
            elseif choice.text == "Save to Location 2" then
                WindowToggler.saveToLocation2()
            elseif choice.text == "Restore to Location 1" then
                WindowToggler.restoreToLocation1()
            elseif choice.text == "Restore to Location 2" then
                WindowToggler.restoreToLocation2()
            elseif choice.text == "Clear This Window's Locations" then
                WindowToggler.clearSavedLocations(false)
            end
        end)

        chooser:placeholderText("Window Locations for " .. appName)
        chooser:choices(menuItems)
        chooser:show()
    end)
end

-- Initialize by loading saved locations
loadLocations()
-- Save in global environment for module reuse
_G.WindowToggler = WindowToggler
return WindowToggler
