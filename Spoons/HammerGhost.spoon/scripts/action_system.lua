-- Action System for HammerGhost
-- Handles defining, managing, and executing actions

local actionSystem = {}

-- Internal action registry
actionSystem.registry = {}
actionSystem.triggers = {}
actionSystem.running = {}

-- Register a new action type
function actionSystem:registerActionType(id, metadata)
    if self.registry[id] then
        return false, "Action type already registered: " .. id
    end

    self.registry[id] = {
        id = id,
        name = metadata.name or id,
        description = metadata.description or "",
        icon = metadata.icon or "⚡",
        category = metadata.category or "General",
        parameters = metadata.parameters or {},
        handler = metadata.handler or function() return false, "No handler implemented" end,
        validate = metadata.validate or function() return true end
    }

    return true
end

-- Execute an action
function actionSystem:executeAction(action)
    if not action or not action.type then
        return false, "Invalid action"
    end

    local actionType = self.registry[action.type]
    if not actionType then
        return false, "Unknown action type: " .. action.type
    end

    -- Validate parameters
    local isValid, validationError = actionType.validate(action.parameters or {})
    if not isValid then
        return false, validationError or "Parameter validation failed"
    end

    -- Generate execution ID for tracking
    local executionId = os.time() .. "-" .. math.random(1000, 9999)

    -- Start execution
    self.running[executionId] = {
        action = action,
        startTime = os.time(),
        status = "running"
    }

    -- Execute the action
    local success, result = actionType.handler(action.parameters or {})

    -- Update execution status
    self.running[executionId].status = success and "completed" or "failed"
    self.running[executionId].endTime = os.time()
    self.running[executionId].result = result

    -- Cleanup after a while
    hs.timer.doAfter(60, function() self.running[executionId] = nil end)

    return success, result, executionId
end

-- Register a trigger for an action
function actionSystem:registerTrigger(triggerConfig)
    if not triggerConfig or not triggerConfig.type or not triggerConfig.action then
        return false, "Invalid trigger configuration"
    end

    local triggerId = triggerConfig.id or os.time() .. "-" .. math.random(1000, 9999)

    -- Define the trigger
    local trigger = {
        id = triggerId,
        type = triggerConfig.type,
        action = triggerConfig.action,
        enabled = triggerConfig.enabled ~= false,
        parameters = triggerConfig.parameters or {}
    }

    -- Specific trigger type setup
    if trigger.type == "hotkey" and trigger.parameters.key then
        trigger.handler = hs.hotkey.new(
            trigger.parameters.modifiers or {},
            trigger.parameters.key,
            function()
                if trigger.enabled then
                    self:executeAction(trigger.action)
                end
            end
        )

        if trigger.enabled then
            trigger.handler:enable()
        end
    elseif trigger.type == "timer" and trigger.parameters.interval then
        trigger.handler = hs.timer.new(trigger.parameters.interval, function()
            if trigger.enabled then
                self:executeAction(trigger.action)
            end
            return trigger.parameters.repeats ~= false
        end)

        if trigger.enabled then
            trigger.handler:start()
        end
    elseif trigger.type == "watcher" and trigger.parameters.event then
        -- Implement various watcher types (file, app, wifi, screen, etc.)
        -- This is a placeholder for future implementation
    else
        return false, "Unsupported trigger type or missing required parameters"
    end

    -- Store the trigger
    self.triggers[triggerId] = trigger

    return true, triggerId
end

-- Enable or disable a trigger
function actionSystem:setTriggerEnabled(triggerId, enabled)
    local trigger = self.triggers[triggerId]
    if not trigger then
        return false, "Trigger not found: " .. triggerId
    end

    trigger.enabled = enabled

    if trigger.handler then
        if trigger.type == "hotkey" then
            if enabled then
                trigger.handler:enable()
            else
                trigger.handler:disable()
            end
        elseif trigger.type == "timer" then
            if enabled then
                trigger.handler:start()
            else
                trigger.handler:stop()
            end
        end
    end

    return true
end

-- Delete a trigger
function actionSystem:deleteTrigger(triggerId)
    local trigger = self.triggers[triggerId]
    if not trigger then
        return false, "Trigger not found: " .. triggerId
    end

    -- Clean up the handler
    if trigger.handler then
        if trigger.type == "hotkey" then
            trigger.handler:delete()
        elseif trigger.type == "timer" then
            trigger.handler:stop()
        end
    end

    -- Remove from registry
    self.triggers[triggerId] = nil

    return true
