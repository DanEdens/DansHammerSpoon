# temp

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")



hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    hs.alert.show("Hello World!")
  end)
  
 
hs.hotkey.bind({"alt"}, "1", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip1 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("1 - " .. clipboardContent)
    
    -- publish clipboard content to MQTT
    -- hs.execute("mosquitto_pub -h
    
    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip1 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "2", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip2 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("2 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip2 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "3", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip3 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("3 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip3 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "4", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip4 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("4 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip4 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "5", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip5 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("5 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip5 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "6", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip6 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("6 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip6 " .. clipboardContent)
end)



hs.hotkey.bind({"alt"}, "7", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip7 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("7 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip7 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "8", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip8 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("8 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip8 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "9", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip9 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("9 - " .. clipboardContent)

    --Execute a system command with the clipboard content
    hs.execute("rost vars/clip9 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "0", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()

    --Store the clipboard content in a global variable
    _G.clip0 = clipboardContent

    --Display OSD (On-Screen Display). Replace with a suitable notification method if needed
    hs.alert.show("0 - " .. clipboardContent)

    --Execute a system command with the clipboard content

    hs.execute("rost vars/clip0 " .. clipboardContent)
end)


hs.hotkey.bind({"alt", "ctrl"}, "1", function()
    hs.alert.show("1 - " .. _G.clip1)
    hs.pasteboard.setContents(_G.clip1)
end)

hs.hotkey.bind({"alt", "ctrl"}, "2", function()
    hs.alert.show("2 - " .. _G.clip2)
    hs.pasteboard.setContents(_G.clip2)
end)

hs.hotkey.bind({"alt", "ctrl"}, "3", function()
    hs.alert.show("3 - " .. _G.clip3)
    hs.pasteboard.setContents(_G.clip3)
end)

hs.hotkey.bind({"alt", "ctrl"}, "4", function()
    hs.alert.show("4 - " .. _G.clip4)
    hs.pasteboard.setContents(_G.clip4)
end)

hs.hotkey.bind({"alt", "ctrl"}, "5", function()
    hs.alert.show("5 - " .. _G.clip5)
    hs.pasteboard.setContents(_G.clip5)
end)

hs.hotkey.bind({"alt", "ctrl"}, "6", function()
    hs.alert.show("6 - " .. _G.clip6)
    hs.pasteboard.setContents(_G.clip6)
end)

hs.hotkey.bind({"alt", "ctrl"}, "7", function()
    hs.alert.show("7 - " .. _G.clip7)
    hs.pasteboard.setContents(_G.clip7)
end)

hs.hotkey.bind({"alt", "ctrl"}, "8", function()
    hs.alert.show("8 - " .. _G.clip8)
    hs.pasteboard.setContents(_G.clip8)
end)

hs.hotkey.bind({"alt", "ctrl"}, "9", function()
    hs.alert.show("9 - " .. _G.clip9)
    hs.pasteboard.setContents(_G.clip9)
end)

hs.hotkey.bind({"alt", "ctrl"}, "0", function()
    hs.alert.show("0 - " .. _G.clip0)
    hs.pasteboard.setContents(_G.clip0)
end)

hs.hotkey.bind({"alt", "ctrl"}, "R", function()
    hs.reload()
end)

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
