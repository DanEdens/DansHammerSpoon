-- WindowMenu.lua - Comprehensive Window Management Menu System
-- Inspired by DragonGrid for intuitive window management

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()

-- Check if module is already initialized
if _G.WindowMenu then
    log:d('Returning existing WindowMenu module')
    return _G.WindowMenu
end

log:i('Initializing window management menu system')

local WindowManager = require('WindowManager')
local WindowToggler = require('WindowToggler')

local WindowMenu = {
    -- Menu state
    isMenuVisible = false,
    currentMenuBar = nil,

    -- Configuration options
    config = {
        gridCols = 4,
        gridRows = 3,
        moveStep = 150,
        gap = 5,
        animationDuration = 0.0
    }
}

-- Menu Icons (using SF Symbols or Unicode)
local icons = {
    window = "□",
    grid = "▦",
    location = "◉",
    layout = "⧉",
    move = "⇄",
    resize = "⟐",
    toggle = "⇅",
    save = "💾",
    restore = "↺",
    settings = "⚙",
    monitor = "🖥",
    clear = "🗑"
}

-- Helper function to create menu item with icon
local function createMenuItem(title, icon, callback, keyEquivalent)
    local menuItem = hs.menubar.new()
    menuItem:setTitle((icon or "") .. " " .. title)
    if callback then
        menuItem:setClickCallback(callback)
    end
    if keyEquivalent then
        menuItem:setKeyEquivalent(keyEquivalent)
    end
    return menuItem
end

-- Window Selection Helper
local function getTargetWindow(callback, showMessage)
    local win = hs.window.focusedWindow()
    if win then
        callback(win)
        return
    end

    if showMessage ~= false then
        hs.alert.show("Please focus a window first", 2)
    end
end

-- Create main window management menu
function WindowMenu.createMainMenu()
    local menuItems = {
        {
            title = "🪟 Window Management Center",
            disabled = true
        },
        { title = "-" },

        -- Quick Actions Section
        {
            title = icons.toggle .. " Toggle Location 1 ⟷ 2",
            fn = function() WindowToggler.toggleWindowPosition() end,
            tooltip = "Toggle window between saved locations"
        },
        {
            title = icons.location .. " Window Locations Menu",
            fn = function() WindowToggler.showLocationsMenu() end,
            tooltip = "Manage window save locations"
        },
        { title = "-" },

        -- Layout Section
        {
            title = icons.layout .. " Quick Layouts",
            menu = WindowMenu.createLayoutsSubmenu()
        },
        {
            title = icons.grid .. " Grid Layouts",
            menu = WindowMenu.createGridSubmenu()
        },
        {
            title = icons.move .. " Window Movement",
            menu = WindowMenu.createMovementSubmenu()
        },
        { title = "-" },

        -- Multi-Window Management
        {
            title = "📋 Layout Management",
            menu = WindowMenu.createLayoutManagementSubmenu()
        },
        {
            title = icons.monitor .. " Monitor Setup: " .. (WindowToggler.currentConfig or "Unknown"),
            menu = WindowMenu.createMonitorSubmenu()
        },
        { title = "-" },

        -- Settings and Info
        {
            title = icons.settings .. " Settings",
            menu = WindowMenu.createSettingsSubmenu()
        },
        {
            title = "ℹ️ Show Status",
            fn = function() WindowMenu.showStatus() end
        }
    }

    return menuItems
end

