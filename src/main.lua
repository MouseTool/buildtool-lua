local globals = require("bt-vars")
local api = globals.api
local tfmEvent = api.tfmEvent
local WindowManager = require("window.window_manager")
local BtEnums = require("bt-enums")
local WindowEnums = BtEnums.Window

-- Override print function
do
    local raw_print = print
    print = function(...)
        local args = {...}
        local nargs = select('#', ...)
        local segments = {}
        for i = 1, nargs do
            segments[i] = tostring(args[i])
        end
        return raw_print(table.concat(segments, "\t"))
    end

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

    local raw_xpcall = xpcall
    xpcall = function(f, msgh, ...)
        local args, nargs = {...}, select("#", ...)
        return raw_xpcall(function()
            return f(table.unpack(args, 1, nargs))
        end, msgh)
    end
end

tfmEvent:on("ChatMessage", function(pn, message)
    print(message)
end)

tfmEvent:on("Keyboard", function(pn, k, down, x, y)
    if k == 72 then
        WindowManager.toggle(WindowEnums.HELP, pn)
    end
    if k==32 then  --tmp test
        WindowManager.refocus(WindowEnums.SETTINGS, pn)
    end
    if k == 79 then
        WindowManager.toggle(WindowEnums.SETTINGS, pn)
    end
end)

tfmEvent:onCrucial("PlayerLeft", function(pn)
    local p = globals.players[pn]
    if not p then return end

    globals.players[pn] = nil
end)

--- @param p Player
api:on("newPlayer", function(p)
    globals.players[p.name] = p
    tfm.exec.chatMessage("player ".. p.name)
    system.bindKeyboard(p.name, 72, true, true)
    system.bindKeyboard(p.name, 32, true, true)  -- tmp
    system.bindKeyboard(p.name, 79, true, true)
end)

-- External Init
require("commands.init")

for _,v in ipairs({'AfkDeath','AllShamanSkills','AutoNewGame','AutoScore','AutoTimeLeft','PhysicalConsumables'}) do
    tfm.exec['disable'..v](true)
end
system.disableChatCommandDisplay(nil,true)

api:start()
