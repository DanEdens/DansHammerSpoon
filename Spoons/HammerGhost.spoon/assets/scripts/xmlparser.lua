-- Simple XML parser for HammerGhost
local parser = {}

-- Helper function to trim whitespace
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Parse XML string into a table
function parser.parse(xmlString)
    local stack = {}
    local top = {}
    table.insert(stack, top)
    
    local index = 1
    while index <= #xmlString do
        -- Find next tag
        local startTag = xmlString:find("<", index)
        if not startTag then break end
        
        local endTag = xmlString:find(">", startTag)
        if not endTag then break end
        
        local tagStr = xmlString:sub(startTag + 1, endTag - 1)
        
        if tagStr:sub(1, 1) == "/" then
            -- Closing tag
            table.remove(stack)
            top = stack[#stack]
        else
            -- Extract tag name and attributes
            local name = tagStr:match("([%w_]+)")
            local attrs = {}
            for k, v in tagStr:gmatch('([%w_]+)="([^"]+)"') do
                attrs[k] = v
            end
            
            local node = {
                name = name,
                attributes = attrs,
                children = {},
                value = ""
            }
            
            if #stack > 0 then
                table.insert(top.children, node)
            end
            
            if not tagStr:match("/[%s]*$") then
                top = node
                table.insert(stack, node)
            end
        end
        
        index = endTag + 1
        
        -- Get text content
        if #stack > 0 then
            local nextTag = xmlString:find("<", index)
            if nextTag then
                local text = xmlString:sub(index, nextTag - 1)
                if text and trim(text) ~= "" then
                    top.value = trim(text)
                end
                index = nextTag
            end
        end
    end
    
    return top.children[1]
end

-- Convert table to XML string
function parser.toXML(tab, indent)
    indent = indent or ""
    local xml = indent .. "<" .. tab.name
    
    -- Add attributes
    for k, v in pairs(tab.attributes or {}) do
        xml = xml .. string.format(' %s="%s"', k, v)
    end
    
    if #(tab.children or {}) == 0 and tab.value == "" then
        return xml .. "/>\n"
    end
    
    xml = xml .. ">"
    
    -- Add value
    if tab.value and tab.value ~= "" then
        xml = xml .. tab.value
    else
        xml = xml .. "\n"
    end
    
    -- Add children
    for _, child in ipairs(tab.children or {}) do
        xml = xml .. parser.toXML(child, indent .. "  ")
    end
    
    if #(tab.children or {}) > 0 then
        xml = xml .. indent
    end
    
    return xml .. "</" .. tab.name .. ">\n"
end

return parser 