-- Layouts submenu
function WindowMenu.createLayoutsSubmenu()
    return {
        {
            title = "Full Screen Variants",
            disabled = true
        },
        { title = "-" },
        {
            title = "🔲 Full Screen (with margin)",
            fn = function() WindowManager.applyLayout('fullScreen') end
        },
        {
            title = "⬜ Nearly Full (90%)",
            fn = function() WindowManager.applyLayout('nearlyFull') end
        },
        {
            title = "📺 True Full (100%)",
            fn = function() WindowManager.applyLayout('trueFull') end
        },
        {
            title = "🎯 Centered (70%)",
            fn = function() WindowManager.applyLayout('sevenByFive') end
        },
        { title = "-" },

        {
            title = "Split Layouts",
            disabled = true
        },
        { title = "-" },
        {
            title = "◐ Left Half",
            fn = function() WindowManager.applyLayout('leftHalf') end
        },
        {
            title = "◑ Right Half",
            fn = function() WindowManager.applyLayout('rightHalf') end
        },
        {
            title = "⬇ Top Half",
            fn = function() WindowManager.applyLayout('splitVertical') end
        },
        {
            title = "⬆ Bottom Half",
            fn = function() WindowManager.applyLayout('splitHorizontal') end
        },
        { title = "-" },

        {
            title = "Corner Layouts",
            disabled = true
        },
        { title = "-" },
        {
            title = "↖ Top Left",
            fn = function() WindowManager.applyLayout('topLeft') end
        },
        {
            title = "↗ Top Right",
            fn = function() WindowManager.applyLayout('topRight') end
        },
        {
            title = "↙ Bottom Left",
            fn = function() WindowManager.applyLayout('bottomLeft') end
        },
        {
            title = "↘ Bottom Right",
            fn = function() WindowManager.applyLayout('bottomRight') end
        }
    }
end

-- Grid submenu
function WindowMenu.createGridSubmenu()
    return {
        {
            title = "Grid Size: " .. WindowMenu.config.gridCols .. "×" .. WindowMenu.config.gridRows,
            disabled = true
        },
        { title = "-" },

        {
            title = "Set Grid Size 2×2",
            fn = function()
                WindowMenu.config.gridCols = 2
                WindowMenu.config.gridRows = 2
                WindowManager.cols = 2
                hs.alert.show("Grid: 2×2")
            end
        },
        {
            title = "Set Grid Size 3×3",
            fn = function()
                WindowMenu.config.gridCols = 3
                WindowMenu.config.gridRows = 3
                WindowManager.cols = 3
                hs.alert.show("Grid: 3×3")
            end
        },
        {
            title = "Set Grid Size 4×4",
            fn = function()
                WindowMenu.config.gridCols = 4
                WindowMenu.config.gridRows = 4
                WindowManager.cols = 4
                hs.alert.show("Grid: 4×4")
            end
        },
        {
            title = "Set Grid Size 5×5",
            fn = function()
                WindowMenu.config.gridCols = 5
                WindowMenu.config.gridRows = 5
                WindowManager.cols = 5
                hs.alert.show("Grid: 5×5")
            end
        },
        { title = "-" },

        {
            title = "🔀 Mini Shuffle",
            fn = function() WindowManager.miniShuffle() end
        },
        {
            title = "↔ Horizontal Shuffle",
            fn = function() WindowManager.halfShuffle(4, 3) end
        },
        {
            title = "↕ Vertical Shuffle",
            fn = function() WindowManager.halfShuffle(12, 3) end
        },
        {
            title = "🔄 Reset Shuffle",
            fn = function() WindowManager.resetShuffleCounters() end
        }
    }
end

-- Movement submenu
function WindowMenu.createMovementSubmenu()
    return {
        {
            title = "Move Step: " .. WindowMenu.config.moveStep .. "px",
            disabled = true
        },
        { title = "-" },

        {
            title = "← Move Left",
            fn = function() WindowManager.moveWindow("left") end
        },
        {
            title = "→ Move Right",
            fn = function() WindowManager.moveWindow("right") end
        },
        {
            title = "↑ Move Up",
            fn = function() WindowManager.moveWindow("up") end
        },
        {
            title = "↓ Move Down",
            fn = function() WindowManager.moveWindow("down") end
        },
        { title = "-" },

        {
            title = "🎯 Move to Mouse Center",
            fn = function() WindowManager.moveWindowMouseCenter() end
        },
        {
            title = "📍 Move to Mouse Corner",
            fn = function() WindowManager.moveWindowMouseCorner() end
        },
        { title = "-" },

        {
            title = "Move Step Settings",
            disabled = true
        },
        { title = "-" },
        {
            title = "Set Move Step: 50px",
            fn = function()
                WindowMenu.config.moveStep = 50
                WindowManager.moveStep = 50
                hs.alert.show("Move step: 50px")
            end
        },
        {
            title = "Set Move Step: 100px",
            fn = function()
                WindowMenu.config.moveStep = 100
                WindowManager.moveStep = 100
                hs.alert.show("Move step: 100px")
            end
        },
        {
            title = "Set Move Step: 150px",
            fn = function()
                WindowMenu.config.moveStep = 150
                WindowManager.moveStep = 150
                hs.alert.show("Move step: 150px")
            end
        }
    }
