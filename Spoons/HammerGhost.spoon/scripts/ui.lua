local ui = {}

-- Initialize the module with dependencies
function ui.init(deps)
    ui.xmlparser = deps.xmlparser
    return ui
end

-- Create toolbar for the main window
function ui.createToolbar(obj)
    local toolbar = hs.webview.toolbar.new("hammerghost", {
        {
            id = "addFolder",
            label = "Add Folder",
            image = hs.image.imageFromName("NSAddTemplate"),
            fn = function() obj:addFolder() end
        },
        {
            id = "addAction",
            label = "Add Action",
            image = hs.image.imageFromName("NSActionTemplate"),
            fn = function() obj:addAction() end
        },
        {
            id = "addSequence",
            label = "Add Sequence",
            image = hs.image.imageFromName("NSFlowViewTemplate"),
            fn = function() obj:addSequence() end
        },
        {
            id = "save",
            label = "Save",
            image = hs.image.imageFromName("NSSaveTemplate"),
            fn = function() obj:saveConfig() end
        },
        {
            id = "reload",
            label = "Reload",
            image = hs.image.imageFromName("NSRefreshTemplate"),
            fn = function() obj:reloadConfig() end
        }
    })
    :canCustomize(true)
    :autosaves(true)

    return toolbar
end

-- Create the main window for HammerGhost
function ui.createMainWindow(obj)
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()

    -- Create main webview window
    local webview = hs.webview.new({
        x = frame.x + (frame.w * 0.1),
        y = frame.y + (frame.h * 0.1),
        w = frame.w * 0.8,
        h = frame.h * 0.8
    }, { developerExtrasEnabled = true })

    if not webview then
        hs.logger.new("HammerGhost"):e("Failed to create webview")
        return nil
    end

    -- Set up webview properties
    webview:windowTitle("HammerGhost")
    webview:windowStyle(hs.webview.windowMasks.titled
                     | hs.webview.windowMasks.closable
                     | hs.webview.windowMasks.resizable)
    webview:allowTextEntry(true)
    webview:darkMode(true)

    -- Set up message handlers for UI interactions
    webview:navigationCallback(function(action, webview)
        local scheme, host, params = action:match("^([^:]+)://([^?]+)%??(.*)$")
        if scheme == "hammerspoon" then
            if host == "selectItem" then
                obj:selectItem(params)
            elseif host == "toggleItem" then
                obj:toggleItem(params)
            elseif host == "configureItem" then
                obj:configureItem(params)
            elseif host == "deleteItem" then
                obj:deleteItem(params)
            elseif host == "editItem" then
                obj:editItem(params)
            elseif host == "saveProperties" then
                local data = hs.json.decode(params)
                if data then
                    obj:saveProperties(data)
                end
            end
            return true
        end
        return false
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

    -- Create and attach toolbar
    local toolbar = ui.createToolbar(obj)
    webview:attachedToolbar(toolbar)

    -- Store the webview in the object
    obj.window = webview
    obj.toolbar = toolbar

    return webview
end

-- Function to update the UI with current macro tree
function ui.updateTree(obj)
    if not obj.window then return end

    local function generateHTML(items, level)
        local html = ""
        for _, item in ipairs(items) do
            local indent = string.rep("  ", level)
            local icon = item.type == "folder" and "📁" or (item.type == "sequence" and "📋" or "⚡")
            local selected = (obj.currentSelection and obj.currentSelection.id == item.id) and "selected" or ""

            html = html .. string.format([[
                <div class="tree-item %s" data-id="%s">
                    %s<span class="icon">%s</span>
                    <span class="name">%s</span>
                    <div class="actions">
                        <button onclick="editItem('%s', event)">✏️</button>
                        <button onclick="deleteItem('%s', event)">🗑️</button>
                    </div>
                </div>
            ]], selected, item.id, indent, icon, item.name, item.id, item.id)

            if item.children and #item.children > 0 then
                html = html .. generateHTML(item.children, level + 1)
            end
        end
        return html
    end

    local treeHTML = generateHTML(obj.macroTree, 0)
    obj.window:evaluateJavaScript(string.format([[
        document.getElementById('tree-panel').innerHTML = `%s`;
    ]], treeHTML))
end

-- Function to show properties panel for an item
function ui.showProperties(obj, item)
    if not obj.window then return end

    local propertiesHTML = string.format([[
        <form class="properties-form" onsubmit="saveProperties('%s'); return false;">
            <div class="form-group">
                <label for="name">Name</label>
                <input type="text" name="name" value="%s" required>
            </div>
            <div class="form-group">
                <label for="type">Type</label>
                <select name="type" %s>
                    <option value="folder" %s>Folder</option>
                    <option value="action" %s>Action</option>
                    <option value="sequence" %s>Sequence</option>
                </select>
            </div>
            %s
            <div class="form-buttons">
                <button type="submit" class="primary">Save</button>
                <button type="button" onclick="cancelEdit()">Cancel</button>
            </div>
        </form>
    ]],
    item.id,
    item.name or "",
    item.type == "action" and 'disabled="disabled"' or "",
    item.type == "folder" and 'selected="selected"' or "",
    item.type == "action" and 'selected="selected"' or "",
    item.type == "sequence" and 'selected="selected"' or "",
    ui.generateTypeSpecificFields(item)
    )

    obj.window:evaluateJavaScript(string.format([[
        document.getElementById('properties-panel').innerHTML = `%s`;
    ]], propertiesHTML))
end

-- Function to generate type-specific form fields
function ui.generateTypeSpecificFields(item)
    if item.type == "action" then
        return string.format([[
            <div class="form-group">
                <label for="shortcut">Keyboard Shortcut</label>
                <input type="text" name="shortcut" value="%s" placeholder="e.g., cmd+shift+a">
            </div>
            <div class="form-group">
                <label for="script">Script</label>
                <textarea name="script" rows="10">%s</textarea>
            </div>
        ]], item.shortcut or "", item.script or "")
    elseif item.type == "sequence" then
        return string.format([[
            <div class="form-group">
                <label for="delay">Delay (ms)</label>
                <input type="number" name="delay" value="%s" min="0">
            </div>
            <div class="form-group">
                <label>Steps</label>
                <div id="sequence-steps">%s</div>
                <button type="button" onclick="addSequenceStep()">Add Step</button>
            </div>
        ]], item.delay or "0", ui.generateSequenceSteps(item))
    end
    return ""
end

-- Function to generate sequence steps HTML
function ui.generateSequenceSteps(item)
    if not item.steps then return "" end

    local stepsHTML = ""
    for i, step in ipairs(item.steps) do
        stepsHTML = stepsHTML .. string.format([[
            <div class="sequence-step">
                <input type="text" name="step_%d" value="%s">
                <button type="button" onclick="removeStep(%d)">Remove</button>
            </div>
        ]], i, step, i)
    end
    return stepsHTML
end

-- Function to handle drag and drop operations
function ui.setupDragAndDrop(obj)
    obj.window:evaluateJavaScript([[
        function handleDragStart(event) {
            event.dataTransfer.setData('text/plain', event.target.dataset.id);
            event.target.classList.add('dragging');
        }

        function handleDragOver(event) {
            event.preventDefault();
            const dropZone = event.target.closest('.tree-item');
            if (dropZone) {
                dropZone.classList.add('drag-over');
            }
        }

        function handleDragLeave(event) {
            const dropZone = event.target.closest('.tree-item');
            if (dropZone) {
                dropZone.classList.remove('drag-over');
            }
        }

        function handleDrop(event) {
            event.preventDefault();
            const dropZone = event.target.closest('.tree-item');
            if (dropZone) {
                dropZone.classList.remove('drag-over');
                const sourceId = event.dataTransfer.getData('text/plain');
                const targetId = dropZone.dataset.id;
                const rect = dropZone.getBoundingClientRect();
                const y = event.clientY;
                const position = y < rect.top + rect.height / 3 ? 'before' :
                               y > rect.bottom - rect.height / 3 ? 'after' : 'inside';
                
                window.location.href = `hammerspoon://moveItem?sourceId=${sourceId}&targetId=${targetId}&position=${position}`;
            }
        }
    ]])
end

-- Function to handle item selection
function ui.handleSelection(obj, itemId)
    if not obj.window then return end

    obj.window:evaluateJavaScript(string.format([[
        const items = document.querySelectorAll('.tree-item');
        items.forEach(item => item.classList.remove('selected'));
        const selectedItem = document.querySelector(`.tree-item[data-id="%s"]`);
        if (selectedItem) {
            selectedItem.classList.add('selected');
            selectedItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    ]], itemId))
end

-- Function to show error message in UI
function ui.showError(obj, message)
    if not obj.window then return end

    obj.window:evaluateJavaScript(string.format([[
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = '%s';
        document.body.appendChild(errorDiv);
        setTimeout(() => errorDiv.remove(), 3000);
    ]], message))
end

-- Function to refresh properties panel
function ui.refreshProperties(obj)
    if not obj.window or not obj.currentSelection then return end
    ui.showProperties(obj, obj.currentSelection)
end

-- Function to handle item expansion/collapse
function ui.toggleItemExpansion(obj, itemId)
    if not obj.window then return end

    obj.window:evaluateJavaScript(string.format([[
        const item = document.querySelector(`.tree-item[data-id="%s"]`);
        if (item) {
            const children = item.nextElementSibling;
            if (children && children.classList.contains('children')) {
                children.style.display = children.style.display === 'none' ? 'block' : 'none';
                item.querySelector('.icon').textContent = 
                    children.style.display === 'none' ? '📁' : '📂';
            }
        }
    ]], itemId))
end

-- Function to initialize UI event handlers
function ui.initializeEventHandlers(obj)
    if not obj.window then return end

    -- Set up drag and drop
    ui.setupDragAndDrop(obj)

    -- Add keyboard shortcuts
    obj.window:evaluateJavaScript([[
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Delete' && document.activeElement.tagName !== 'INPUT' && 
                document.activeElement.tagName !== 'TEXTAREA') {
                const selected = document.querySelector('.tree-item.selected');
                if (selected) {
                    window.location.href = 'hammerspoon://deleteItem?' + selected.dataset.id;
                }
            }
        });
    ]])

    -- Initialize context menu
    ui.setupContextMenu(obj)
end

-- Function to set up context menu
function ui.setupContextMenu(obj)
    if not obj.window then return end

    obj.window:evaluateJavaScript([[
        document.addEventListener('contextmenu', function(event) {
            const treeItem = event.target.closest('.tree-item');
            if (treeItem) {
                event.preventDefault();
                const itemId = treeItem.dataset.id;
                window.location.href = 'hammerspoon://showContextMenu?' + itemId;
            }
        });
    ]])
end

return ui
