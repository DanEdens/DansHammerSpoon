

hammer = {"cmd","ctrl","alt"}
hyper = {"cmd","shift","ctrl","alt"}


-- Layouts Menu
spoon.Layouts:bindHotKeys({ choose = {hammer, "8"} }):start()


-- Aclock Show
hs.hotkey.bind(hammer, "W", function()
    spoon.AClock:toggleShow()
end)

-- Reload HammerSpoon
hs.hotkey.bind(hammer, "R", function()
    hs.reload()
end)

-- Toggle HammerSpoon Console
hs.hotkey.bind(hammer, "Space", function()
    hs.toggleConsole()
end)


