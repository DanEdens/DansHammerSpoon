--- XML Parser for HammerGhost
--- Simple XML parser for handling macro configurations

local parser = {}

-- Helper function to trim whitespace
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Helper function to escape XML special characters
local function escapeXML(s)
    if not s then return "" end
    local escaped = s:gsub("&", "&amp;")
                    :gsub("<", "&lt;")
                    :gsub(">", "&gt;")
                    :gsub("\"", "&quot;")
                    :gsub("'", "&apos;")
    return escaped
end

-- Helper function to unescape XML special characters
local function unescapeXML(s)
    if not s then return "" end
    local unescaped = s:gsub("&amp;", "&")
                       :gsub("&lt;", "<")
                       :gsub("&gt;", ">")
                       :gsub("&quot;", "\"")
                       :gsub("&apos;", "'")
    return unescaped
end

-- Convert macro tree to XML
function parser.toXML(macroTree)
    if not macroTree then return '<?xml version="1.0" encoding="UTF-8"?>\n<macros>\n</macros>' end
    local function itemToXML(item, indent)
        indent = indent or ""
        local attrs = string.format('id="%s" type="%s" name="%s"',
            escapeXML(item.id),
            escapeXML(item.type),
            escapeXML(item.name))

        if item.expanded ~= nil then
            attrs = attrs .. string.format(' expanded="%s"', tostring(item.expanded))
        end

        if item.children and #item.children > 0 then
            local xml = indent .. "<item " .. attrs .. ">\n"
            for _, child in ipairs(item.children) do
                xml = xml .. itemToXML(child, indent .. "  ")
            end
            return xml .. indent .. "</item>\n"
        else
            return indent .. "<item " .. attrs .. "/>\n"
        end
    end

    local xml = '<?xml version="1.0" encoding="UTF-8"?>\n<macros>\n'
    for _, item in ipairs(macroTree) do
        xml = xml .. itemToXML(item, "  ")
    end
    xml = xml .. "</macros>"

    return xml
end

-- Parse XML into macro tree
function parser.fromXML(xmlString)
    local function createItem(element)
        local item = {
            id = unescapeXML(element.attributes.id),
            type = unescapeXML(element.attributes.type),
            name = unescapeXML(element.attributes.name),
            expanded = element.attributes.expanded == "true"
        }

        if element.children then
            item.children = {}
            for _, child in ipairs(element.children) do
                if child.tag == "item" then
                    table.insert(item.children, createItem(child))
                end
            end
        end

        return item
    end

    local stack = {}
    local top = { tag = "root", children = {} }
    table.insert(stack, top)

    local index = 1
    while index <= #xmlString do
        -- Find next tag
        local startTag = xmlString:find("<", index)
        if not startTag then break end

        -- Find end of tag
        local endTag = xmlString:find(">", startTag)
        if not endTag then break end

        local tag = xmlString:sub(startTag + 1, endTag - 1)

        if tag:sub(1, 1) == "/" then
            -- Closing tag
            table.remove(stack)
            top = stack[#stack]
        elseif tag:sub(1, 1) == "?" then
            -- XML declaration, skip it
        else
            -- Opening tag
            local element = { attributes = {} }
            element.tag = tag:match("^(%S+)")

            -- Parse attributes
            for name, value in tag:gmatch('%s+([%w_]+)="([^"]*)"') do
                element.attributes[name] = value
            end

            if not top.children then
                top.children = {}
            end

            if tag:match("/$") then
                -- Self-closing tag
                table.insert(top.children, element)
            else
                table.insert(top.children, element)
                table.insert(stack, element)
                top = element
            end
        end

        index = endTag + 1
    end

    local macroTree = {}
    if top.children then
        for _, child in ipairs(top.children) do
            if child.tag == "macros" and child.children then
                for _, item in ipairs(child.children) do
                    if item.tag == "item" then
                        table.insert(macroTree, createItem(item))
                    end
                end
                break
            end
        end
    end

    return macroTree
end

return parser
