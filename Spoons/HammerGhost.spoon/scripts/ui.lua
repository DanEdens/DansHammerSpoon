local ui = {}

-- Initialize the module with dependencies
function ui.init(deps)
    ui.xmlparser = deps.xmlparser
    return ui
end

-- Create the main window for HammerGhost
function ui.createMainWindow(obj)
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- Create main window
    local webview = hs.webview.new({
        x = frame.x + (frame.w * 0.1),
        y = frame.y + (frame.h * 0.1),
        w = frame.w * 0.8,
        h = frame.h * 0.8
    }, { developerExtrasEnabled = true })

    if not webview then
        hs.logger.new("HammerGhost"):e("Failed to create webview")
        return nil  -- Return nil if webview creation fails
    end

    -- Set up webview
    webview:windowTitle("HammerGhost")
    webview:windowStyle(hs.webview.windowMasks.titled
                     | hs.webview.windowMasks.closable
                     | hs.webview.windowMasks.resizable)
    webview:allowTextEntry(true)
    webview:darkMode(true)

    -- Set up message handlers
    webview:navigationCallback(function(action, webview)
        -- Handle navigation actions...
    end)

    -- Load HTML content
    local filePath = hs.spoons.resourcePath("../assets/index.html")
    if not hs.fs.attributes(filePath) then
        hs.logger.new("HammerGhost"):e("index.html does not exist at: " .. filePath)
        webview:html("<html><body style='background: #1e1e1e; color: #d4d4d4;'><h1>Error loading UI</h1></body></html>")
        return webview
    end

    local htmlFile = io.open(filePath, "r")
    if htmlFile then
        local content = htmlFile:read("*all")
        htmlFile:close()
        webview:html(content)
    else
        hs.logger.new("HammerGhost"):e("Failed to load index.html")
        webview:html("<html><body style='background: #1e1e1e; color: #d4d4d4;'><h1>Error loading UI</h1></body></html>")
    end

    -- Store the webview
    obj.window = webview  -- Store the webview in obj.window

    -- Create toolbar
    obj:createToolbar()

    return webview  -- Return the webview object
end

return ui
