-- spoon.SpoonInstall:andUse("HSKeybindings")

-- hs.loadSpoon("SpoonInstall")
-- Bind hotkeys for HSKeybindings Spoon
-- hs.loadSpoon("HSKeybindings")
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
--     spoon.HSKeybindings:show()
-- end)

-- hs.alert.show("Config loaded")

-- local notRunning = { "app1", "app2", "app3" }  -- Replace with actual applications or scripts

-- -- Function to print messages
-- local function printMessage(message)
--     print(message)
-- end

-- -- Function to execute a command
-- local function executePsCommand(command)
--     -- Adapt this to the actual system command format you need
--     hs.execute("powershell.exe Start-Process " .. command)
--     hs.timer.usleep(1000000) -- Wait for 1 second
-- end

-- -- Function to simulate the event check
-- local function checkRunning(eventSuffix)
--     if eventSuffix == "Launch all" then
--         for _, app in ipairs(notRunning) do
--             printMessage("Launching: " .. app .. "...")
--             executePsCommand(app)
--         end
--     else
--         printMessage("Launching: " .. eventSuffix .. "...")
--         executePsCommand(eventSuffix)
--     end
-- end

-- -- Example usage
-- checkRunning("Launch all") -- Or replace with another event suffix



-- hs.notify.new({title="Clipboard", informativeText="Resetting Clipboard"}):send()
-- hs.timer.doAfter(1, fixClipboard)