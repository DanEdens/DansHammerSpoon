

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


-- ctrl + cmd + alt + ` to switch to vs code
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "`", function()
    hs.application.launchOrFocus("Visual Studio Code")
end)

-- -- ctrl + cmd + alt + shift + P
hs.hotkey.bind(hammer, "1", function()
    hs.execute("code ~/lab/regressiontestkit")
end)