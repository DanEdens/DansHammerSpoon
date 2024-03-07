local window = require "hs.window"
local spaces = require "hs.spaces"

-- hammer = "fn"
hammer = {"cmd","ctrl","alt"}
_hyper = {"cmd","shift","ctrl","alt"}

-- local editor = "Visual Studio Code"
-- local editor = "PyCharm Community Edition"
local editor = "Fleet"

local gap = 5
local cols = 4
local counter = 0

local function calculatePosition(counter, max, rows)
    local row = math.floor(counter / cols)
    local col = counter % cols
    local x = max.x + (col * (max.w / cols + gap))
    local y = max.y + (row * (max.h / rows + gap))
    return x, y
end
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
hs.hotkey.bind("shift", "F13", function() hs.execute("open ~/Pictures/Greenshot") end)                           -- shift f13    -- Screenshots folder
spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()                                                    -- hammer 8     -- Layouts Menu
hs.hotkey.bind(_hyper, "W", function() spoon.AClock:toggleShow() end)                                            -- _hyper W     -- Aclock Show
hs.hotkey.bind(hammer, "F5", function() hs.reload() end)                                                         -- hammer F5    -- Reload HammerSpoon
hs.hotkey.bind(hammer, "F1", function() hs.toggleConsole() end)                                                  -- hammer F1    -- Toggle HammerSpoon Console
hs.hotkey.bind(_hyper, "F1", function() hs.application.launchOrFocus("Console") end)                             -- _hyper F2    -- Open console.app
hs.hotkey.bind(hammer, "F2", function() hs.application.launchOrFocus("Finder") end)                              -- hammer F2    -- Finder
hs.hotkey.bind(hammer, "`", function() hs.application.launchOrFocus("Visual Studio Code") end)                   -- hammer `     -- Vscode
hs.hotkey.bind(hammer, "p", function() hs.application.launchOrFocus("PyCharm Community Edition") end)            -- hammer P     -- Pycharm
hs.hotkey.bind(hammer, "b", function() hs.application.launchOrFocus("Arc") end)                                  -- hammer B     -- Arc
hs.hotkey.bind(_hyper, "b", function() hs.application.launchOrFocus("Google Chrome") end)                        -- _hyper B     -- Chrome
hs.hotkey.bind(hammer, "l", function() hs.application.launchOrFocus("logioptionsplus") end)                      -- hammer l     -- Logi Options+
hs.hotkey.bind(_hyper, "l", function() hs.application.launchOrFocus("System Preferences") end)                   -- _hyper l     -- System settings
hs.hotkey.bind(hammer, "f", function() hs.application.launchOrFocus("Fleet") end)                                -- hammer f     -- Fleet
hs.hotkey.bind(_hyper, "f", function() hs.execute("open ~/lab") end)                                             -- _hyper f     -- Open ~/lab
hs.hotkey.bind(hammer, "m", function() hs.eventtap.event.newSystemKeyEvent('PLAY', true):post() end)             -- hammer m     -- Play/pause 
hs.hotkey.bind(_hyper, "m", function() hs.application.launchOrFocus("Music") end)                                -- _hyper m     -- Music
hs.hotkey.bind(hammer, "s", function() hs.application.launchOrFocus("Slack") end)                                -- hammer s     -- Slack
hs.hotkey.bind(hammer, "g", function() hs.application.launchOrFocus("GitHub Desktop") end)                       -- hammer g     -- Github desktop
hs.hotkey.bind(hammer, "Tab", function() hs.application.launchOrFocus("Mission Control.app") end)                -- hammer Tab   -- mission control
hs.hotkey.bind(_hyper, "Tab", function() hs.application.launchOrFocus("Launchpad") end)                          -- _hyper Tab   -- launchpad
hs.hotkey.bind(hammer, "e", function() hs.execute("open -a '" .. editor .. "' ~/.hammerspoon/hotkeys.lua") end)  -- hammer e     -- edit hotkeys.lua
hs.hotkey.bind(_hyper, "e", function() hs.execute("open -a '" .. editor .. "' ~/.zshenv") end)                   -- _hyper e     -- edit zshenv
hs.hotkey.bind(hammer, "z", function() hs.execute("open -a '" .. editor .. "' ~/.bash_aliases") end)             -- hammer z     -- edit bash_aliases
hs.hotkey.bind(_hyper, "z", function()    hs.execute("open -a '" .. editor .. "' ~/.zshrc") end)                 -- _hyper z     -- edit zshrc
hs.hotkey.bind(hammer, "F9", nil, function() moveWindowOneSpace("left",true) end)                                -- hammer F9    -- move window one space left
hs.hotkey.bind(_hyper, "F9", nil, function() moveWindowOneSpace("left",false) end)                               -- _hyper F9    -- move window one space left
hs.hotkey.bind(hammer, "F10", nil, function() moveWindowOneSpace("right",true) end)                              -- hammer F10   -- move window one space right
hs.hotkey.bind(_hyper, "F10", nil, function() moveWindowOneSpace("right",false) end)                             -- _hyper F10   -- move window one space right
hs.hotkey.bind(hammer, "F11", nil, function() flashScreen(window.focusedWindow():screen()) end)                  -- hammer F11   -- flashScreen
hs.hotkey.bind(hammer, "0", function()                                                                           -- hammer 0     -- shuffle 
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local rows = 2  -- Adjust the number of rows
    local x, y = calculatePosition(counter, max, rows) -- Calculate position based on counter and number of rows
    f.x = x
    f.y = y
    f.w = max.w / cols - 2 * gap
    f.h = max.h / rows - 2 * gap
    win:setFrame(f)
    counter = (counter + 1) % (rows * cols)
end)
hs.hotkey.bind(_hyper, "0", function()                                                                           -- _hyper 0     -- 1/4th screen vertical
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local rows = 1  -- Adjust the number of rows
    local x, y = calculatePosition(counter, max, rows)
    f.x = x
    f.y = y
    f.w = max.w / cols - 2 * gap
    f.h = max.h 
    win:setFrame(f)
    counter = (counter + 1) % (rows * cols)
end)
hs.hotkey.bind(hammer, "1", function()                                                                           -- hammer 1     -- Move window Left corner
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
hs.hotkey.bind(_hyper, "1", function()                                                                           -- _hyper 1     -- Move window Bottom-Left corner
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
hs.hotkey.bind(hammer, "2", function()                                                                           -- hammer 2     -- Move window Right corner
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
hs.hotkey.bind(_hyper, "2", function()                                                                           -- _hyper 2     -- Move window Bottom-Right corner
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
hs.hotkey.bind(hammer, "3", function()                                                                           -- hammer 3     -- full screen
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
hs.hotkey.bind(_hyper, "3", function()                                                                           -- _hyper 3     -- 80% full screen centered
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
hs.hotkey.bind(hammer, "4", function()                                                                           -- hammer 4     -- Move window 95 by 72 from left side
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + 30
    f.y = max.y + (max.h * 0.01)
    f.w = max.w * 0.72 - 30
    f.h = max.h * 0.98
    win:setFrame(f)
end)
hs.hotkey.bind(_hyper, "4", function()                                                                           -- _hyper 4     -- Move window to 95 by 30 from right side
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w * 0.73)
    f.y = max.y + (max.h * 0.01)
    f.w = max.w * 0.27
    f.h = max.h * 0.98
    win:setFrame(f)
end)
hs.hotkey.bind(hammer, "6", function()                                                                           -- hammer 6     -- smaller left side
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
hs.hotkey.bind(_hyper, "6", function()                                                                           -- _hyper 6     -- left half
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
hs.hotkey.bind(hammer, "7", function()                                                                           -- hammer 7     -- smaller right side
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
hs.hotkey.bind(_hyper, "7", function()                                                                           -- Hammer 7     -- right half
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
hs.hotkey.bind(hammer, "9", function()                                                                           -- hammer 9     -- move focused window to mouse as center
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()
    f.x = mouse.x - (f.w / 2)
    f.y = mouse.y - (f.h / 2)
    win:setFrame(f)
end) 
hs.hotkey.bind(_hyper, "9", function()                                                                           -- _hyper 9     -- move focused window to cursor as top left corner  
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local mouse = hs.mouse.absolutePosition()
    local screen = win:screen()
    local max = screen:frame()
    f.x = mouse.x
    f.y = mouse.y
    win:setFrame(f)
end) 
hs.hotkey.bind(hammer, "left", function()                                                                        -- hammer right -- move to next screen left
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
hs.hotkey.bind(_hyper, "left", function()                                                                        -- _hyper right -- move to next screen right
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
hs.hotkey.bind(hammer, "right", function()                                                                       -- hammer left  -- move to previous screen left
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
hs.hotkey.bind(_hyper, "right", function()                                                                       -- _hyper left  -- move to previous screen right
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
hs.hotkey.bind(hammer, "-", function()                                                                           -- hammer -     -- flash list of window movement options 1-9 
    hs.alert.show("\
    -- shift  f13             -- Screenshots folder                          -- hammer 8         -- Layouts Menu  \
    -- _hyper W           -- Aclock Show                                     -- hammer F1       -- Toggle HammerSpoon Console  \
    -- _hyper F2          -- Open console.app                           -- hammer F2      -- Finder  \
    -- hammer F5       -- Reload HammerSpoon                   -- hammer F11    -- flashScreen  \
    -- hammer F9       -- move window one space left        -- _hyper F9       -- move window one space left  \
    -- hammer F10     -- move window one space right     -- _hyper F10     -- move window one space right  \
    -- hammer `          -- Vscode                                                -- hammer P       -- Pycharm  \
    -- hammer B         -- Arc                                                         -- _hyper B         -- Chrome  \
    -- hammer l           -- Logi Options+                                    -- _hyper l          -- System settings  \
    -- hammer f           -- Fleet                                                     -- _hyper f          -- Open ~/lab  \
    -- hammer m         -- Play/pause                                         -- _hyper m        -- Music  \
    -- hammer s           -- Slack                                                   -- hammer g       -- Github desktop  \
    -- hammer Tab      -- mission control                                -- _hyper Tab      -- launchpad  \
    ")
