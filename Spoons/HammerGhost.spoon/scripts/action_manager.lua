-- Action Manager for HammerGhost
-- Handles storage, retrieval, and management of actions
local actionSystem = dofile(hs.spoons.resourcePath("scripts/action_system.lua"))

local actionManager = {}
actionManager.__index = actionManager

-- Initialize with empty collections
actionManager.actions = {}
actionManager.configPath = hs.configdir .. "/hammerghost_actions.json"

-- Create a new action
function actionManager:createAction(data)
    local id = tostring(os.time()) .. "-" .. math.random(1000, 9999)

    local action = {
        id = id,
        name = data and data.name or "New Action",
        type = data and data.type or "alert", -- default to alert action
        description = data and data.description or "",
        parameters = data and data.parameters or {},
        triggers = data and data.triggers or {},
        category = data and data.category or "Custom",
        icon = data and data.icon or "⚡"
    }

    self.actions[id] = action
    return id
end

-- Get an action by ID
function actionManager:getAction(id)
    return self.actions[id]
end

-- Get all actions
function actionManager:getAllActions()
    local result = {}
    for _, action in pairs(self.actions) do
        table.insert(result, action)
    end
    return result
end

-- Update an action
function actionManager:updateAction(id, updates)
    local action = self.actions[id]
    if not action then
        return false, "Action not found: " .. id
    end

    -- Update fields
    for k, v in pairs(updates) do
        action[k] = v
    end

    return true
end

-- Update action parameter
function actionManager:updateParameter(id, name, value)
    local action = self.actions[id]
    if not action then
        return false, "Action not found: " .. id
    end

    if not action.parameters then
        action.parameters = {}
    end

    action.parameters[name] = value
    return true
end

-- Delete an action
function actionManager:deleteAction(id)
    if not self.actions[id] then
        return false, "Action not found: " .. id
    end

    -- Clean up any triggers
    local action = self.actions[id]
    if action.triggers then
        for triggerId, _ in pairs(action.triggers) do
            actionSystem:deleteTrigger(triggerId)
        end
    end

    self.actions[id] = nil
    return true
end

-- Execute an action
function actionManager:executeAction(id)
    local action = self.actions[id]
    if not action then
        return false, "Action not found: " .. id
    end

    -- Convert to format expected by actionSystem
    local actionToExecute = {
        type = action.type,
        parameters = action.parameters or {}
    }

    return actionSystem:executeAction(actionToExecute)
end

-- Add a trigger to an action
function actionManager:addTrigger(actionId, triggerType)
    local action = self.actions[actionId]
    if not action then
        return false, "Action not found: " .. actionId
    end

    if not action.triggers then
        action.triggers = {}
    end

    -- Default parameters based on trigger type
    local parameters = {}
    if triggerType == "hotkey" then
        parameters = {
            modifiers = { "cmd", "alt" },
            key = ""
        }
    elseif triggerType == "timer" then
        parameters = {
            interval = 60,
            repeats = true
        }
    elseif triggerType == "watcher" then
        parameters = {
            event = "applicationLaunched"
        }
    end

    -- Create the trigger config
    local triggerConfig = {
        type = triggerType,
        parameters = parameters,
        action = {
            type = action.type,
            parameters = action.parameters,
            name = action.name
        }
    }

    -- Register the trigger
    local success, resultOrError = actionSystem:registerTrigger(triggerConfig)
    if not success then
        return false, resultOrError
    end

    -- Store the trigger ID
    local triggerId = resultOrError
    action.triggers[triggerId] = {
        id = triggerId,
        type = triggerType,
        parameters = parameters,
        enabled = true
    }

    return true, triggerId
end

-- Delete a trigger
function actionManager:deleteTrigger(actionId, triggerId)
    local action = self.actions[actionId]
    if not action or not action.triggers or not action.triggers[triggerId] then
        return false, "Trigger not found"
    end

    -- Delete from system
    actionSystem:deleteTrigger(triggerId)

    -- Remove from action
    action.triggers[triggerId] = nil

    return true
end

-- Toggle a trigger
function actionManager:toggleTrigger(actionId, triggerId)
    local action = self.actions[actionId]
    if not action or not action.triggers or not action.triggers[triggerId] then
        return false, "Trigger not found"
    end

    local trigger = action.triggers[triggerId]
    local newState = not trigger.enabled

    -- Update in system
    actionSystem:setTriggerEnabled(triggerId, newState)

    -- Update local state
    trigger.enabled = newState

    return true
end

-- Load actions from disk
function actionManager:load()
    if not hs.fs.attributes(self.configPath) then
        return true -- No config yet, that's fine
    end

    local f = io.open(self.configPath, "r")
    if not f then
        return false, "Could not open config file"
    end

    local content = f:read("*all")
    f:close()

    local success, data = pcall(function() return hs.json.decode(content) end)
    if not success or not data then
        return false, "Could not parse config file"
    end

    -- Load actions
    self.actions = {}
    for id, action in pairs(data.actions or {}) do
        self.actions[id] = action

        -- Recreate triggers
        if action.triggers then
            for triggerId, trigger in pairs(action.triggers) do
                local triggerConfig = {
                    id = triggerId,
                    type = trigger.type,
                    parameters = trigger.parameters,
                    enabled = trigger.enabled,
                    action = {
                        type = action.type,
                        parameters = action.parameters,
                        name = action.name
                    }
                }

                actionSystem:registerTrigger(triggerConfig)
            end
        end
    end

    return true
end

-- Save actions to disk
function actionManager:save()
    local data = {
        actions = self.actions,
        version = "1.0"
    }

    local jsonString = hs.json.encode(data)

    local f = io.open(self.configPath, "w")
    if not f then
        return false, "Could not open config file for writing"
    end

    f:write(jsonString)
    f:close()

    return true
end

-- Get UI data for action editor
function actionManager:getActionEditorData(selectedId)
    local actions = self:getAllActions()
    local actionTypes = actionSystem:getActionTypes()

    return {
        actions = actions,
        actionTypes = actionTypes,
        selectedActionId = selectedId
    }
end

-- Initialize
function actionManager:init()
    -- Initialize action system
    actionSystem:init()

    -- Load saved actions
    self:load()

    return self
end

return actionManager
