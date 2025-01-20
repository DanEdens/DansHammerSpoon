local config = {}

-- Helper function to find the highest ID
local function findHighestId(macroTree)
    local highestId = 0
    local function traverse(items)
        for _, item in ipairs(items) do
            if tonumber(item.id) and tonumber(item.id) > highestId then
                highestId = tonumber(item.id)
            end
            if item.children then
                traverse(item.children)
            end
        end
    end
    traverse(macroTree)
    return highestId
end

-- Add this function to validate the macro tree
local function validateMacroTree(macroTree)
    local hasError = false
    local function traverse(items)
        for _, item in ipairs(items) do
            if not item.name then
                hs.logger.new("HammerGhost"):e("Macro item missing 'name': " .. hs.inspect(item))
                hasError = true
            end
            if item.children then
                traverse(item.children)
            end
        end
    end
    traverse(macroTree)
    return not hasError
end

-- Initialize the module with dependencies
function config.init(deps)
    config.xmlparser = deps.xmlparser
    if not config.xmlparser or not config.xmlparser.fromXML then
        hs.logger.new("HammerGhost"):e("Error: xmlparser or fromXML method is not available")
    end
    return config
end

-- Load macros from the specified path
function config.loadMacros(path)
    local macroTree = {}
    local lastId = 0

    if hs.fs.attributes(path) then
        local f = io.open(path, "r")
        if f then
            local content = f:read("*all")
            f:close()

            -- Check if xmlparser and fromXML are available
            if config.xmlparser and config.xmlparser.fromXML then
                macroTree = config.xmlparser.fromXML(content) or {}
                lastId = findHighestId(macroTree)
                
                -- Validate the loaded macroTree
                if not validateMacroTree(macroTree) then
                    hs.alert.show("HammerGhost: Invalid macro configuration detected. Please check the config file.")
                end
            else
                hs.alert.show("Error: xmlparser or fromXML method is not available")
            end
        end
    end

    return macroTree, lastId
end

-- Save macros to the specified path
function config.saveMacros(path, macroTree)
    -- Log the macroTree structure
    hs.logger.new("HammerGhost"):d("Saving macroTree: " .. hs.inspect(macroTree))

    -- Check if macroTree is valid
    if not macroTree or #macroTree == 0 then
        hs.logger.new("HammerGhost"):e("Invalid macroTree: " .. hs.inspect(macroTree))
        return
    end

    local xml = config.xmlparser.toXML(macroTree)
    if not xml then
        hs.logger.new("HammerGhost"):e("Failed to convert macroTree to XML")
        return
    end

    local f = io.open(path, "w")
    if f then
        f:write(xml)
        f:close()
    else
        hs.alert.show("Error saving configuration")
    end
end

return config
