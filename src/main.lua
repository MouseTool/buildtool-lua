local globals = require("bt-vars")
local api = globals.api

-- Patch globals with custom vars
do
    dumptbl = function(tbl, indent, cb)
        if not indent then indent = 0 end
        if not cb then cb = print end
        if indent > 6 then
            cb(string.rep("  ", indent) .. "...")
            return
        end
        for k, v in pairs(tbl) do
            formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                cb(formatting)
                dumptbl(v, indent+1, cb)
            elseif type(v) == 'boolean' then
                cb(formatting .. tostring(v))
            elseif type(v) == "function" then
                cb(formatting .. "()")
            else
                cb(formatting .. v)
            end
        end
    end

    -- Apply patched globals
    require("@mousetool/mousebase").overloads.applyGlobal()
end

--[[ External Init ]]
require("basic")
require("shaman")
require("commands.bt-init")
require("translations.bt-init")

for _,v in ipairs({'AfkDeath','AllShamanSkills','AutoNewGame','AutoScore','AutoTimeLeft','PhysicalConsumables'}) do
    tfm.exec['disable'..v](true)
end
system.disableChatCommandDisplay(nil,true)

api:start()
