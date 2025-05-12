-- FileManager.lua - File management utilities
-- Using singleton pattern to avoid multiple initializations
-- Use HyperLogger for clickable debugging logs
local HyperLogger = require('HyperLogger')
local log = HyperLogger.new()
-- Check if module is already initialized
if _G.FileManager then
    return _G.FileManager
end
log:d('Initializing file management system')

local FileManager = {}

-- Configuration
local editor = "cursor"
log:d('Default editor set to: ' .. editor)

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
    { name = "File Manager",      path = "/Users/d.edens/.hammerspoon/FileManager.lua" },
    { name = "zshenv",         path = "~/.zshenv" },
    { name = "zshrc",          path = "~/.zshrc" },
    { name = "bash_aliases",   path = "~/.bash_aliases" },
    { name = "goosehints",     path = "~/.config/goose/.goosehints" },
    { name = "tasks",          path = "~/lab/regressiontestkit/tasks.py" },
    { name = "ssh config",     path = "~/.ssh/config" },
    { name = "RTK_rules",      path = "~/lab/regressiontestkit/regressiontest/.cursorrules" },
    { name = "mad_rules",      path = "~/lab/madness_interactive/.cursorrules" },
    { name = "swarmonomicon",  path = "~/lab/madness_interactive/projects/common/swarmonomicon/.cursorrules" },
}

local projects_list = {
    -- Core projects
    { name = ".hammerspoon",        path = "~/.hammerspoon" },
    { name = "Chat History",        path = "/Users/d.edens/lab/madness_interactive/docs/cursor_chathistory" },
    { name = "Todomill_projectorium", path = "~/lab/madness_interactive/projects/python/Omnispindle/Todomill_projectorium" },
    { name = "Inventorium",           path = "~/lab/madness_interactive/projects/common/Inventorium" },
    { name = "Omnispindle",         path = "~/lab/madness_interactive/projects/python/Omnispindle" },
    { name = "Swarmonomicon",       path = "~/lab/madness_interactive/projects/common/Swarmonomicon" },
    { name = "lab",                 path = "~/lab" },
    { name = "regressiontestkit",   path = "~/lab/regressiontestkit" },
    { name = "gateway_metrics",       path = "~/lab/regressiontestkit/gateway_metrics" },
    { name = "madness_interactive", path = "~/lab/madness_interactive" },
    -- RegressionTestKit ecosystem
    { name = "OculusTestKit",       path = "~/lab/regressiontestkit/OculusTestKit" },
    { name = "phoenix",             path = "~/lab/regressiontestkit/phoenix" },
    { name = "hammerspoon-vs-extension",   path = "/Users/d.edens/.cursor/extensions/virgilsisoe.hammerspoon-0.5.2" },
    { name = "rust_ingest",         path = "~/lab/regressiontestkit/rust_ingest" },
    { name = "rtk-docs-host",       path = "~/lab/regressiontestkit/rtk-docs-host" },
    { name = "gateway_metrics",     path = "~/lab/regressiontestkit/gateway_metrics" },
    { name = "http-dump-server",    path = "~/lab/regressiontestkit/http-dump-server" },
    { name = "teltonika_wrapper",   path = "~/lab/regressiontestkit/teltonika_wrapper" },
    { name = "ohmura-firmware",     path = "~/lab/regressiontestkit/ohmura-firmware" },
    { name = "saws",                path = "~/lab/regressiontestkit/saws" },
    { name = "prod-ed-configs",     path = "~/lab/regressiontestkit/prod-ed-configs" },

    -- Swarmonomicon ecosystem
    -- { name = "swarm-browser-agent", path = "~/lab/madness_interactive/projects/common/Swarmonomicon/browser-agent" },
    -- { name = "swarm-todo-server",   path = "~/lab/madness_interactive/projects/common/Swarmonomicon/Omnispindle" },
    -- { name = "swarm-projects",      path = "~/lab/madness_interactive/projects/common/Swarmonomicon/projects" },
    -- { name = "lego-vision",         path = "~/lab/madness_interactive/projects/common/Swarmonomicon/projects/python/lego-vision" },

    -- Other major projects
    { name = "Cogwyrm",             path = "~/lab/madness_interactive/projects/mobile/Cogwyrm" },
    -- Rust projects
    { name = "Tinker",              path = "~/lab/madness_interactive/projects/rust/Tinker" },
    { name = "EventGhost-Rust",     path = "~/lab/madness_interactive/projects/rust/EventGhost-Rust" },

    -- Python projects
    -- { name = "fastmcp-balena-cli",  path = "~/lab/madness_interactive/projects/python/fastmcp-balena-cli" },
    { name = "mcp-personal-jira",   path = "~/lab/madness_interactive/projects/python/mcp-personal-jira" },
    -- { name = "LegoScry",            path = "~/lab/madness_interactive/projects/python/LegoScry" },
    -- { name = "local-ai",            path = "~/lab/madness_interactive/projects/python/local-ai" },
    -- { name = "simple-mqtt-server",  path = "~/lab/madness_interactive/projects/python/simple-mqtt-server-agent" },
    { name = "mqtt-get-var",        path = "~/lab/madness_interactive/projects/python/mqtt-get-var" },
    { name = "dvtTestKit",          path = "~/lab/madness_interactive/projects/python/dvtTestKit" },
    -- { name = "SeleniumPageUtils",   path = "~/lab/madness_interactive/projects/python/SeleniumPageUtilities" },
    -- { name = "MqttLogger",          path = "~/lab/madness_interactive/projects/python/MqttLogger" },
    { name = "EventGhost-py",       path = "~/lab/madness_interactive/projects/python/EventGhost" },
    -- { name = "py-games",            path = "~/lab/madness_interactive/projects/python/games" },
    -- { name = "snowball-snowman",    path = "~/lab/madness_interactive/projects/python/games/snowball_snowman" },

    -- Project root directories
    { name = "projects-root",       path = "~/lab/madness_interactive/projects" },
    { name = "common-projects",     path = "~/lab/madness_interactive/projects/common" },
    { name = "mobile-projects",     path = "~/lab/madness_interactive/projects/mobile" },
    { name = "python-projects",     path = "~/lab/madness_interactive/projects/python" },
    -- { name = "nodeJS-projects",     path = "~/lab/madness_interactive/projects/nodeJS" },
    { name = "lua-projects",        path = "~/lab/madness_interactive/projects/lua" },
    { name = "powershell-projects", path = "~/lab/madness_interactive/projects/powershell" },
    -- { name = "OS-projects",         path = "~/lab/madness_interactive/projects/OS" },
    { name = "rust-projects",       path = "~/lab/madness_interactive/projects/rust" },
    { name = "tasker-projects",     path = "~/lab/madness_interactive/projects/tasker" },

    -- Lua projects
    -- { name = "LGS_script_template", path = "~/lab/madness_interactive/projects/lua/LGS_script_template" },
    { name = "hammerspoon-proj",    path = "~/lab/madness_interactive/projects/lua/hammerspoon" },

    -- PowerShell projects
    { name = "WinSystemSnapshot",   path = "~/lab/madness_interactive/projects/powershell/WinSystemSnapshot" },

    -- OS projects
    { name = "DisplayPhotoTime",    path = "~/lab/madness_interactive/projects/OS/windows/DisplayPhotoTime" },

    -- Tasker projects
    { name = "Verbatex",            path = "~/lab/madness_interactive/projects/tasker/Verbatex" },
    { name = "RunedManifold",       path = "~/lab/madness_interactive/projects/tasker/RunedManifold" },
    { name = "PhilosophersAmpoule", path = "~/lab/madness_interactive/projects/tasker/PhilosophersAmpoule" },
    { name = "Ludomancery",         path = "~/lab/madness_interactive/projects/tasker/Ludomancery" },
    { name = "Fragmentarium",       path = "~/lab/madness_interactive/projects/tasker/Fragmentarium" },
    { name = "EntropyVector",       path = "~/lab/madness_interactive/projects/tasker/EntropyVector" },
    { name = "ContextOfficium",     path = "~/lab/madness_interactive/projects/tasker/ContextOfficium" },
    { name = "AnathemaHexVault",    path = "~/lab/madness_interactive/projects/tasker/AnathemaHexVault" },
    -- Typescript projects
    { name = "typescript-projects",        path = "~/lab/madness_interactive/projects/typescript" },
    { name = "RaidShadowLegendsButItsMCP", path = "~/lab/madness_interactive/projects/typescript/RaidShadowLegendsButItsMCP" },
}

