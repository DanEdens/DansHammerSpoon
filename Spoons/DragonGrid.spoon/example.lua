-- Example usage of DragonGrid.spoon

-- Load the spoon
hs.loadSpoon("DragonGrid")

-- Optional: Configure the DragonGrid spoon
-- Change grid size (default is 3x3)
spoon.DragonGrid.config.gridSize = 3

-- Change maximum number of layers (default is 2)
spoon.DragonGrid.config.maxLayers = 2

-- Optional: Customize colors
spoon.DragonGrid.config.colors.background = { red = 0, green = 0, blue = 0, alpha = 0.3 }

-- Define your hyper key (modify as needed)
local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Bind hotkeys to activate DragonGrid
-- In this example, pressing hyper+g will show the grid
spoon.DragonGrid:bindHotKeys({
    show = { hyper, "g" }
})

-- Start the DragonGrid spoon
-- This will create the menubar icon and set up the spoon
spoon.DragonGrid:start()

-- Optional: log level can be adjusted if you want more or less logging
spoon.DragonGrid.logger.setLogLevel('info') -- Options: 'debug', 'info', 'warning', 'error'

-- That's it! You can now use DragonGrid by pressing hyper+g
