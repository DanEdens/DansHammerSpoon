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
    return config
end

-- Load macros from XML file
function config.loadMacros(filepath)
    local file = io.open(filepath, "r")
    if not file then
        -- Return empty configuration if file doesn't exist
        return {}, 0
    end
    
    local content = file:read("*all")
    file:close()
    
    local parsed = config.xmlparser.fromXML(content)
    if not parsed then
        return {}, 0
    end
    
    -- Convert XML structure to macro structure
    local function convertToMacro(item)
        if not item then return nil end
        
        local macro = {
            id = item.attributes and item.attributes.id,
            name = item.attributes and item.attributes.name,
            type = item.attributes and item.attributes.type,
            tag = item.tag,
            expanded = false,
            children = {}
        }
        
        if item.children then
            for _, child in ipairs(item.children) do
                local converted = convertToMacro(child)
                if converted then
                    table.insert(macro.children, converted)
                end
            end
        end
        
        return macro
    end
    
    local macros = {}
    local lastId = 0
    
    if parsed.children then
        for _, item in ipairs(parsed.children) do
            local macro = convertToMacro(item)
            if macro then
                table.insert(macros, macro)
                -- Update lastId
                if macro.id then
                    local numId = tonumber(macro.id)
                    if numId and numId > lastId then
                        lastId = numId
                    end
                end
            end
        end
    end
    
    return macros, lastId
end

-- Save macros to XML file
function config.saveMacros(filepath, macros)
    -- Convert macro structure to XML structure
    local function convertToXML(item)
        if not item then return nil end
        
        local xmlItem = {
            tag = item.tag or "macro",
            attributes = {
                id = item.id,
                name = item.name,
                type = item.type
            },
            children = {}
        }
        
        if item.children then
            for _, child in ipairs(item.children) do
                local converted = convertToXML(child)
                if converted then
                    table.insert(xmlItem.children, converted)
                end
            end
        end
        
        return xmlItem
    end
    
    local root = {
        tag = "macros",
        children = {}
    }
    
    for _, macro in ipairs(macros) do
        local xmlMacro = convertToXML(macro)
        if xmlMacro then
            table.insert(root.children, xmlMacro)
        end
    end
    
    local xml = config.xmlparser.toXML(root)
    local file = io.open(filepath, "w")
    if file then
        file:write(xml)
        file:close()
        return true
    end
    return false
end

return config