local editorList = {
    { name = "Visual Studio Code",        command = "code" },
    { name = "cursor",                    command = "cursor" },
    { name = "nvim",                      command = "nvim" },
    { name = "PyCharm Community Edition", command = "pycharm" }
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

function FileManager.getProjectsList()
    log:d('Getting projects list')
    return projects_list
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
    local choices = {}
    for _, editorOption in ipairs(editorList) do
        table.insert(choices, {
            text = editorOption.name,
            subText = "Select this editor",
            command = editorOption.command
        })
    end

    local chooser = hs.chooser.new(function(choice)
        if choice then
            log:i('Editor selected: ' .. choice.text)
            editor = choice.command
            lastSelected.editor = choice
            hs.alert.show("Editor set to: " .. editor)
            chooser:hide()
        else
            log:d('Editor selection canceled')
        end
    end)
    chooser:choices(choices)
    chooser:show()
end

function FileManager.openMostRecentImage()
    log:i('Attempting to open most recent image from Desktop')
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    log:d('Desktop path: ' .. desktopPath)

    local filePath = hs.execute("ls -t " .. desktopPath .. "/*.png | head -n 1")
    if filePath ~= "" then
        log:i('Opening image: ' .. filePath)
        lastSelected.file = { name = "recent_image", path = filePath }
        hs.execute("open " .. filePath)
    else
        log:w('No PNG images found on Desktop')
        hs.alert.show("No PNG images found on Desktop")
    end
end

-- Save in global environment for module reuse
_G.FileManager = FileManager
return FileManager
