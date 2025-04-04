local log = hs.logger.new('AppManager', 'debug')
log.i('Initializing application management system')

local FileManager = require('FileManager')

local AppManager = {}

-- Configuration
local enableMultiWindowSelector = true

-- Application Management Functions
function AppManager.launchOrFocusWithWindowSelection(appName)
    if not enableMultiWindowSelector then
        hs.application.launchOrFocus(appName)
        return
    end

    local app = hs.application.find(appName)

    if not app then
        hs.application.launchOrFocus(appName)
        return
    end

    local windows = app:allWindows()

    if #windows == 0 then
        hs.application.launchOrFocus(appName)
        return
    end

    if #windows == 1 then
        windows[1]:focus()
        return
    end

    local choices = {}

    -- Add existing windows as choices
    for i, win in ipairs(windows) do
        local title = win:title()
        table.insert(choices, {
            text = title,
            subText = "Focus this " .. appName .. " window",
            window = win,
            type = "window"
        })
    end

    -- Add a separator
    table.insert(choices, {
        text = "──────────────────────────────────",
        subText = "Projects",
        disabled = true
    })

    -- Add projects list as choices
    local projects_list = FileManager.getProjectsList()
    for _, project in ipairs(projects_list) do
        table.insert(choices, {
            text = project.name,
            subText = "Open " .. project.path,
            path = project.path,
            type = "project"
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if not choice then return end

        if choice.type == "window" then
            -- Focus the selected window
            choice.window:focus()
        elseif choice.type == "project" then
            -- Open the selected project with the application
            hs.execute("open -a '" .. appName .. "' " .. choice.path)
        elseif choice.type == "custom" then
            -- Open the custom path with the application
            hs.execute("open -a '" .. appName .. "' " .. choice.path)
        end
    end)

    -- Handle the query changed callback for custom paths
    chooser:queryChangedCallback(function(query)
        if query:match("^[~/]") then
            -- If query starts with / or ~, show only one option for custom path
            local customChoices = table.shallow_copy(choices)
            table.insert(customChoices, 1, {
                text = "Open custom path: " .. query,
                subText = "Enter to open this path with " .. appName,
                path = query,
                type = "custom"
            })
            chooser:choices(customChoices)
        else
            -- Show normal filtered choices
            chooser:choices(choices)
        end
    end)

    chooser:choices(choices)
    chooser:show()
end

-- Application Launch Functions
function AppManager.open_github()
    AppManager.launchOrFocusWithWindowSelection("GitHub Desktop")
end

function AppManager.open_slack()
    AppManager.launchOrFocusWithWindowSelection("Slack")
end

function AppManager.open_arc()
    AppManager.launchOrFocusWithWindowSelection("Arc")
end

function AppManager.open_chrome()
    AppManager.launchOrFocusWithWindowSelection("Google Chrome")
end

function AppManager.open_pycharm()
    AppManager.launchOrFocusWithWindowSelection("PyCharm Community Edition")
end

function AppManager.open_anythingllm()
    AppManager.launchOrFocusWithWindowSelection("AnythingLLM")
end

function AppManager.open_mongodb()
    AppManager.launchOrFocusWithWindowSelection("MongoDB Compass")
end

function AppManager.open_logi()
    AppManager.launchOrFocusWithWindowSelection("logioptionsplus")
end

function AppManager.open_system()
    AppManager.launchOrFocusWithWindowSelection("System Preferences")
end

function AppManager.open_vscode()
    AppManager.launchOrFocusWithWindowSelection("Visual Studio Code")
end

function AppManager.open_cursor()
    AppManager.launchOrFocusWithWindowSelection("cursor")
end

function AppManager.open_barrier()
    hs.execute("open -a 'Barrier'")
end

function AppManager.open_mission_control()
    AppManager.launchOrFocusWithWindowSelection("Mission Control.app")
end

function AppManager.open_launchpad()
    AppManager.launchOrFocusWithWindowSelection("Launchpad")
end

return AppManager