end

-- Layout management submenu
function WindowMenu.createLayoutManagementSubmenu()
    return {
        {
            title = "💾 Save All Window Positions",
            fn = function() WindowManager.saveAllWindowPositions() end
        },
        {
            title = "↺ Restore All Window Positions",
            fn = function() WindowManager.restoreAllWindowPositions() end
        },
        { title = "-" },

        {
            title = "📸 Save Multi-Window Layout",
            fn = function()
                local layoutName = "Layout_" .. os.date("%Y%m%d_%H%M%S")
                WindowManager.saveCurrentLayout(layoutName)
                hs.alert.show("Saved layout: " .. layoutName)
            end
        },
        {
            title = "📋 Restore Multi-Window Layout",
            fn = function() WindowMenu.showSavedLayoutsMenu() end
        },
        { title = "-" },

        {
            title = "🗑 Clear All Saved Positions",
            fn = function()
                local button = hs.dialog.blockAlert("Clear All Positions",
                    "Are you sure you want to clear all saved window positions and layouts?", "Clear All", "Cancel")
                if button == "Clear All" then
                    WindowManager.lastWindowPositions = {}
                    WindowManager.savedLayouts = {}
                    WindowToggler.clearSavedLocations(true)
                    hs.alert.show("All positions cleared")
                end
            end
        }
    }
end

-- Monitor configuration submenu
function WindowMenu.createMonitorSubmenu()
    local currentConfig = WindowToggler.detectMonitorConfiguration and WindowToggler.detectMonitorConfiguration() or
    "Unknown"

    return {
        {
            title = "Current: " .. currentConfig:gsub("_", " "),
            disabled = true
        },
        { title = "-" },

        {
            title = "🔄 Refresh Monitor Config",
            fn = function()
                if WindowToggler.refreshConfiguration then
                    WindowToggler.refreshConfiguration()
                else
                    hs.alert.show("Monitor config refreshed")
                end
            end
        },
        {
            title = "📋 Show Config Info",
            fn = function()
                if WindowToggler.showConfigurationInfo then
                    WindowToggler.showConfigurationInfo()
                else
                    local screens = hs.screen.allScreens()
                    local info = "Monitor Configuration:\n\n"
                    info = info .. "Count: " .. #screens .. "\n"
                    info = info .. "Config: " .. currentConfig .. "\n\n"
                    for i, screen in ipairs(screens) do
                        local frame = screen:frame()
                        info = info .. "Screen " .. i .. ": " .. frame.w .. "×" .. frame.h .. "\n"
                    end
                    hs.alert.show(info, 5)
                end
            end
        },
        { title = "-" },

        {
            title = "🖥 Move to Previous Screen",
            fn = function() WindowManager.moveToScreen("previous", "right") end
        },
        {
            title = "🖥 Move to Next Screen",
            fn = function() WindowManager.moveToScreen("next", "left") end
        }
    }
end

-- Settings submenu
function WindowMenu.createSettingsSubmenu()
    return {
        {
            title = "Animation: " .. (WindowMenu.config.animationDuration == 0 and "Disabled" or "Enabled"),
            fn = function()
                if WindowMenu.config.animationDuration == 0 then
                    WindowMenu.config.animationDuration = 0.2
                    hs.window.animationDuration = 0.2
                    hs.alert.show("Animation enabled")
                else
                    WindowMenu.config.animationDuration = 0
                    hs.window.animationDuration = 0
                    hs.alert.show("Animation disabled")
                end
            end
        },
        {
            title = "Gap Size: " .. WindowMenu.config.gap .. "px",
            fn = function() WindowMenu.showGapSizeMenu() end
        },
        { title = "-" },

        {
            title = "🔧 Reset All Settings",
            fn = function()
                WindowMenu.config = {
                    gridCols = 4,
                    gridRows = 3,
                    moveStep = 150,
                    gap = 5,
                    animationDuration = 0.0
                }
                WindowManager.cols = 4
                WindowManager.moveStep = 150
                WindowManager.gap = 5
                hs.window.animationDuration = 0.0
                hs.alert.show("Settings reset to defaults")
            end
        }
    }
