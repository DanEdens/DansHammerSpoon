--- XML Parser for HammerGhost
--- Simple XML parser for handling macro configurations

local parser = {}

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
function parser.parse(xmlString)
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
function parser.toXML(tbl)
    local function processItem(item, indent)
        local xml = string.rep("  ", indent) .. "<macro>\n"

        -- Add basic properties
        xml = xml .. string.rep("  ", indent + 1) .. "<id>" .. item.id .. "</id>\n"
        xml = xml .. string.rep("  ", indent + 1) .. "<name>" .. escapeXML(item.name) .. "</name>\n"
        xml = xml .. string.rep("  ", indent + 1) .. "<type>" .. item.type .. "</type>\n"

        -- Add attributes if present
        if item.attributes then
            xml = xml .. string.rep("  ", indent + 1) .. "<attributes>\n"
            for key, value in pairs(item.attributes) do
                xml = xml .. string.rep("  ", indent + 2) ..
                      string.format("<%s>%s</%s>\n", key, escapeXML(tostring(value)), key)
            end
            xml = xml .. string.rep("  ", indent + 1) .. "</attributes>\n"
        end

        -- Add children if present
        if item.children and #item.children > 0 then
            xml = xml .. string.rep("  ", indent + 1) .. "<children>\n"
            for _, child in ipairs(item.children) do
                xml = xml .. processItem(child, indent + 2)
            end
            xml = xml .. string.rep("  ", indent + 1) .. "</children>\n"
        end

        xml = xml .. string.rep("  ", indent) .. "</macro>\n"
        return xml
    end

    local xml = "<macros>\n"
    for _, item in ipairs(tbl) do
        xml = xml .. processItem(item, 1)
    end
    xml = xml .. "</macros>"

    return xml
end

function parser.fromXML(xmlString)
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

    return stack[1].children or {}
end

return parser
