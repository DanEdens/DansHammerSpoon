-- FileManager.lua - File management utilities with centralized project management
-- Using singleton pattern to avoid multiple initializations
-- Use HyperLogger for clickable debugging logs
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()
-- Check if module is already initialized
if _G.FileManager then
    log:d('Returning existing FileManager module')
    return _G.FileManager
end
log:i('Initializing file management system')

local FileManager = {}

-- Configuration
local editor = "cursor"
log:d('Default editor set to: ' .. editor)
-- local seatOfMadness = os.getenv("SEAT_OF_MADNESS")
local seatOfMadness = "/Users/d.edens/lab/madness_interactive"
-- local seatOfTest = os.getenv("SEAT_OF_TEST")
local seatOfTest = "/Users/d.edens/lab/regressiontestkit"

-- State
local selectedFile = nil
local fileChooser = nil
local lastSelected = {
    file = nil,
    project = nil,
    editor = nil
}
-- File Lists
local fileList = {
    { name = "init.lua",       path = "~/.hammerspoon/init.lua" },
    { name = "global hotkeys", path = "~/.hammerspoon/hotkeys.lua" },
    { name = "zshenv",         path = "~/.zshenv" },
    { name = "File Manager",   path = "~/.hammerspoon/FileManager.lua" },
    { name = "zshrc",          path = "~/.zshrc" },
    { name = "bash_aliases",   path = "~/.bash_aliases" },
    { name = "goosehints",     path = "~/.config/goose/.goosehints" },
    { name = "tasks",          path = "~/lab/regressiontestkit/tasks.py" },
    { name = "ssh config",     path = "~/.ssh/config" },
    -- { name = "RTK_rules",      path = "~/lab/regressiontestkit/regressiontest/.cursorrules" },
    { name = "mad_rules",      path = seatOfMadness .. "/.cursor/rules" },
    { name = "swarmonomicon",  path = seatOfMadness .. "/projects/common/swarmonomicon/.cursorrules" },
}

