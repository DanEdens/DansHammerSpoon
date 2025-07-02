-- ====================================
-- CAPS LOCK AS HYPER KEY SETUP 🔧⚡
-- ====================================
-- Create a modal for Caps Lock (F18) - The Mad Tinker's fourth dimension of hotkeys!
-- local capsModal = hs.hotkey.modal.new({}, 'F17')

-- -- Enter Caps Mode when F18 (remapped Caps Lock) is pressed
-- function enterCapsMode()
--     capsModal.triggered = false
--     capsModal:enter()
--     log:d('Entered Caps Lock Hyper Mode - The fourth dimension awaits!', __FILE__, 50)
-- end

-- -- Exit Caps Mode when F18 is released
-- -- If no other keys were pressed, send ESCAPE (handy for vim users!)
-- function exitCapsMode()
--     capsModal:exit()
--     if not capsModal.triggered then
--         hs.eventtap.keyStroke({}, 'ESCAPE')
--         log:d('Caps Lock released alone - sending ESCAPE', __FILE__, 58)
--     else
--         log:d('Exited Caps Lock Hyper Mode', __FILE__, 60)
--     end
-- end

-- -- Bind F18 (remapped Caps Lock) to enter/exit Caps Mode
-- local f18Hotkey = hs.hotkey.bind({}, 'F18', enterCapsMode, exitCapsMode)

-- -- Helper function to bind Caps Lock hotkeys
-- local function bindCapsKey(key, description, func)
--     capsModal:bind({}, key, description, function()
--         capsModal.triggered = true
--         func()
--     end)
-- end

-- ====================================
-- CAPS LOCK HOTKEY BINDINGS 🚀
-- ====================================
-- The Mad Tinker's Fourth Dimension of Hotkeys!

-- -- Quick App Launchers (Caps + Letter)
-- bindCapsKey("c", "Open Calculator", function()
--     hs.application.launchOrFocus("Calculator")
--     hs.alert.show("📊 Calculator", 1)
-- end)

-- bindCapsKey("v", "Open VS Code", function()
--     hs.application.launchOrFocus("Visual Studio Code")
--     hs.alert.show("💻 VS Code", 1)
-- end)

-- bindCapsKey("n", "Open Notes", function()
--     hs.application.launchOrFocus("Notes")
--     hs.alert.show("📝 Notes", 1)
-- end)

-- bindCapsKey("r", "Open Activity Monitor", function()
--     hs.application.launchOrFocus("Activity Monitor")
--     hs.alert.show("📈 Activity Monitor", 1)
-- end)

-- -- System Controls (Caps + Function Keys)
-- bindCapsKey("F1", "Show Desktop", function()
--     hs.spaces.toggleShowDesktop()
--     hs.alert.show("🖥️ Desktop", 1)
-- end)

-- bindCapsKey("F2", "Mission Control", function()
--     hs.spaces.toggleMissionControl()
--     hs.alert.show("🚀 Mission Control", 1)
-- end)

-- bindCapsKey("F3", "Launchpad", function()
--     hs.application.launchOrFocus("Launchpad")
--     hs.alert.show("🎯 Launchpad", 1)
-- end)

-- -- Window Management (Caps + Arrow Keys)
-- bindCapsKey("left", "Move Window Left Quarter", function()
--     WindowManager.applyLayout("leftQuarter")
--     hs.alert.show("⬅️ Left Quarter", 1)
-- end)

-- bindCapsKey("right", "Move Window Right Quarter", function()
--     WindowManager.applyLayout("rightQuarter")
--     hs.alert.show("➡️ Right Quarter", 1)
-- end)

-- bindCapsKey("up", "Move Window Top Half", function()
--     WindowManager.applyLayout("topHalf")
--     hs.alert.show("⬆️ Top Half", 1)
-- end)

-- bindCapsKey("down", "Move Window Bottom Third", function()
--     WindowManager.applyLayout("bottomThird")
--     hs.alert.show("⬇️ Bottom Third", 1)
-- end)

-- -- Utility Functions (Caps + Numbers)
-- bindCapsKey("1", "Toggle WiFi", function()
--     -- This would need a WiFi toggle function
--     hs.alert.show("📶 WiFi Toggle", 1)
--     log:i('WiFi toggle requested via Caps Lock', __FILE__, 125)
-- end)

-- bindCapsKey("2", "Toggle Bluetooth", function()
--     -- This would need a Bluetooth toggle function
--     hs.alert.show("🔵 Bluetooth Toggle", 1)
--     log:i('Bluetooth toggle requested via Caps Lock', __FILE__, 130)
-- end)

-- bindCapsKey("3", "Toggle Do Not Disturb", function()
--     AppManager.toggle_do_not_disturb()
--     hs.alert.show("🔕 Do Not Disturb", 1)
-- end)

-- -- Mad Tinker Special Functions (Caps + Special Keys)
-- bindCapsKey("space", "Show All Hotkeys", function()
--     -- Show a comprehensive hotkey list including Caps Lock hotkeys
--     HotkeyManager.showAllHotkeys()
--     hs.alert.show("🔧 All Hotkeys", 2)
-- end)

-- bindCapsKey("tab", "Cycle Through Apps", function()
--     hs.application.launchOrFocus("Mission Control")
--     hs.alert.show("🔄 App Cycle", 1)
-- end)

-- bindCapsKey("escape", "Lock Screen", function()
--     hs.caffeinate.lockScreen()
--     hs.alert.show("🔒 Screen Locked", 1)
-- end)

-- -- Fun Mad Tinker Features
-- bindCapsKey("m", "Toggle Madness Mode", function()
--     -- This could toggle some special visual effects or modes
--     hs.alert.show("🎪 MADNESS MODE ENGAGED! 🔧⚡", 3)
--     log:i('MADNESS MODE TOGGLED!', __FILE__, 155)
-- end)