end

-- Show gap size selection menu
function WindowMenu.showGapSizeMenu()
    local choices = {
        { text = "Gap: 0px",  gap = 0 },
        { text = "Gap: 5px",  gap = 5 },
        { text = "Gap: 10px", gap = 10 },
        { text = "Gap: 15px", gap = 15 },
        { text = "Gap: 20px", gap = 20 }
    }

    local chooser = hs.chooser.new(function(choice)
        if choice then
            WindowMenu.config.gap = choice.gap
            WindowManager.gap = choice.gap
            hs.alert.show("Gap set to " .. choice.gap .. "px")
        end
    end)

    chooser:placeholderText("Select gap size...")
    chooser:choices(choices)
    chooser:show()
end

-- Show saved layouts menu
function WindowMenu.showSavedLayoutsMenu()
    local layouts = WindowManager.savedLayouts or {}
    local choices = {}

    for layoutName, layoutData in pairs(layouts) do
        table.insert(choices, {
            text = layoutName,
            subText = layoutData.description or "Saved layout",
            layoutName = layoutName
        })
    end

    if #choices == 0 then
        hs.alert.show("No saved layouts found")
        return
    end

    local chooser = hs.chooser.new(function(choice)
        if choice and choice.layoutName then
            if WindowManager.restoreLayout then
                WindowManager.restoreLayout(choice.layoutName)
            else
                hs.alert.show("Layout restoration not available")
            end
        end
    end)

    chooser:placeholderText("Select layout to restore...")
    chooser:choices(choices)
    chooser:show()
end

-- Show comprehensive status
function WindowMenu.showStatus()
    local status = "🪟 Window Management Status\n\n"

    -- Current window info
    local win = hs.window.focusedWindow()
    if win then
        local app = win:application()
        local appName = app and app:name() or "Unknown"
        local frame = win:frame()
        status = status .. "Active Window: " .. appName .. "\n"
        status = status .. "Position: " .. math.floor(frame.x) .. "," .. math.floor(frame.y) .. "\n"
        status = status .. "Size: " .. math.floor(frame.w) .. "×" .. math.floor(frame.h) .. "\n\n"
    else
        status = status .. "No active window\n\n"
    end

    -- Configuration
    status = status .. "Configuration:\n"
    status = status .. "Grid: " .. WindowMenu.config.gridCols .. "×" .. WindowMenu.config.gridRows .. "\n"
    status = status .. "Move Step: " .. WindowMenu.config.moveStep .. "px\n"
    status = status .. "Gap: " .. WindowMenu.config.gap .. "px\n"
    status = status .. "Animation: " .. (WindowMenu.config.animationDuration == 0 and "Off" or "On") .. "\n\n"

    -- Monitor info
    local screens = hs.screen.allScreens()
    status = status .. "Monitors: " .. #screens .. " (" .. (WindowToggler.currentConfig or "Unknown") .. ")\n\n"

    -- Saved positions count
    local loc1Count = 0
    local loc2Count = 0
    if WindowToggler.location1 then
        for _ in pairs(WindowToggler.location1) do loc1Count = loc1Count + 1 end
    end
    if WindowToggler.location2 then
        for _ in pairs(WindowToggler.location2) do loc2Count = loc2Count + 1 end
    end

    status = status .. "Saved Locations:\n"
    status = status .. "Location 1: " .. loc1Count .. " windows\n"
    status = status .. "Location 2: " .. loc2Count .. " windows\n"

    -- Saved layouts count
    local layoutCount = 0
    if WindowManager.savedLayouts then
        for _ in pairs(WindowManager.savedLayouts) do layoutCount = layoutCount + 1 end
    end
    status = status .. "Multi-Window Layouts: " .. layoutCount .. "\n"

    hs.alert.show(status, 8)
