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
end

tfmEvent:on("ChatMessage", function(pn, message)
    print(message)
end)

tfmEvent:on("Keyboard", function(pn, k, down, x, y)
    if k == 72 then
        WindowManager.toggle(WindowEnums.HELP, pn)
    end
end)

tfmEvent:onCrucial("PlayerLeft", function(pn)
    local p = globals.players[pn]
    if not p then return end

    globals.players[pn] = nil
end)

api:on("newPlayer", function(p)
    globals.players[p.name] = p
    tfm.exec.chatMessage("player ".. p.name)
    system.bindKeyboard(p.name, 72, true, true)
end)

api:start()