end

-- Get a list of registered action types
function actionSystem:getActionTypes()
    local types = {}
    for id, actionType in pairs(self.registry) do
        table.insert(types, {
            id = id,
            name = actionType.name,
            description = actionType.description,
            icon = actionType.icon,
            category = actionType.category
        })
    end
    return types
end

-- Get a list of active triggers
function actionSystem:getTriggers()
    local result = {}
    for id, trigger in pairs(self.triggers) do
        table.insert(result, {
            id = id,
            type = trigger.type,
            enabled = trigger.enabled,
            parameters = trigger.parameters,
            action = {
                type = trigger.action.type,
                name = trigger.action.name
            }
        })
    end
    return result
end

-- Register built-in action types
function actionSystem:registerBuiltins()
    -- Alert action
    self:registerActionType("alert", {
        name = "Show Alert",
        description = "Display an alert message on screen",
        icon = "💬",
        category = "User Interface",
        parameters = {
            message = { type = "string", required = true },
            duration = { type = "number", default = 2 }
        },
        handler = function(params)
            hs.alert.show(params.message, params.duration)
            return true
        end
    })

    -- Launch application action
    self:registerActionType("launchApp", {
        name = "Launch Application",
        description = "Launch or focus an application",
        icon = "🚀",
        category = "Applications",
        parameters = {
            appName = { type = "string", required = true }
        },
        handler = function(params)
            return hs.application.launchOrFocus(params.appName)
        end
    })

    -- Execute shell command
    self:registerActionType("shell", {
        name = "Run Shell Command",
        description = "Execute a shell command",
        icon = "🖥️",
        category = "System",
        parameters = {
            command = { type = "string", required = true },
            background = { type = "boolean", default = false }
        },
        handler = function(params)
            if params.background then
                hs.task.new("/bin/sh", nil, { "-c", params.command }):start()
                return true
            else
                local output, status = hs.execute(params.command)
                return status == 0, output
            end
        end
    })

    -- Window manipulation
    self:registerActionType("windowMove", {
        name = "Move Window",
        description = "Move the active window to a specific position",
        icon = "🪟",
        category = "Windows",
        parameters = {
            position = {
                type = "enum",
                required = true,
                options = {
                    "left", "right", "top", "bottom",
                    "topLeft", "topRight", "bottomLeft", "bottomRight",
                    "center", "fullscreen"
                }
            }
        },
        handler = function(params)
            local win = hs.window.focusedWindow()
            if not win then return false, "No active window" end

            local screen = win:screen()
            local screenFrame = screen:frame()
            local frame = win:frame()

            if params.position == "left" then
                frame.x = screenFrame.x
                frame.y = screenFrame.y
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h
            elseif params.position == "right" then
                frame.x = screenFrame.x + screenFrame.w / 2
                frame.y = screenFrame.y
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h
            elseif params.position == "top" then
                frame.x = screenFrame.x
                frame.y = screenFrame.y
                frame.w = screenFrame.w
                frame.h = screenFrame.h / 2
            elseif params.position == "bottom" then
                frame.x = screenFrame.x
                frame.y = screenFrame.y + screenFrame.h / 2
                frame.w = screenFrame.w
                frame.h = screenFrame.h / 2
            elseif params.position == "topLeft" then
                frame.x = screenFrame.x
                frame.y = screenFrame.y
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h / 2
            elseif params.position == "topRight" then
                frame.x = screenFrame.x + screenFrame.w / 2
                frame.y = screenFrame.y
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h / 2
            elseif params.position == "bottomLeft" then
                frame.x = screenFrame.x
                frame.y = screenFrame.y + screenFrame.h / 2
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h / 2
            elseif params.position == "bottomRight" then
                frame.x = screenFrame.x + screenFrame.w / 2
                frame.y = screenFrame.y + screenFrame.h / 2
                frame.w = screenFrame.w / 2
                frame.h = screenFrame.h / 2
            elseif params.position == "center" then
                frame.x = screenFrame.x + (screenFrame.w - frame.w) / 2
                frame.y = screenFrame.y + (screenFrame.h - frame.h) / 2
            elseif params.position == "fullscreen" then
                frame = screenFrame
            end

            win:setFrame(frame)
            return true
        end
    })
end

-- Initialize
function actionSystem:init()
    self:registerBuiltins()
    return self
end

return actionSystem