-- Fallback projects list (used when OmniLadle is not available)
local fallback_projects_list = {
    -- Core projects
    { name = "madness_interactive",        path = seatOfMadness },
    { name = ".hammerspoon",        path = "~/.hammerspoon" },
    { name = "Chat History",               path = seatOfMadness .. "/docs/cursor_chathistory" },
    { name = "Todomill_projectorium",      path = seatOfMadness .. "/projects/common/Omnispindle/Todomill_projectorium" },
    { name = "Inventorium",                path = seatOfMadness .. "/projects/common/Inventorium" },
    { name = "Omnispindle",                path = seatOfMadness .. "/projects/common/Omnispindle" },
    { name = "Swarmonomicon",              path = seatOfMadness .. "/projects/common/Swarmonomicon" },
    { name = "Whispermind_Conduit",        path = seatOfMadness .. "/projects/common/Whispermind_Conduit" },
    { name = "SwarmDesk",                  path = seatOfMadness .. "/projects/common/SwarmDesk" },
    { name = "regressiontestkit",          path = seatOfTest },
    -- RegressionTestKit ecosystem
    { name = "OculusTestKit",              path = seatOfTest .. "/OculusTestKit" },
    { name = "phoenix",                    path = seatOfTest .. "/phoenix" },
    { name = "rust_ingest",                path = seatOfTest .. "/rust_ingest" },
    { name = "rtk-docs-host",              path = seatOfTest .. "/rtk-docs-host" },
    { name = "zsh-autocompletions",        path = "/opt/homebrew/share/zsh/site-functions" },
    { name = "gateway_metrics",            path = seatOfTest .. "/gateway_metrics" },
    { name = "http-dump-server",           path = seatOfTest .. "/http-dump-server" },
    { name = "teltonika_wrapper",          path = seatOfTest .. "/teltonika_wrapper" },
    { name = "ohmura-firmware",            path = seatOfTest .. "/ohmura-firmware" },
    { name = "saws",                       path = seatOfTest .. "/saws" },
    { name = "prod-ed-configs",            path = seatOfTest .. "/prod-ed-configs" },

    -- Swarmonomicon ecosystem
    -- { name = "swarm-browser-agent", path = "~/lab/madness_interactive/projects/common/Swarmonomicon/browser-agent" },
    -- { name = "swarm-todo-server",   path = "~/lab/madness_interactive/projects/common/Swarmonomicon/Omnispindle" },
    -- { name = "swarm-projects",      path = "~/lab/madness_interactive/projects/common/Swarmonomicon/projects" },
    -- { name = "lego-vision",         path = "~/lab/madness_interactive/projects/common/Swarmonomicon/projects/python/lego-vision" },

    -- Other major projects
    { name = "Cogwyrm",                    path = seatOfMadness .. "/projects/mobile/Cogwyrm" },
    -- Rust projects
    { name = "Tinker",                     path = seatOfMadness .. "/projects/rust/Tinker" },
    { name = "EventGhost-Rust",            path = seatOfMadness .. "/projects/rust/EventGhost-Rust" },

    -- Python projects
    -- { name = "fastmcp-balena-cli",  path = seatOfMadness .. "/projects/python/fastmcp-balena-cli" },
    { name = "mcp-personal-jira",          path = seatOfMadness .. "/projects/python/mcp-personal-jira" },
    -- { name = "LegoScry",            path = seatOfMadness .. "/projects/python/LegoScry" },
    -- { name = "local-ai",            path = seatOfMadness .. "/projects/python/local-ai" },
    -- { name = "simple-mqtt-server",  path = seatOfMadness .. "/projects/python/simple-mqtt-server-agent" },
    { name = "mqtt-get-var",               path = seatOfMadness .. "/projects/python/mqtt-get-var" },
    { name = "dvtTestKit",                 path = seatOfMadness .. "/projects/python/dvtTestKit" },
    -- { name = "SeleniumPageUtils",   path = seatOfMadness .. "/projects/python/SeleniumPageUtilities" },
    -- { name = "MqttLogger",          path = seatOfMadness .. "/projects/python/MqttLogger" },
    { name = "EventGhost-py",              path = seatOfMadness .. "/projects/python/EventGhost" },
    -- { name = "py-games",            path = seatOfMadness .. "/projects/python/games" },
    -- { name = "snowball-snowman",    path = seatOfMadness .. "/projects/python/games/snowball_snowman" },

    -- Project root directories
    { name = "projects-root",              path = seatOfMadness .. "/projects" },
    { name = "common-projects",            path = seatOfMadness .. "/projects/common" },
    { name = "mobile-projects",            path = seatOfMadness .. "/projects/mobile" },
    { name = "python-projects",            path = seatOfMadness .. "/projects/python" },
    -- { name = "nodeJS-projects",     path = "~/lab/madness_interactive/projects/nodeJS" },
    { name = "lua-projects",               path = seatOfMadness .. "/projects/lua" },
    { name = "powershell-projects",        path = seatOfMadness .. "/projects/powershell" },
    -- { name = "OS-projects",         path = seatOfMadness .. "/projects/OS" },
    { name = "rust-projects",              path = seatOfMadness .. "/projects/rust" },
    { name = "tasker-projects",            path = seatOfMadness .. "/projects/tasker" },

    -- Lua projects
    -- { name = "LGS_script_template", path = "~/lab/madness_interactive/projects/lua/LGS_script_template" },
    { name = "hammerspoon-proj",           path = seatOfMadness .. "/projects/lua/hammerspoon" },

    -- PowerShell projects
    { name = "WinSystemSnapshot",          path = seatOfMadness .. "/projects/powershell/WinSystemSnapshot" },

    -- OS projects
    { name = "DisplayPhotoTime",           path = seatOfMadness .. "/projects/OS/windows/DisplayPhotoTime" },

    -- Tasker projects
    { name = "Verbatex",                   path = seatOfMadness .. "/projects/tasker/Verbatex" },
    { name = "RunedManifold",              path = seatOfMadness .. "/projects/tasker/RunedManifold" },
    { name = "PhilosophersAmpoule",        path = seatOfMadness .. "/projects/tasker/PhilosophersAmpoule" },
    { name = "Ludomancery",                path = seatOfMadness .. "/projects/tasker/Ludomancery" },
    { name = "Fragmentarium",              path = seatOfMadness .. "/projects/tasker/Fragmentarium" },
    { name = "EntropyVector",              path = seatOfMadness .. "/projects/tasker/EntropyVector" },
    { name = "ContextOfficium",            path = seatOfMadness .. "/projects/tasker/ContextOfficium" },
    { name = "AnathemaHexVault",           path = seatOfMadness .. "/projects/tasker/AnathemaHexVault" },
    -- Typescript projects
    -- { name = "typescript-projects",        path = "~/lab/madness_interactive/projects/typescript" },
    { name = "RaidShadowLegendsButItsMCP", path = seatOfMadness .. "/projects/typescript/RaidShadowLegendsButItsMCP" },
}

