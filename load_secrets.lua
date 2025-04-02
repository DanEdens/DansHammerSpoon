-- Hammerspoon secrets loader
-- This script loads secrets from a .secrets file and returns them as a table

local M = {}

-- Attempt to load the secrets file
local function loadSecrets()
    local secretsPath = hs.configdir .. "/.env"
    local f = io.open(secretsPath, "r")
    if not f then
        hs.alert.show("Warning: .secrets file not found")
        return {}
    end

    local secrets = {}
    for line in f:lines() do
        -- Skip comments and empty lines
        if line:match("^%s*#") or line:match("^%s*$") then
            -- Skip
        else
            -- Parse KEY="VALUE" format
            local key, value = line:match('([^=]+)="([^"]*)"')
            if key and value then
                secrets[key:gsub("%s+", "")] = value
            else
                -- Try KEY=VALUE format without quotes
                key, value = line:match('([^=]+)=([^#]*)')
                if key and value then
                    -- Handle boolean values
                    if value:match("^%s*true%s*$") then
                        value = true
                    elseif value:match("^%s*false%s*$") then
                        value = false
                    end
                    secrets[key:gsub("%s+", "")] = value
                end
            end
        end
    end
    f:close()
    return secrets
end

-- Load secrets into the module
local secrets = loadSecrets()
for k, v in pairs(secrets) do
    M[k] = v
end

-- Function to get a secret with a fallback default value
function M.get(key, default)
    if M[key] ~= nil then
        return M[key]
    else
        return default
    end
end

return M
