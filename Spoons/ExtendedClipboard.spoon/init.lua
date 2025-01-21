--- === ExtendedClipboard ===
---
--- Enhanced clipboard capabilities with numbered registers, history, and device sharing
---
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ExtendedClipboard"
obj.version = "0.2.0"
obj.author = "<d.edens@email>"
obj.homepage = ""
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Configuration
obj.config = {
    max_history = 100,
    log_path = os.getenv("HOME") .. "/cliplog.txt",
    history_path = os.getenv("HOME") .. "/.hammerspoon/clipboard_history.json",
    editor = "Visual Studio Code"
}

-- State
obj.history = {}
local json = require("hs.json")

-- Helper Functions
local function saveToRegister(number)
    return function()
        local content = hs.pasteboard.getContents()
        if not content then return end

        _G["clip" .. number] = content
        hs.alert.show(string.format("%d - %s", number, content:sub(1, 50)))
        hs.execute(string.format("rost vars/clip%d %s", number, content))

        -- Add to history
        table.insert(obj.history, 1, {
            content = content,
            timestamp = os.time(),
            register = number
        })

        -- Trim history if needed
        if #obj.history > obj.config.max_history then
            table.remove(obj.history)
        end

        -- Save history to file
        local f = io.open(obj.config.history_path, "w")
        if f then
            f:write(json.encode(obj.history))
            f:close()
        end
    end
end

local function pasteFromRegister(number)
    return function()
        local content = _G["clip" .. number]
        if content then
            hs.alert.show(string.format("%d - %s", number, content:sub(1, 50)))
            hs.pasteboard.setContents(content)
        end
    end
end

function obj:init()
    -- Load history from file
    local f = io.open(self.config.history_path, "r")
    if f then
        local content = f:read("*all")
        f:close()
        if content then
            self.history = json.decode(content) or {}
        end
    end

    -- Bind hotkeys
    for i = 0, 9 do
        hs.hotkey.bind(_alt, tostring(i), saveToRegister(i))
        hs.hotkey.bind(_alt_ctrl, tostring(i), pasteFromRegister(i))
    end

    -- Additional hotkeys
    hs.hotkey.bind(_alt, "V", function() self:toggleClipboard() end)
    hs.hotkey.bind(_alt, "C", function() self:saveClipboard() end)
    hs.hotkey.bind(_hyper, "C", function() self:openAndCleanLog() end)
    hs.hotkey.bind(hammer, "H", function() self:clearHistory() end)

    return self
end

function obj:saveClipboard()
    local content = hs.pasteboard.getContents()
    if not content then return end

    local f = io.open(self.config.log_path, "a")
    if not f then
        hs.alert.show("Failed to open clipboard log!")
        return
    end

    -- Write structured log entry
    local entry = string.format([[
[%s]
Content: %s
Length: %d
Type: %s
-------------------
]], os.date("%Y-%m-%d %H:%M:%S"), content, #content, type(content))

    f:write(entry)
    f:close()
    hs.alert.show("Clipboard saved to log")
end

function obj:cleanCliplog()
    local f = io.open(self.config.log_path, "r")
    if not f then return end

    local seen = {}
    local entries = {}
    local current_entry = {}

    for line in f:lines() do
        if line:match("^%[%d") then  -- New entry starts
            if #current_entry > 0 then
                local entry_text = table.concat(current_entry, "\n")
                if not seen[entry_text] then
                    seen[entry_text] = true
                    table.insert(entries, entry_text)
                end
                current_entry = {}
            end
        end
        table.insert(current_entry, line)
    end

    f:close()

    -- Write cleaned entries back
    f = io.open(self.config.log_path, "w")
    if f then
        f:write(table.concat(entries, "\n\n"))
        f:close()
    end
end

function obj:clearHistory()
    -- Clear registers
    for i = 0, 9 do
        _G["clip" .. i] = nil
    end

    -- Clear history
    self.history = {}
    os.remove(self.config.history_path)

    hs.alert.show("Clipboard history cleared!")
end

function obj:openAndCleanLog()
    self:cleanCliplog()
    hs.execute(string.format("open -a '%s' '%s'", self.config.editor, self.config.log_path))
end

function obj:toggleClipboard()
    -- Show clipboard history chooser
    local choices = {}
    for i, entry in ipairs(self.history) do
        table.insert(choices, {
            text = entry.content:sub(1, 50),
            subText = os.date("%Y-%m-%d %H:%M:%S", entry.timestamp),
            content = entry.content
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            hs.pasteboard.setContents(choice.content)
        end
    end)

    chooser:choices(choices)
    chooser:show()
end

return obj