local editorList = {
    { name = "Visual Studio Code",        command = "code" },
    { name = "cursor",                    command = "cursor" },
    { name = "nvim",                      command = "nvim" },
    { name = "PyCharm Community Edition", command = "pycharm" },
    { name = "Void",                      command = "void" }
}

-- Helper Functions
function FileManager.getEditor()
    log:d('Getting current editor: ' .. editor)
    return editor
end

function FileManager.setEditor(newEditor)
    log:i('Setting editor to: ' .. newEditor)
    editor = newEditor
    lastSelected.editor = newEditor
end

-- OmniLadle integration for centralized project management
local function getOmniLadle()
    -- Check if OmniLadle is available globally (loaded in init.lua)
    if _G.OmniLadle then
        return _G.OmniLadle
    end

    -- Try to access through spoon system
    if spoon and spoon.OmniLadle then
        return spoon.OmniLadle
    end

    log:w('OmniLadle not available for FileManager - using fallback project list')
    return nil
end

-- Dynamic project list function that tries OmniLadle first, then fallbacks
function FileManager.getProjectsList()
    log:d('Getting projects list for FileManager')

    -- Try OmniLadle first for real-time project management
    local omniLadle = getOmniLadle()
    if omniLadle then
        local projects = omniLadle:getProjectsList()
        if projects and #projects > 0 then
            log:i('FileManager using ' .. #projects .. ' projects from OmniLadle')
            return projects
        else
            log:w('OmniLadle returned empty or invalid project list, using fallback')
        end
    end

    -- Fallback to hardcoded list
    log:i('FileManager using fallback project list (' .. #fallback_projects_list .. ' projects)')
    return fallback_projects_list
end

function FileManager.getLastSelected()
    log:d('Getting last selected item')
    return lastSelected
end

-- File Management Functions
function FileManager.openSelectedFile()
    if selectedFile ~= nil then
        log:i('Opening selected file: ' .. selectedFile.text .. ' with ' .. editor)
        lastSelected.file = selectedFile
        hs.execute("open -a '" .. editor .. "' " .. selectedFile.path)
    else
        log:w('No file selected, showing file menu')
        FileManager.showFileMenu()
    end
end

function FileManager.showFileMenu()
    log:i('Showing file selection menu')
    local choices = {}
    for _, file in ipairs(fileList) do
        table.insert(choices, {
            text = file.name,
            subText = "Edit this file",
            path = file.path
        })
    end

    if not fileChooser then
        log:d('Creating new file chooser')
        fileChooser = hs.chooser.new(function(choice)
            if choice then
                log:d('File selected: ' .. choice.text)
                selectedFile = choice
                lastSelected.file = choice
                FileManager.openSelectedFile()
                fileChooser:hide()
            else
                log:d('File selection canceled')
            end
        end)
    end
    fileChooser:choices(choices)
    fileChooser:show()
end

function FileManager.showEditorMenu()
    log:i('Showing editor selection menu')
    -- Ensure editorList exists and is not empty
    if not editorList or #editorList == 0 then
        log:e('Editor list is empty or not available')
        hs.alert.show("Error: No editors available")
        return
    end
    local choices = {}
    for _, editorOption in ipairs(editorList) do
        -- Validate each editor option
        if editorOption and editorOption.name and editorOption.command then
            table.insert(choices, {
                text = editorOption.name,
                subText = "Select this editor",
                command = editorOption.command
            })
        else
            log:w('Invalid editor option found, skipping:', hs.inspect(editorOption))
        end
    end

    -- Check if we have any valid choices
    if #choices == 0 then
        log:e('No valid editor choices available')
        hs.alert.show("Error: No valid editors found")
        return
    end

    -- Create the chooser with proper closure handling
    local chooser = nil

    local success, error_msg = pcall(function()
        chooser = hs.chooser.new(function(choice)
            if choice then
                log:i('Editor selected: ' .. tostring(choice.text))
                editor = choice.command
                lastSelected.editor = choice
                hs.alert.show("Editor set to: " .. tostring(editor))
                -- Hide the chooser safely
                if chooser then
                    pcall(function() chooser:hide() end)
                end
            else
                log:d('Editor selection canceled')
            end
        end)
    end)

    if not success or not chooser then
        log:e('Failed to create editor chooser:', error_msg)
        hs.alert.show("Error: Could not create editor menu")
        return
    end

    -- Set choices and show the chooser
    local success2, error_msg2 = pcall(function()
        chooser:choices(choices)
        chooser:show()
    end)

    if not success2 then
        log:e('Failed to show editor chooser:', error_msg2)
        hs.alert.show("Error: Could not display editor menu")
        return
    end

    log:d('Editor menu displayed successfully with', #choices, 'options')
end

function FileManager.showEditorMenuSafe()
    log:i('Showing editor menu with error handling')
    local success, error_msg = pcall(function()
        FileManager.showEditorMenu()
    end)
    if not success then
        log:e('Error calling FileManager.showEditorMenu:', error_msg)
        hs.alert.show("Error opening editor menu: " .. tostring(error_msg))
    end
end
function FileManager.openMostRecentImage()
    log:i('Attempting to open most recent image from Desktop')
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    log:d('Desktop path: ' .. desktopPath)

    -- Look for multiple image formats, not just PNG
    local cmd = string.format(
    "find '%s' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \\) -exec ls -t {} + | head -n 1",
        desktopPath)
    log:d('Executing command: ' .. cmd)

    local output, status, type, rc = hs.execute(cmd)

    if status and output and output ~= "" then
        -- Trim whitespace and newlines from the output
        local filePath = output:match("^%s*(.-)%s*$")
        if filePath and filePath ~= "" then
            log:i('Opening image: ' .. filePath)
            lastSelected.file = { name = "recent_image", path = filePath }
            -- Properly quote the file path to handle spaces
            local openCmd = string.format("open '%s'", filePath)
            log:d('Executing open command: ' .. openCmd)
            hs.execute(openCmd)
        else
            log:w('No valid file path found in command output')
            hs.alert.show("No recent images found on Desktop")
        end
    else
        log:w('Command failed or no images found. Status: ' .. tostring(status) .. ', RC: ' .. tostring(rc))
        hs.alert.show("No recent images found on Desktop")
    end
end

function FileManager.copyMostRecentImage()
    log:i('Attempting to copy most recent image from Desktop to clipboard')
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    log:d('Desktop path: ' .. desktopPath)

    -- Look for multiple image formats, not just PNG
    local cmd = string.format(
        "find '%s' -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tiff' \\) -exec ls -t {} + | head -n 1",
        desktopPath)
    log:d('Executing command: ' .. cmd)

    local output, status, type, rc = hs.execute(cmd)

    if status and output and output ~= "" then
        -- Trim whitespace and newlines from the output
        local filePath = output:match("^%s*(.-)%s*$")
        if filePath and filePath ~= "" then
            log:i('Copying image to clipboard: ' .. filePath)
            lastSelected.file = { name = "recent_image_copied", path = filePath }

            -- Load the image and copy to clipboard
            local image = hs.image.imageFromPath(filePath)
            if image then
                hs.pasteboard.writeObjects(image)
                log:i('Successfully copied image to clipboard')
                hs.alert.show("Image copied to clipboard: " .. hs.fs.displayName(filePath))
            else
                log:e('Failed to load image from path: ' .. filePath)
                hs.alert.show("Error: Could not load image file")
            end
        else
            log:w('No valid file path found in command output')
            hs.alert.show("No recent images found on Desktop")
        end
    else
        log:w('Command failed or no images found. Status: ' .. tostring(status) .. ', RC: ' .. tostring(rc))
        hs.alert.show("No recent images found on Desktop")
    end
end
-- Save in global environment for module reuse
_G.FileManager = FileManager
return FileManager
