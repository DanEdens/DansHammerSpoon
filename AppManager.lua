-- AppManager.lua - Application management utilities
-- Using singleton pattern to avoid multiple initializations

local HyperLogger = require('HyperLogger')
local log = HyperLogger.new('AppManager', 'debug')

-- Check if module is already initialized
if _G.AppManager then
    log:d('Returning existing AppManager module')
    return _G.AppManager
end

log:i('Initializing application management system')

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
    local openWindowTitles = {}

    -- Add existing windows as choices
    for i, win in ipairs(windows) do
        local title = win:title()
        table.insert(choices, {
            text = title,
            subText = "Focus this " .. appName .. " window",
            window = win,
            type = "window"
        })
        openWindowTitles[title] = true
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
        if not openWindowTitles[project.name] then
            table.insert(choices, {
                text = project.name,
                subText = "Open " .. project.path,
                path = project.path,
                type = "project"
            })
        end
    end

    local chooser = hs.chooser.new(function(choice)
        if not choice then return end

        if choice.type == "window" then
            -- Focus the selected window
            choice.window:focus()
        elseif choice.type == "project" and choice.text == "New Project" then
            -- Handle New Project creation
            -- local home = os.getenv("HOME")
            -- local timestamp = os.date("%Y%m%d_%H%M%S")
            -- local newProjectPath = home .. "/lab/new_project_" .. timestamp
            -- -- Create the directory and open it
            -- hs.execute("mkdir -p '" .. newProjectPath .. "'")
            -- hs.execute("open -a '" .. appName .. "' '" .. newProjectPath .. "'")
            -- -- Alert the user
            hs.alert.show("TODO: Implement new project creation")
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
            local customChoices = {}
            for k, v in pairs(choices) do customChoices[k] = v end
            table.insert(customChoices, 1, {
                text = "Open custom path: " .. query,
                subText = "Enter to open this path with " .. appName,
                path = query,
                type = "custom"
            })

            chooser:choices(customChoices)
        else
            -- Filter choices based on the query
            local filteredChoices = {}
            local hasMatches = false
            local matchingChoices = {}
            local separatorChoice = nil

            -- First find the separator and matching items
            for _, choice in ipairs(choices) do
                if choice.disabled then
                    separatorChoice = choice
                elseif choice.type == "project" or choice.type == "window" then
                    if choice.text:lower():find(query:lower(), 1, true) then
                        table.insert(matchingChoices, choice)
                        hasMatches = true
                    end
                end
            end

            -- Add windows first if any
            for _, choice in ipairs(matchingChoices) do
                if choice.type == "window" then
                    table.insert(filteredChoices, choice)
                end
            end

            -- Add separator if we have any matches
            if hasMatches and separatorChoice then
                table.insert(filteredChoices, separatorChoice)
            end

            -- Add projects
            for _, choice in ipairs(matchingChoices) do
                if choice.type == "project" then
                    table.insert(filteredChoices, choice)
                end
            end

            -- If no matches found and query is not empty, add custom path option
            if not hasMatches and query ~= "" then
                table.insert(filteredChoices, {
                    text = "Open custom path: " .. query,
                    subText = "Enter to open this path with " .. appName,
                    path = query,
                    type = "custom"
                })
            end

            chooser:choices(filteredChoices)
        end
    end)

    chooser:choices(choices)
    chooser:show()
end

