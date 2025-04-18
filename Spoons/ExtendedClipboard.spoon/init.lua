--- === ExtendedClipboard ===
---
--- This adds additional Clipboard capablities like 1-10 register, history, and mqtt based device sharing
---
--- Download:
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ExtendedClipboard"
obj.version = "0.1.1"
obj.author = "<d.edens@email>"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- ExtendedClipboard:helloWorld()

-- hs.hotkey.bind({"alt"}, "1", function()
--     --  Get Clipboard contents.
--     local clipboardContent = hs.pasteboard.getContents()

--     --Store the clipboard content in a global variable
--     _G.clip1 = clipboardContent

--     --Display OSD (On-Screen Display).
--     hs.alert.show("1 - " .. clipboardContent)

--     -- Set topic var with rost
--     hs.execute("rost vars/clip1 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "2", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip2 = clipboardContent
--     hs.alert.show("2 - " .. clipboardContent)
--     hs.execute("rost vars/clip2 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "3", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip3 = clipboardContent
--     hs.alert.show("3 - " .. clipboardContent)
--     hs.execute("rost vars/clip3 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "4", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip4 = clipboardContent
--     hs.alert.show("4 - " .. clipboardContent)
--     hs.execute("rost vars/clip4 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "5", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip5 = clipboardContent
--     hs.alert.show("5 - " .. clipboardContent)
--     hs.execute("rost vars/clip5 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "6", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip6 = clipboardContent
--     hs.alert.show("6 - " .. clipboardContent)
--     hs.execute("rost vars/clip6 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "7", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip7 = clipboardContent
--     hs.alert.show("7 - " .. clipboardContent)
--     hs.execute("rost vars/clip7 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "8", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip8 = clipboardContent
--     hs.alert.show("8 - " .. clipboardContent)
--     hs.execute("rost vars/clip8 " .. clipboardContent)
-- end)


-- hs.hotkey.bind({"alt"}, "9", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip9 = clipboardContent
--     hs.alert.show("9 - " .. clipboardContent)
--     hs.execute("rost vars/clip9 " .. clipboardContent)
-- end)

-- hs.hotkey.bind({"alt"}, "0", function()
--     local clipboardContent = hs.pasteboard.getContents()
--     _G.clip0 = clipboardContent
--     hs.alert.show("0 - " .. clipboardContent)
--     hs.execute("rost vars/clip0 " .. clipboardContent)
-- end)

-- -- Paste Hotkeys
-- hs.hotkey.bind({"alt", "ctrl"}, "1", function()
--     -- Flash clip1 contents on screen
--     hs.alert.show("1 - " .. _G.clip1)
--     -- Set clip1 contents to clipboard
--     hs.pasteboard.setContents(_G.clip1)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "2", function()
--     hs.alert.show("2 - " .. _G.clip2)
--     hs.pasteboard.setContents(_G.clip2)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "3", function()
--     hs.alert.show("3 - " .. _G.clip3)
--     hs.pasteboard.setContents(_G.clip3)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "4", function()
--     hs.alert.show("4 - " .. _G.clip4)
--     hs.pasteboard.setContents(_G.clip4)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "5", function()
--     hs.alert.show("5 - " .. _G.clip5)
--     hs.pasteboard.setContents(_G.clip5)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "6", function()
--     hs.alert.show("6 - " .. _G.clip6)
--     hs.pasteboard.setContents(_G.clip6)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "7", function()
--     hs.alert.show("7 - " .. _G.clip7)
--     hs.pasteboard.setContents(_G.clip7)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "8", function()
--     hs.alert.show("8 - " .. _G.clip8)
--     hs.pasteboard.setContents(_G.clip8)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "9", function()
--     hs.alert.show("9 - " .. _G.clip9)
--     hs.pasteboard.setContents(_G.clip9)
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "0", function()
--     hs.alert.show("0 - " .. _G.clip0)
--     hs.pasteboard.setContents(_G.clip0)
-- end)

-- function saveClipboard()
--     -- Write Clipboard to cliplog file
--     local clipboardContent = hs.pasteboard.getContents()
--     local cliplog = io.open(os.getenv("HOME") .. "/cliplog.txt", "a")
--     -- add log entry
--     cliplog:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. clipboardContent .. "\n")
--     cliplog:write(clipboardContent .. "\n")
--     cliplog:close()
-- end

-- function cleanCliplog()
--     -- Clean cliplog file
--     local cliplog = io.open(os.getenv("HOME") .. "/cliplog.txt", "r")
--     local lines = {}

--     -- Read each line and remove duplicates
--     for line in cliplog:lines() do
--         if not lines[line] then
--             lines[line] = true
--         end
--     end

--     cliplog:close()

--     -- Write cleaned contents back to the file
--     cliplog = io.open(os.getenv("HOME") .. "/cliplog.txt", "w")
--     for line, _ in pairs(lines) do
--         cliplog:write(line .. "\n")
--     end

--     cliplog:close()
-- end

-- hs.hotkey.bind({"alt"}, "V", function()
--     spoon.ClipboardTool:toggleClipboard()
-- end)

-- hs.hotkey.bind({"alt"}, "C", function()
--     saveClipboard()
-- end)

-- hs.hotkey.bind({"ctrl","alt"}, "C", function()
--     hs.execute("open -a 'Visual Studio Code' " .. os.getenv("HOME") .. "/cliplog.txt")
-- end)

-- hs.hotkey.bind({"ctrl","alt","cmd"}, "C", function()
--     cleanCliplog()
-- end)

-- hs.hotkey.bind({"ctrl","alt","cmd","shift"}, "C", function()
--     hs.execute("open -a 'Visual Studio Code' " .. os.getenv("HOME") .. "/cliplog.txt")
--     cleanCliplog()
-- end)
-- function obj:helloWorld(name)
--   print(string.format('Hello %s from %s', name, self.name))
-- end

-- return obj



--local clipLogger
--
--function toggleClipLogger()
--    if clipLogger then
--        clipLogger:stop()
--        clipLogger = nil
--    else
--        clipLogger = hs.eventtap.new({ hs.eventtap.event.types.typesChanged }, function(event)
--            local clipboard = hs.pasteboard.getContents()
--            if clipboard then
--                local file = io.open(os.getenv("HOME") .. "/cliplog.txt", "a")
--                file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. clipboard .. "\n")
--                file:close()
--            end
--        end)
--        clipLogger:start()
--    end
--end
--
