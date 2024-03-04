

hammer = {"cmd","ctrl","alt"}
hyper = {"cmd","shift","ctrl","alt"}

-- Initialize counter
local counter = 0

-- Gap between windows
local gap = 10
local cols = 5

-- Function to calculate position based on counter
local function calculatePosition(counter, max, rows)
    local row = math.floor(counter / cols)
    local col = counter % cols
    
    local x = max.x + (col * (max.w / cols + gap))
    local y = max.y + (row * (max.h / rows + gap))

    return x, y
end

-- Layouts Menu
spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()


-- 0 make tiny for storage 
hs.hotkey.bind(hammer, "0", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    -- Number of rows
    local rows = 2  -- Change this value to adjust the number of rows

    -- Calculate position based on counter and number of rows
    local x, y = calculatePosition(counter, max, rows)

    -- Update frame
    f.x = x
    f.y = y
    f.w = max.w / 5 - 2 * gap
    f.h = max.h / rows - 2 * gap
    win:setFrame(f)

    -- Increment counter (and wrap around)
    counter = (counter + 1) % (rows * cols)
end)


-- Aclock Show
hs.hotkey.bind(hyper, "W", function()
    spoon.AClock:toggleShow()
end)

-- Reload HammerSpoon
hs.hotkey.bind(hammer, "F5", function()
    hs.reload()
end)

-- Toggle HammerSpoon Console
hs.hotkey.bind(hammer, "F1", function()
    hs.toggleConsole()
end)

-- ctrl + cmd + alt + ` to switch to vs code
hs.hotkey.bind(hammer, "`", function()
    hs.application.launchOrFocus("Visual Studio Code")
end)

-- hammer P for pycharm
hs.hotkey.bind(hammer, "p", function()
    hs.application.launchOrFocus("PyCharm Community Edition")
end)

-- l for Logi Options+
hs.hotkey.bind(hammer, "l", function()
    hs.application.launchOrFocus("Logi Options")
end)

hs.hotkey.bind({"alt", "ctrl"}, "Tab", function()
    hs.application.launchOrFocus("Mission Control.app")
end)

-- Hammer 1 - left half
hs.hotkey.bind(hammer, "1", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- hyper 1 - left corner
hs.hotkey.bind(hyper, "1", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end)

-- Hammer 2 - right half
hs.hotkey.bind(hammer, "2", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h
    win:setFrame(f)
end)

-- hyper 2 - right corner
hs.hotkey.bind(hyper, "2", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end)

-- Hammer 3 - full screen
hs.hotkey.bind(hammer, "3", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end)

-- 4 -- 95% full screen centered
hs.hotkey.bind(hammer, "4", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.025)
    f.y = max.y + (max.h * 0.025)
    f.w = max.w * 0.95
    f.h = max.h * 0.95
    win:setFrame(f)
end)

-- 5 -- 80% full screen centered
hs.hotkey.bind(hammer, "5", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.1)
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.8
    f.h = max.h * 0.8
    win:setFrame(f)
end)

-- 6 smaller left side
hs.hotkey.bind(hammer, "6", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    
    f.x = max.x
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.4
    f.h = max.h * 0.8
    win:setFrame(f)
end)

-- 7 smaller right side
hs.hotkey.bind(hammer, "7", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.6)
    f.y = max.y + (max.h * 0.1)
    f.w = max.w * 0.4
    f.h = max.h * 0.8
    win:setFrame(f)
end)

-- 9 move focused window to cursor as top left corner  
hs.hotkey.bind(hammer, "8", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()

    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
end)

--move focused window to mouse as center
hs.hotkey.bind(hammer, "9", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()

    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    win:setFrame(f)
end)



-- hammer - flash list of window movement options 1-9 
hs.hotkey.bind(hammer, "-", function()
    hs.alert.show("\
    1: Full Left half <<< \
    2: Ful Right half >>> \
    3: Full Screen, \
    4: 95% full screen, \
    5: 80% full screen, \
    6: 40% right, \
    7: 40% left, \
    8: move to mouse, \
    9: move corner to cursor \
    -: print options")
end)