-- Special function for GitHub Desktop that always shows the selection menu
function AppManager.launchGitHubWithProjectSelection()
    local appName = "GitHub Desktop"
    local app = hs.application.find(appName)

    if not app then
        -- If GitHub Desktop isn't running, launch it with the selection menu
        local choices = {}

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

            if choice.type == "project" then
                -- Open the selected project with GitHub Desktop
                hs.execute("open -a '" .. appName .. "' " .. choice.path)
            elseif choice.type == "custom" then
                -- Open the custom path with GitHub Desktop
                hs.execute("open -a '" .. appName .. "' " .. choice.path)
            end
        end)

        -- Handle the query changed callback for custom paths
        chooser:queryChangedCallback(function(query)
            if query:match("^[~/]") then
                -- If query starts with / or ~, show only one option for custom path
                local customChoices = {}
                for k, v in pairs(choices) do customChoices[k] = v end
                table.insert(customChoices, 1, {
                    text = "Open custom path: " .. query,
                    subText = "Enter to open this path with " .. appName,
                    path = query,
                    type = "custom"
                })

                chooser:choices(customChoices)
            else
                -- Filter choices based on the query
                local filteredChoices = {}
                local hasMatches = false
                local matchingChoices = {}
                local separatorChoice = nil

                -- First find the separator and matching items
                for _, choice in ipairs(choices) do
                    if choice.disabled then
                        separatorChoice = choice
                    elseif choice.type == "project" or choice.type == "window" then
                        if choice.text:lower():find(query:lower(), 1, true) then
                            table.insert(matchingChoices, choice)
                            hasMatches = true
                        end
                    end
                end

                -- Add windows first if any
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "window" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- Add separator if we have any matches
                if hasMatches and separatorChoice then
                    table.insert(filteredChoices, separatorChoice)
                end

                -- Add projects
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "project" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- If no matches found and query is not empty, add custom path option
                if not hasMatches and query ~= "" then
                    table.insert(filteredChoices, {
                        text = "Open custom path: " .. query,
                        subText = "Enter to open this path with " .. appName,
                        path = query,
                        type = "custom"
                    })
                end

                chooser:choices(filteredChoices)
            end
        end)

        chooser:choices(choices)
        chooser:show()
    else
        -- If GitHub Desktop is running, get all its windows
        local windows = app:allWindows()
        local choices = {}
        local openWindowTitles = {}

        -- Add existing windows as choices
        for i, win in ipairs(windows) do
            local title = win:title()
            table.insert(choices, {
                text = title,
                subText = "Focus this " .. appName .. " window",
                window = win,
                type = "window"
            })
            openWindowTitles[title] = true
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
            if not openWindowTitles[project.name] then
                table.insert(choices, {
                    text = project.name,
                    subText = "Open " .. project.path,
                    path = project.path,
                    type = "project"
                })
            end
        end

        local chooser = hs.chooser.new(function(choice)
            if not choice then return end

            if choice.type == "window" then
                -- Focus the selected window
                choice.window:focus()
            elseif choice.type == "project" then
                -- Open the selected project with GitHub Desktop
                hs.execute("open -a '" .. appName .. "' " .. choice.path)
            elseif choice.type == "custom" then
                -- Open the custom path with GitHub Desktop
                hs.execute("open -a '" .. appName .. "' " .. choice.path)
            end
        end)

        -- Handle the query changed callback for custom paths
        chooser:queryChangedCallback(function(query)
            if query:match("^[~/]") then
                -- If query starts with / or ~, show only one option for custom path
                local customChoices = {}
                for k, v in pairs(choices) do customChoices[k] = v end
                table.insert(customChoices, 1, {
                    text = "Open custom path: " .. query,
                    subText = "Enter to open this path with " .. appName,
                    path = query,
                    type = "custom"
                })

                chooser:choices(customChoices)
            else
                -- Filter choices based on the query
                local filteredChoices = {}
                local hasMatches = false
                local matchingChoices = {}
                local separatorChoice = nil

                -- First find the separator and matching items
                for _, choice in ipairs(choices) do
                    if choice.disabled then
                        separatorChoice = choice
                    elseif choice.type == "project" or choice.type == "window" then
                        if choice.text:lower():find(query:lower(), 1, true) then
                            table.insert(matchingChoices, choice)
                            hasMatches = true
                        end
                    end
                end

                -- Add windows first if any
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "window" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- Add separator if we have any matches
                if hasMatches and separatorChoice then
                    table.insert(filteredChoices, separatorChoice)
                end

                -- Add projects
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "project" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- If no matches found and query is not empty, add custom path option
                if not hasMatches and query ~= "" then
                    table.insert(filteredChoices, {
                        text = "Open custom path: " .. query,
                        subText = "Enter to open this path with " .. appName,
                        path = query,
                        type = "custom"
                    })
                end

                chooser:choices(filteredChoices)
            end
        end)

        chooser:choices(choices)
        chooser:show()
    end
end

