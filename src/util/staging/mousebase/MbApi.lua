local MbPlayer = require("MbPlayer")

local players = {}

--- @class mousebase.api : EventEmitter
local api = require("@mousetool/event-emitter").EventEmitter
    :extend("mousebase.api")
    :new()

local emitExistingPlayers = function()
    for name, rp in pairs(tfm.get.room.playerList) do
        players[name] = p

        api:emit("newPlayer", p)
    end
end

api.tfmEvent = require("tfmEvent")

api.start = function()
    emitExistingPlayers()
    api:emit("ready")
end

return api
