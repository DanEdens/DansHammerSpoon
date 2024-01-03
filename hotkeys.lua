

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    spoon.AClock:toggleShow()
end)

hs.hotkey.bind({"alt", "ctrl","cmd"}, "R", function()
    hs.reload()
end)
