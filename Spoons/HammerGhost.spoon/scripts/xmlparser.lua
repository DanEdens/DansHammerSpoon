--- XML Parser for HammerGhost
--- Simple XML parser for handling macro configurations

local parser = {}

-- Helper function to trim whitespace
local function trim(s)
    return s:match("^%s*(.-)%s*$")
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
    local xml = ""

    for _, element in ipairs(tbl) do
        xml = xml .. "<" .. element.tag

        if element.attributes then
            for name, value in pairs(element.attributes) do
                xml = xml .. string.format(" %s=\"%s\"", name, value)
            end
        end

        if element.children or element.value then
            xml = xml .. ">"

            if element.children then
                xml = xml .. parser.toXML(element.children)
            end

            if element.value then
                xml = xml .. element.value
            end

            xml = xml .. "</" .. element.tag .. ">"
        else
            xml = xml .. "/>"
        end
    end

    return xml
end

return parser