end

-- Main menu toggle function
function WindowMenu.toggleMenu()
    if WindowMenu.isMenuVisible then
        WindowMenu.hideMenu()
    else
        WindowMenu.showMenu()
    end
end

-- Show the main menu
function WindowMenu.showMenu()
    local menu = WindowMenu.createMainMenu()

    -- Create chooser for the menu
    local choices = {}

    local function addMenuItems(items, prefix)
        prefix = prefix or ""

        for _, item in ipairs(items) do
            if item.title == "-" then
                -- Skip separators in chooser
            elseif item.disabled then
                -- Add disabled items as headers
                table.insert(choices, {
                    text = prefix .. item.title,
                    subText = "────────",
                    disabled = true
                })
            elseif item.menu then
                -- Add submenu indicator
                table.insert(choices, {
                    text = prefix .. item.title .. " ▶",
                    subText = "Submenu",
                    submenu = item.menu,
                    prefix = prefix .. "  "
                })
            else
                -- Regular menu item
                table.insert(choices, {
                    text = prefix .. item.title,
                    subText = item.tooltip or "Window action",
                    fn = item.fn
                })
            end
        end
    end

    addMenuItems(menu)

    local chooser = hs.chooser.new(function(choice)
        if not choice then
            WindowMenu.isMenuVisible = false
            return
        end

        if choice.disabled then
            -- Re-show menu for disabled items
            WindowMenu.showMenu()
            return
        end

        if choice.submenu then
            -- Show submenu
            WindowMenu.showSubmenu(choice.submenu, choice.text, choice.prefix)
            return
        end

        if choice.fn then
            choice.fn()
        end

        WindowMenu.isMenuVisible = false
    end)

    chooser:placeholderText("Window Management Menu...")
    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:show()

    WindowMenu.isMenuVisible = true
    WindowMenu.currentMenuBar = chooser
end

-- Show submenu
function WindowMenu.showSubmenu(submenuItems, title, prefix)
    local choices = {}

    local function addMenuItems(items, currentPrefix)
        currentPrefix = currentPrefix or ""

        for _, item in ipairs(items) do
            if item.title == "-" then
                -- Skip separators
            elseif item.disabled then
                table.insert(choices, {
                    text = currentPrefix .. item.title,
                    subText = "────────",
                    disabled = true
                })
            else
                table.insert(choices, {
                    text = currentPrefix .. item.title,
                    subText = item.tooltip or "Action",
                    fn = item.fn
                })
            end
        end
    end

    addMenuItems(submenuItems, "")

    -- Add back option
    table.insert(choices, 1, {
        text = "◀ Back to Main Menu",
        subText = "Return to previous menu",
        back = true
    })

    local chooser = hs.chooser.new(function(choice)
        if not choice then
            WindowMenu.isMenuVisible = false
            return
        end

        if choice.disabled then
            WindowMenu.showSubmenu(submenuItems, title, prefix)
            return
        end

        if choice.back then
            WindowMenu.showMenu()
            return
        end

        if choice.fn then
            choice.fn()
        end

        WindowMenu.isMenuVisible = false
    end)

    chooser:placeholderText(title or "Submenu...")
    chooser:choices(choices)
    chooser:searchSubText(true)
    chooser:show()

    WindowMenu.currentMenuBar = chooser
end

-- Hide menu
function WindowMenu.hideMenu()
    if WindowMenu.currentMenuBar then
        WindowMenu.currentMenuBar:hide()
        WindowMenu.currentMenuBar = nil
    end
    WindowMenu.isMenuVisible = false
end

-- Initialize the module
function WindowMenu.init()
    log:i('Window management menu system initialized')

    -- Load saved configuration if exists
    -- This could be expanded to persist settings

    return WindowMenu
end

-- Store globally and initialize
_G.WindowMenu = WindowMenu
WindowMenu.init()

return WindowMenu
