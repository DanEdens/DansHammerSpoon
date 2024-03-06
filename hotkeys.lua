

hammer = {"cmd","ctrl","alt"}
_hyper = {"cmd","shift","ctrl","alt"}
-- local editor = "Visual Studio Code"
-- local editor = "PyCharm Community Edition"
local editor = "Fleet"

-- Initialize counter
local counter = 0

-- Gap between windows
local gap = 5
local cols = 4

-- Function to calculate position based on counter
local function calculatePosition(counter, max, rows)
    local row = math.floor(counter / cols)
    local col = counter % cols
    
    local x = max.x + (col * (max.w / cols + gap))
    local y = max.y + (row * (max.h / rows + gap))

    return x, y
end


local hotkey = require "hs.hotkey"
local window = require "hs.window"
local spaces = require "hs.spaces"

function getGoodFocusedWindow(nofull)
   local win = window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end 

function flashScreen(screen)
   local flash=hs.canvas.new(screen:fullFrame()):appendElements({
	 action = "fill",
	 fillColor = { alpha = 0.25, red=1},
	 type = "rectangle"})
   flash:show()
   hs.timer.doAfter(.15,function () flash:delete() end)
end 

function switchSpace(skip,dir)
   for i=1,skip do
      hs.eventtap.keyStroke({"ctrl","cmd", "shift"}, dir, 0) -- "fn" is a bugfix!
   end 
end

function moveWindowOneSpace(dir,switch)
   local win = getGoodFocusedWindow(true)
   if not win then return end
   local screen=win:screen()
   local uuid=screen:getUUID()
   local userSpaces=nil
   for k,v in pairs(spaces.allSpaces()) do
      userSpaces=v
      if k==uuid then break end
   end
   if not userSpaces then return end
   local thisSpace=spaces.windowSpaces(win) -- first space win appears on
   if not thisSpace then return else thisSpace=thisSpace[1] end
   local last=nil
   local skipSpaces=0
   for _, spc in ipairs(userSpaces) do
      if spaces.spaceType(spc)~="user" then -- skippable space
	 skipSpaces=skipSpaces+1
      else
	 if last and
	    ((dir=="left" and spc==thisSpace) or
	     (dir=="right" and last==thisSpace)) then
	       local newSpace=(dir=="left" and last or spc)
	       if switch then
		  spaces.gotoSpace(newSpace)  -- also possible, invokes MC
		--   switchSpace(skipSpaces+1,dir)
	       end
	       spaces.moveWindowToSpace(win,newSpace)
	       return
	 end
	 last=spc	 -- Haven't found it yet...
	 skipSpaces=0
      end
   end
   flashScreen(screen)   -- Shouldn't get here, so no space found
end




spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()                                                    -- Layouts Menu
hs.hotkey.bind(_hyper, "W", function() spoon.AClock:toggleShow() end)                                            -- Aclock Show
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)                                                         -- Reload HammerSpoon
hs.hotkey.bind("shift", "F13", function() hs.execute("open ~/Pictures/Greenshot") end)                           -- shift + f13 open screenshots folder
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)                                                  -- Toggle HammerSpoon Console
hs.hotkey.bind(_hyper, "F1", function() hs.application.launchOrFocus("Console") end)                             -- hyper open console.app
hs.hotkey.bind(hammer, "F2", function() hs.application.launchOrFocus("Finder") end)                              -- hammer F2 for finder
hs.hotkey.bind(hammer, "`", function() hs.application.launchOrFocus("Visual Studio Code") end)                   -- hammer ` for vscode
hs.hotkey.bind(hammer, "p", function() hs.application.launchOrFocus("PyCharm Community Edition") end)            -- hammer P for pycharm
hs.hotkey.bind(hammer, "b", function() hs.application.launchOrFocus("Arc") end)                                  -- hammer B for arc
hs.hotkey.bind(_hyper, "b", function() hs.application.launchOrFocus("Google Chrome") end)                        -- hyper B for chrome
hs.hotkey.bind(hammer, "l", function() hs.application.launchOrFocus("logioptionsplus") end)                      -- l for Logi Options+
hs.hotkey.bind(_hyper, "l", function() hs.application.launchOrFocus("System Preferences") end)                   -- hyper l for system settings
hs.hotkey.bind(hammer, "f", function() hs.application.launchOrFocus("Fleet") end)                                -- f for fleet
hs.hotkey.bind(_hyper, "f", function() hs.execute("open ~/lab") end)                                             -- hyper f for open ~/lab
hs.hotkey.bind(hammer, "m", function() hs.eventtap.event.newSystemKeyEvent('PLAY', true):post() end)             -- hammer m for play/pause 
hs.hotkey.bind(_hyper, "m", function() hs.application.launchOrFocus("Music") end)                                -- hyper m for music
hs.hotkey.bind(hammer, "s", function() hs.application.launchOrFocus("Slack") end)                                -- hammer s for slack
hs.hotkey.bind(hammer, "g", function() hs.application.launchOrFocus("GitHub Desktop") end)                       -- hammer g for github desktop
hs.hotkey.bind(hammer, "Tab", function() hs.application.launchOrFocus("Mission Control.app") end)                -- hammer tab for mission control
hs.hotkey.bind(_hyper, "Tab", function() hs.application.launchOrFocus("Launchpad") end)                          -- hyper tab for launchpad
hs.hotkey.bind(hammer, "e", function() hs.execute("open -a '" .. editor .. "' ~/.hammerspoon/hotkeys.lua") end)  -- hammer e for edit hotkeys.lua
hs.hotkey.bind(_hyper, "e", function() hs.execute("open -a '" .. editor .. "' ~/.zshenv") end)                   -- hyper e for edit zshenv
hs.hotkey.bind(hammer, "z", function() hs.execute("open -a '" .. editor .. "' ~/.bash_aliases") end)             -- hammer z for edit bash_aliases
hs.hotkey.bind(_hyper, "z", function()    hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                 -- hyper z for edit zshrc
hs.hotkey.bind(hammer, "F9", nil, function() moveWindowOneSpace("left",true) end)                                -- hammer f9 move window one space left
hs.hotkey.bind(hammer, "F10", nil, function() moveWindowOneSpace("right",true) end)                              -- hyper f10 move window one space right
hs.hotkey.bind(_hyper, "F9", nil, function() moveWindowOneSpace("left",false) end)                               -- hyper f9 move window one space left
hs.hotkey.bind(_hyper, "F10", nil, function() moveWindowOneSpace("right",false) end)                             -- hyper f10 move window one space right
hs.hotkey.bind(hammer, "F11", nil, function() flashScreen(window.focusedWindow():screen()) end)                  -- hammer f11 flashScreen.
hs.hotkey.bind(hammer, "0", function()                                                                           -- 0 make tiny for storage 
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
    f.w = max.w / cols - 2 * gap
    f.h = max.h / rows - 2 * gap
    win:setFrame(f)
    
    -- Increment counter (and wrap around)
    counter = (counter + 1) % (rows * cols)
end)
hs.hotkey.bind(_hyper, "0", function()                                                                           -- 0 1/4th screen vertical
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    
    -- Number of rows
    local rows = 1  -- Change this value to adjust the number of rows
    
    -- Calculate position based on counter and number of rows
    local x, y = calculatePosition(counter, max, rows)
    
    -- Update frame
    f.x = x
    f.y = y
    f.w = max.w / cols - 2 * gap
    f.h = max.h 
    win:setFrame(f)
    
    -- Increment counter (and wrap around)
    counter = (counter + 1) % (rows * cols)
end)
hs.hotkey.bind(hammer, "1", function()                                                                           -- hammer 1 -- Move window Left corner
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
hs.hotkey.bind(_hyper, "1", function()                                                                           -- hyper 1 -- Move window Bottom-Left corner
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end) 
hs.hotkey.bind(hammer, "2", function()                                                                           -- hammer 2 -- Move window Right corner
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
hs.hotkey.bind(_hyper, "2", function()                                                                           -- hyper 2 -- Move window Bottom-Right corner
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w / 2)
    f.y = max.y + (max.h / 2)
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
end)  
hs.hotkey.bind(hammer, "3", function()                                                                           -- hammer 3 -- full screen
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
hs.hotkey.bind(_hyper, "3", function()                                                                           -- hyper 3 -- 80% full screen centered
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
hs.hotkey.bind(hammer, "4", function()                                                                           -- hammer 4 -- Move window 95 by 72 from left side
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.025)
    f.y = max.y + (max.h * 0.025)
    f.w = max.w * 0.72
    f.h = max.h * 0.95
    win:setFrame(f)
end)
hs.hotkey.bind(_hyper, "4", function()                                                                           -- hyper 4 -- Move window to 95 by 30 from right side
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x + (max.w * 0.75)
    f.y = max.y + (max.h * 0.025)
    f.w = max.w * 0.25
    f.h = max.h * 0.95
    win:setFrame(f)
end)
hs.hotkey.bind(hammer, "6", function()                                                                           -- 6 smaller left side
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
hs.hotkey.bind(_hyper, "6", function()                                                                           -- hyper 6 - left half
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
hs.hotkey.bind(hammer, "7", function()                                                                           -- 7 smaller right side
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
hs.hotkey.bind(_hyper, "7", function()                                                                           -- Hammer 2 - right half
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
hs.hotkey.bind(hammer, "9", function()                                                                           -- move focused window to mouse as center
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()

    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    win:setFrame(f)
end) 
hs.hotkey.bind(_hyper, "9", function()                                                                           -- 9 move focused window to cursor as top left corner  
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()

    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
end) 
hs.hotkey.bind(hammer, "left", function()                                                                        -- hammer right arrow move to next screen
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:next()
    local max = nextScreen:frame()

    f.x = max.x
    f.y = max.y
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end) 
hs.hotkey.bind(_hyper, "left", function()                                                                        -- hyper right arrow
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:next()
    local max = nextScreen:frame()
    
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end) 
hs.hotkey.bind(hammer, "right", function()                                                                       -- hammer left arrow move to previous screen
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:previous()
    local max = nextScreen:frame()

    f.x = max.x
    f.y = max.y
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end)
hs.hotkey.bind(_hyper, "right", function()                                                                       -- hyper left arrow
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local nextScreen = screen:previous()
    local max = nextScreen:frame()
    
    f.x = max.x + (max.w / 2)
    f.y = max.y
    f.w = max.w / 2
    f.h = max.h / 2
    win:setFrame(f)
    win:setFrame(f)
    win:moveToScreen(nextScreen)
end) 
hs.hotkey.bind(hammer, "-", function()                                                                           -- hammer - flash list of window movement options 1-9 
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