-- Special function for Cursor that also updates GitHub Desktop
function AppManager.launchCursorWithGitHubDesktop()
    local cursorAppName = "cursor"
    local githubAppName = "GitHub Desktop"
    local cursor = hs.application.find(cursorAppName)

    if not cursor then
        -- If Cursor isn't running, launch it with the selection menu
        local choices = {}

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

            if choice.type == "project" then
                -- Open the selected project with both GitHub Desktop and Cursor
                hs.execute("open -a '" .. githubAppName .. "' " .. choice.path)
                hs.execute("open -a '" .. cursorAppName .. "' " .. choice.path)
            elseif choice.type == "custom" then
                -- Open the custom path with both GitHub Desktop and Cursor
                hs.execute("open -a '" .. githubAppName .. "' " .. choice.path)
                hs.execute("open -a '" .. cursorAppName .. "' " .. choice.path)
            end
        end)

        -- Handle the query changed callback for custom paths
        chooser:queryChangedCallback(function(query)
            if query:match("^[~/]") then
                -- If query starts with / or ~, show only one option for custom path
                local customChoices = {}
                for k, v in pairs(choices) do customChoices[k] = v end
                table.insert(customChoices, 1, {
                    text = "Open custom path: " .. query,
                    subText = "Enter to open this path with " .. cursorAppName,
                    path = query,
                    type = "custom"
                })

                chooser:choices(customChoices)
            else
                -- Filter choices based on the query
                local filteredChoices = {}
                local hasMatches = false
                local matchingChoices = {}
                local separatorChoice = nil

                -- First find the separator and matching items
                for _, choice in ipairs(choices) do
                    if choice.disabled then
                        separatorChoice = choice
                    elseif choice.type == "project" or choice.type == "window" then
                        if choice.text:lower():find(query:lower(), 1, true) then
                            table.insert(matchingChoices, choice)
                            hasMatches = true
                        end
                    end
                end

                -- Add windows first if any
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "window" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- Add separator if we have any matches
                if hasMatches and separatorChoice then
                    table.insert(filteredChoices, separatorChoice)
                end

                -- Add projects
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "project" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- If no matches found and query is not empty, add custom path option
                if not hasMatches and query ~= "" then
                    table.insert(filteredChoices, {
                        text = "Open custom path: " .. query,
                        subText = "Enter to open this path with " .. cursorAppName,
                        path = query,
                        type = "custom"
                    })
                end

                chooser:choices(filteredChoices)
            end
        end)

        chooser:choices(choices)
        chooser:show()
    else
        -- If Cursor is running, get all its windows
        local windows = cursor:allWindows()
        local choices = {}
        local openWindowTitles = {}

        -- Add existing windows as choices
        for i, win in ipairs(windows) do
            local title = win:title()
            -- Try to extract path information from window title or use empty string
            local path = ""

            -- Check if this window title matches any known project
            for _, project in ipairs(FileManager.getProjectsList()) do
                if title:match(project.name) then
                    path = project.path
                    break
                end
            end
            table.insert(choices, {
                text = title,
                subText = "Focus this " .. cursorAppName .. " window",
                window = win,
                type = "window",
                path = path
            })
            openWindowTitles[title] = true
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
            if not openWindowTitles[project.name] then
                table.insert(choices, {
                    text = project.name,
                    subText = "Open " .. project.path,
                    path = project.path,
                    type = "project"
                })
            end
        end

        local chooser = hs.chooser.new(function(choice)
            if not choice then return end

            if choice.type == "window" then
                -- Focus the selected window and update GitHub Desktop if we have a path
                if choice.path and choice.path ~= "" then
                    hs.execute("open -a '" .. githubAppName .. "' " .. choice.path)
                    hs.execute("open -a '" .. cursorAppName .. "' " .. choice.path)
                end
                choice.window:focus()
            elseif choice.type == "project" then
                -- Open the selected project with both GitHub Desktop and Cursor
                hs.execute("open -a '" .. githubAppName .. "' " .. choice.path)
                hs.execute("open -a '" .. cursorAppName .. "' " .. choice.path)
            elseif choice.type == "custom" then
                -- Open the custom path with both GitHub Desktop and Cursor
                hs.execute("open -a '" .. githubAppName .. "' " .. choice.path)
                hs.execute("open -a '" .. cursorAppName .. "' " .. choice.path)
            end
        end)

        -- Handle the query changed callback for custom paths
        chooser:queryChangedCallback(function(query)
            if query:match("^[~/]") then
                -- If query starts with / or ~, show only one option for custom path
                local customChoices = {}
                for k, v in pairs(choices) do customChoices[k] = v end
                table.insert(customChoices, 1, {
                    text = "Open custom path: " .. query,
                    subText = "Enter to open this path with " .. cursorAppName,
                    path = query,
                    type = "custom"
                })

                chooser:choices(customChoices)
            else
                -- Filter choices based on the query
                local filteredChoices = {}
                local hasMatches = false
                local matchingChoices = {}
                local separatorChoice = nil

                -- First find the separator and matching items
                for _, choice in ipairs(choices) do
                    if choice.disabled then
                        separatorChoice = choice
                    elseif choice.type == "project" or choice.type == "window" then
                        if choice.text:lower():find(query:lower(), 1, true) then
                            table.insert(matchingChoices, choice)
                            hasMatches = true
                        end
                    end
                end

                -- Add windows first if any
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "window" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- Add separator if we have any matches
                if hasMatches and separatorChoice then
                    table.insert(filteredChoices, separatorChoice)
                end

                -- Add projects
                for _, choice in ipairs(matchingChoices) do
                    if choice.type == "project" then
                        table.insert(filteredChoices, choice)
                    end
                end

                -- If no matches found and query is not empty, add custom path option
                if not hasMatches and query ~= "" then
                    table.insert(filteredChoices, {
                        text = "Open custom path: " .. query,
                        subText = "Enter to open this path with " .. cursorAppName,
                        path = query,
                        type = "custom"
                    })
                end

                chooser:choices(filteredChoices)
            end
        end)
        chooser:choices(choices)
        chooser:show()
    end
end
-- Application Launch Functions
function AppManager.open_github()
    AppManager.launchGitHubWithProjectSelection()
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

function AppManager.open_cursor_with_github()
    AppManager.launchCursorWithGitHubDesktop()
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

function AppManager.open_terminal()
    AppManager.launchOrFocusWithWindowSelection("Warp")
end

function AppManager.open_finder()
    AppManager.launchOrFocusWithWindowSelection("Finder")
end
-- Save in global environment for module reuse
_G.AppManager = AppManager
return AppManager