end)    
hs.hotkey.bind(_hyper, "-", function()                                                                           -- hammer -     -- flash list of window movement options 1-9 
    hs.alert.show("\
    -- hammer e           -- edit hotkeys.lua                                        -- _hyper e     -- edit zshenv  \
    -- hammer z           -- edit bash_aliases                                     -- _hyper z     -- edit zshrc  \
    -- hammer 0           -- shuffle                                                         -- _hyper 0     -- 1/4th screen vertical  \
    -- hammer 1           -- Move window Left corner                      -- _hyper 1     -- Move window Bottom-Left corner  \
    -- hammer 2           -- Move window Right corner                   -- _hyper 2     -- Move window Bottom-Right corner  \
    -- hammer 3           -- full screen                                                   -- _hyper 3     -- 80% full screen centered  \
    -- hammer 4           -- Move window 95 by 72 left side         -- _hyper 4     -- Move window to 95 by 30 from right side  \
    -- hammer 6           -- smaller left side                                        -- _hyper 6       -- left half  \
    -- hammer 7           -- smaller right side                                      -- hammer 7     -- right half  \
    -- hammer 9           -- focused window to mouse center      -- _hyper 9        -- move focused window to cursor as top left corner    \
    -- hammer right     -- move to next screen left                        -- _hyper right   -- move to next screen right  \
    -- hammer left        -- move to previous screen left                -- _hyper left     -- move to previous screen right  \
    -- hammer -            -- flash list of options 1-9 \
    ")
end) 
