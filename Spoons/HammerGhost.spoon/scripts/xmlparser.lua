--- XML Parser for HammerGhost
--- Simple XML parser for handling macro configurations

local xmlparser = {}

-- Helper function to trim whitespace
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Helper function to escape special XML characters
local function escapeXML(s)
    local escaped = s:gsub("[<>&'\"]", {
        ['<'] = '&lt;',
        ['>'] = '&gt;',
        ['&'] = '&amp;',
        ["'"] = '&apos;',
        ['"'] = '&quot;'
    })
    return escaped
end

-- Helper function to unescape XML entities
local function unescapeXML(s)
    local unescaped = s:gsub('&(%w+);', {
        lt = '<',
        gt = '>',
        amp = '&',
        apos = "'",
        quot = '"'
    })
    return unescaped
end

-- Parse XML string into a Lua table
function xmlparser.parse(xmlString)
    local stack = {}
    local top = {}
    table.insert(stack, top)

    local index = 1
    local text = ""

    while index <= #xmlString do
        -- Find next tag
        local startTag = xmlString:find("<", index)
        if not startTag then break end

        -- Add text before tag
        text = text .. trim(xmlString:sub(index, startTag - 1))
        if #text > 0 then
            if top.value then
                top.value = top.value .. text
            else
                top.value = text
            end
            text = ""
        end

        -- Find end of tag
        local endTag = xmlString:find(">", startTag)
        if not endTag then break end

        local tag = xmlString:sub(startTag + 1, endTag - 1)

        if tag:sub(1, 1) == "/" then
            -- Closing tag
            table.remove(stack)
            top = stack[#stack]
        else
            -- Opening tag
            local element = {}
            element.tag = tag:match("^(%S+)")

            -- Parse attributes
            for name, value in tag:gmatch("%s+(%w+)=\"([^\"]*)\"") do
                if not element.attributes then
                    element.attributes = {}
                end
                element.attributes[name] = value
            end

            if not top.children then
                top.children = {}
            end
            table.insert(top.children, element)

            if not tag:match("/$") then
                table.insert(stack, element)
                top = element
            end
        end

        index = endTag + 1
    end

    return stack[1].children
end

-- Convert Lua table to XML string
function xmlparser.toXML(item)
    if not item then return "" end
    
    local function processItem(item, indent)
        indent = indent or ""
        local xml = indent .. "<" .. (item.tag or "item")
        
        -- Add attributes if they exist
        if item.attributes then
            for k, v in pairs(item.attributes) do
                if v then  -- Only add non-nil attributes
                    xml = xml .. string.format(' %s="%s"', k, tostring(v))
                end
            end
        end
        
        -- If there are children or value, add them
        if item.children and #item.children > 0 then
            xml = xml .. ">\n"
            for _, child in ipairs(item.children) do
                xml = xml .. processItem(child, indent .. "  ")
            end
            xml = xml .. indent .. "</" .. (item.tag or "item") .. ">\n"
        elseif item.value then
            xml = xml .. ">" .. tostring(item.value) .. "</" .. (item.tag or "item") .. ">\n"
        else
            xml = xml .. "/>\n"
        end
        
        return xml
    end
    
    return processItem(item)
end

-- Parse XML string to table
function xmlparser.fromXML(xml)
    if not xml or xml == "" then return nil end
    
    local stack = {}
    local top = {}
    table.insert(stack, top)
    
    local index = 1
    local text = ""
    
    local function addText()
        if text ~= "" then
            if stack[#stack].value then
                stack[#stack].value = stack[#stack].value .. text
            else
                stack[#stack].value = text
            end
            text = ""
        end
    end
    
    while index <= #xml do
        local start, stop = string.find(xml, "<[^>]+>", index)
        if not start then break end
        
        -- Add any text before the tag
        if start > index then
            text = text .. string.sub(xml, index, start - 1)
        end
        
        local tag = string.sub(xml, start + 1, stop - 1)
        
        if string.sub(tag, 1, 1) == "/" then
            -- Closing tag
            addText()
            table.remove(stack)
        elseif string.sub(tag, -1) == "/" then
            -- Self-closing tag
            local element = {tag = string.sub(tag, 1, -2)}
            table.insert(stack[#stack], element)
        else
            -- Opening tag
            local element = {tag = tag, children = {}}
            table.insert(stack[#stack], element)
            table.insert(stack, element)
        end
        
        index = stop + 1
    end
    
    -- Add any remaining text
    if index <= #xml then
        text = text .. string.sub(xml, index)
        addText()
    end
    
    return top[1]
end

return xmlparser
