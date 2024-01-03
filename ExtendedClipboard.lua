
hs.hotkey.bind({"alt"}, "1", function()
    --  Get Clipboard contents.
    local clipboardContent = hs.pasteboard.getContents()
    
    --Store the clipboard content in a global variable
    _G.clip1 = clipboardContent
    
    --Display OSD (On-Screen Display). 
    hs.alert.show("1 - " .. clipboardContent)
    
    -- Set topic var with rost
    hs.execute("rost vars/clip1 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "2", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip2 = clipboardContent
    hs.alert.show("2 - " .. clipboardContent)
    hs.execute("rost vars/clip2 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "3", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip3 = clipboardContent
    hs.alert.show("3 - " .. clipboardContent)
    hs.execute("rost vars/clip3 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "4", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip4 = clipboardContent
    hs.alert.show("4 - " .. clipboardContent)
    hs.execute("rost vars/clip4 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "5", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip5 = clipboardContent
    hs.alert.show("5 - " .. clipboardContent)
    hs.execute("rost vars/clip5 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "6", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip6 = clipboardContent
    hs.alert.show("6 - " .. clipboardContent)
    hs.execute("rost vars/clip6 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "7", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip7 = clipboardContent
    hs.alert.show("7 - " .. clipboardContent)
    hs.execute("rost vars/clip7 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "8", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip8 = clipboardContent
    hs.alert.show("8 - " .. clipboardContent)
    hs.execute("rost vars/clip8 " .. clipboardContent)
end)


hs.hotkey.bind({"alt"}, "9", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip9 = clipboardContent
    hs.alert.show("9 - " .. clipboardContent)
    hs.execute("rost vars/clip9 " .. clipboardContent)
end)

hs.hotkey.bind({"alt"}, "0", function()
    local clipboardContent = hs.pasteboard.getContents()
    _G.clip0 = clipboardContent
    hs.alert.show("0 - " .. clipboardContent)
    hs.execute("rost vars/clip0 " .. clipboardContent)
end)

-- Paste Hotkeys
hs.hotkey.bind({"alt", "ctrl"}, "1", function()
    -- Flash clip1 contents on screen
    hs.alert.show("1 - " .. _G.clip1)
    -- Set clip1 contents to clipboard
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

