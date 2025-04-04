local log = hs.logger.new('FileManager', 'debug')
log.i('Initializing file management system')

local FileManager = {}

-- Configuration
local editor = "cursor"

-- File Lists
local fileList = {
    { name = "init.lua",       path = "~/.hammerspoon/init.lua" },
    { name = "global hotkeys", path = "~/.hammerspoon/hotkeys.lua" },
    { name = "hs config",      path = "~/.hammerspoon/config.lua" },
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
    { name = "lab",                 path = "~/lab" },
    { name = "regressiontestkit",   path = "~/lab/regressiontestkit" },
    { name = "OculusTestKit",       path = "~/lab/regressiontestkit/OculusTestKit" },
    { name = ".hammerspoon",        path = "~/.hammerspoon" },
    { name = "fastmcp-todo-server", path = "/Users/d.edens/lab/madness_interactive/projects/python/fastmcp-todo-server" },
    { name = "madness_interactive", path = "~/lab/madness_interactive" },
    { name = "swarmonomicon",       path = "~/lab/madness_interactive/projects/common/swarmonomicon" },
    { name = "Cogwyrm",             path = "~/lab/madness_interactive/projects/mobile/Cogwyrm" },
}

local editorList = {
    { name = "Visual Studio Code",        command = "Visual Studio Code" },
    { name = "cursor",                    command = "cursor" },
    { name = "nvim",                      command = "nvim" },
    { name = "PyCharm Community Edition", command = "PyCharm Community Edition" }
}

-- State
local selectedFile = nil
local fileChooser = nil

-- Helper Functions
function FileManager.getEditor()
    return editor
end

function FileManager.setEditor(newEditor)
    editor = newEditor
end

function FileManager.getProjectsList()
    return projects_list
end

-- File Management Functions
function FileManager.openSelectedFile()
    if selectedFile ~= nil then
        hs.execute("open -a '" .. editor .. "' " .. selectedFile.path)
    else
        FileManager.showFileMenu()
    end
end

function FileManager.showFileMenu()
    local choices = {}
    for _, file in ipairs(fileList) do
        table.insert(choices, {
            text = file.name,
            subText = "Edit this file",
            path = file.path
        })
    end

    if not fileChooser then
        fileChooser = hs.chooser.new(function(choice)
            if choice then
                selectedFile = choice
                FileManager.openSelectedFile()
                fileChooser:hide()
            end
        end)
    end
    fileChooser:choices(choices)
    fileChooser:show()
end

function FileManager.showEditorMenu()
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
            editor = choice.command
            hs.alert.show("Editor set to: " .. editor)
            chooser:hide()
        end
    end)
    chooser:choices(choices)
    chooser:show()
end

function FileManager.openMostRecentImage()
    local desktopPath = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/Desktop")
    local filePath = hs.execute("ls -t " .. desktopPath .. "/*.png | head -n 1")
    print("filePath: " .. filePath)
    if filePath ~= "" then
        hs.execute("open " .. filePath)
    else
        hs.alert.show("No recent image found on the desktop")
    end
end

return FileManager
