local btRoom = require "modules.btRoom"
--- A simple volatile player data table that only exists during the time the player is in the room,
--- clears itself after the player leaves.
local volatilePlayerTable = {}

local tables = {}


function volatilePlayerTable.create()
    --- @type table<string, any>
    local d = {}




    tables[#tables+1] = d
    return d
end

btRoom.api.tfmEvent:on("PlayerLeft", function(pn)
    for i = 1, #tables do
        tables[i][pn] = nil
    end
end)

--- @param mbp mousebase.MbPlayer
btRoom.api:on("newPlayer", function (mbp)
    local pn = mbp.name
    for i = 1, #tables do
        tables[i][pn] = {}
    end
end)


--return volatilePlayerTable
local pWindowStates = volatilePlayerTable.create()

pWindowStates.get("xx")
--btRoom.players
