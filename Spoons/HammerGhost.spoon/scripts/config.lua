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

-- Initialize the module with dependencies
function config.init(deps)
    config.xmlparser = deps.xmlparser
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
            else
                hs.alert.show("Error: xmlparser or fromXML method is not available")
            end
        end
    end

    return macroTree, lastId
end

-- Save macros to the specified path
function config.saveMacros(path, macroTree)
    local xml = config.xmlparser.toXML(macroTree)
    local f = io.open(path, "w")
    if f then
        f:write(xml)
        f:close()
    else
        hs.alert.show("Error saving configuration")
    end
end

return config
