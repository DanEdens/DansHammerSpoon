

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

-- shift + f13 open screenshots folder
hs.hotkey.bind("shift", "F13", function()
    hs.execute("open ~/Pictures/Greenshot")
end)

-- Toggle HammerSpoon Console
hs.hotkey.bind(hammer, "F1", function()
    hs.toggleConsole()
end)

--hyper open console.app
hs.hotkey.bind(hyper, "F1", function()
    hs.application.launchOrFocus("Console")
end)

-- hammer F2 for finder

hs.hotkey.bind(hammer, "F2", function()
    hs.application.launchOrFocus("Finder")
end)

-- ctrl + cmd + alt + ` to switch to vs code
hs.hotkey.bind(hammer, "`", function()
    hs.application.launchOrFocus("Visual Studio Code")
end)

-- hammer P for pycharm
hs.hotkey.bind(hammer, "p", function()
    hs.application.launchOrFocus("PyCharm Community Edition")
end)


-- hammer B for arc browser
hs.hotkey.bind(hammer, "b", function()
    hs.application.launchOrFocus("Arc")
end)

-- hyper B for chrome
hs.hotkey.bind(hyper, "b", function()
    hs.application.launchOrFocus("Google Chrome")
end)

-- l for Logi Options+
hs.hotkey.bind(hammer, "l", function()
    hs.application.launchOrFocus("logioptionsplus")
end)

-- hyper l for system settings
hs.hotkey.bind(hyper, "l", function()
    hs.application.launchOrFocus("System Preferences")
end)

-- f for fleet
hs.hotkey.bind(hammer, "f", function()
    hs.application.launchOrFocus("Fleet")
end)

-- hyper f for open ~/lab
hs.hotkey.bind(hyper, "f", function()
    hs.execute("open ~/lab")
end)

-- m for music
hs.hotkey.bind(hammer, "m", function()
    hs.application.launchOrFocus("Music")
end)
-- hyper m for play/pause 

 hs.hotkey.bind(hyper, "m", function()
    hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
end)

-- s for slack
hs.hotkey.bind(hammer, "s", function()
    hs.application.launchOrFocus("Slack")
end)

-- g for github desktop
hs.hotkey.bind(hammer, "g", function()
    hs.application.launchOrFocus("GitHub Desktop")
end)


-- hammer tab for mission control
hs.hotkey.bind(hammer, "Tab", function()
    hs.application.launchOrFocus("Mission Control.app")
end)

-- hyper tab for launchpad
hs.hotkey.bind(hyper, "Tab", function()
    hs.application.launchOrFocus("Launchpad")
end)

-- Move window Left corner
hs.hotkey.bind(hammer, "1", function()
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

-- Move window Bottom-Left corner
hs.hotkey.bind(hyper, "1", function()
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

-- Move window Right corner
hs.hotkey.bind(hammer, "2", function()
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

-- Move window Bottom-Right corner
hs.hotkey.bind(hyper, "2", function()
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

-- Move window Full screen
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

-- 5 -- 80% full screen centered
hs.hotkey.bind(hyper, "3", function()
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

-- Move window 95 by 70 Full screen
hs.hotkey.bind(hammer, "4", function()
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

-- Move window to 95 by 30 from right side
hs.hotkey.bind(hyper, "4", function()
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

-- Hammer 1 - left half
hs.hotkey.bind(hyper, "6", function()
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

-- Hammer 2 - right half
hs.hotkey.bind(hyper, "7", function()
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

-- 9 move focused window to cursor as top left corner  
hs.hotkey.bind(hyper, "9", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()

    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
end)

-- hammer right arrow move to next screen
hs.hotkey.bind(hammer, "left", function()
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

-- hyper right arrow
hs.hotkey.bind(hyper, "left", function()
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

-- hammer left arrow move to previous screen
hs.hotkey.bind(hammer, "right", function()
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

-- hyper left arrow
hs.hotkey.bind(hyper, "right", function()
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

-- hyper - edit hotkeys.lua
hs.hotkey.bind(hyper, "-", function()
    hs.execute("code  ~/.hammerspoon/hotkeys.lua")
end)



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

hotkey.bind(hammer, "F9",nil,
	    function() moveWindowOneSpace("right",true) end)
hotkey.bind(hammer, "F10",nil,
	    function() moveWindowOneSpace("left",true) end)
hotkey.bind(hyper, "F9",nil,
	    function() moveWindowOneSpace("right",false) end)
hotkey.bind(hyper, "F10",nil,
	    function() moveWindowOneSpace("left",false) end)