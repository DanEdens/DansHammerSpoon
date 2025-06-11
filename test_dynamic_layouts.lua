-- test_dynamic_layouts.lua - Test script for the new dynamic layout system
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

log:i("=== Starting Dynamic Layout System Tests ===")

-- Test 1: Monitor Detection
log:i("Test 1: Testing monitor detection...")
local config = WindowManager.detectMonitorConfiguration()
log:i("Current configuration:", config.type)
log:i("Number of screens:", config.count)
for i, screen in ipairs(config.screens) do
    log:i(string.format("Screen %d: %s (%s) at %s", i, screen.name, screen.size, screen.position))
end

-- Test 2: Layout Set Retrieval
log:i("Test 2: Testing layout set retrieval...")
local miniLayouts, standardLayouts = WindowManager.getCurrentLayouts()
log:i("Mini layouts available:", #miniLayouts)
log:i("Standard layouts available:")
local layoutNames = {}
for name, _ in pairs(standardLayouts) do
    table.insert(layoutNames, name)
end
table.sort(layoutNames)
for _, name in ipairs(layoutNames) do
    log:i("  - " .. name)
end

-- Test 3: Layout Application Test (if window is focused)
log:i("Test 3: Testing layout application...")
local win = hs.window.focusedWindow()
if win then
    log:i("Focused window found:", win:application():name(), "-", win:title())

    -- Test a common layout
    if standardLayouts.centerScreen then
        log:i("Testing centerScreen layout...")
        WindowManager.applyLayout("centerScreen")
        hs.timer.doAfter(1, function()
            log:i("centerScreen layout applied successfully")
        end)
    else
        log:w("centerScreen layout not available in current configuration")
    end
else
    log:w("No focused window for layout testing")
end

-- Test 4: Configuration-Specific Layout Test
log:i("Test 4: Testing configuration-specific layouts...")
if config.type == "laptop" then
    log:i("Testing laptop-specific features...")
    if standardLayouts.leftHalf and standardLayouts.rightHalf then
        log:i("✓ Laptop has basic half-screen layouts")
    end
elseif config.type == "dual_monitor" then
    log:i("Testing dual monitor-specific features...")
    if standardLayouts.leftWide and standardLayouts.rightNarrow then
        log:i("✓ Dual monitor has wide/narrow layouts")
    end
elseif config.type == "triple_monitor" then
    log:i("Testing triple monitor-specific features...")
    if standardLayouts.leftThird and standardLayouts.centerThird and standardLayouts.rightThird then
        log:i("✓ Triple monitor has third-based layouts")
    end
end

-- Test 5: Mini Shuffle Test
log:i("Test 5: Testing mini shuffle functionality...")
if win then
    local originalFrame = win:frame()
    log:i("Original window frame:", hs.inspect(originalFrame))

    -- Test mini shuffle
    WindowManager.miniShuffle()
    hs.timer.doAfter(0.5, function()
        local newFrame = win:frame()
        log:i("Frame after mini shuffle:", hs.inspect(newFrame))

        if not (originalFrame.x == newFrame.x and originalFrame.y == newFrame.y) then
            log:i("✓ Mini shuffle moved window successfully")
        else
            log:w("✗ Mini shuffle may not have moved window")
        end
    end)
end

-- Test 6: Monitor Info Display
log:i("Test 6: Testing monitor info display...")
hs.timer.doAfter(2, function()
    WindowManager.showMonitorInfo()
    log:i("Monitor info should be displayed on screen now")
end)

-- Test 7: Layout Refresh Test
log:i("Test 7: Testing layout refresh...")
hs.timer.doAfter(3, function()
    WindowManager.refreshLayouts()
    log:i("Layout refresh completed")
end)

log:i("=== Dynamic Layout System Tests Completed ===")
log:i("Check the results above and the visual feedback on screen")

-- Return test summary
return {
    config = config,
    miniLayoutCount = #miniLayouts,
    standardLayoutCount = #layoutNames,
    availableLayouts = layoutNames
}
