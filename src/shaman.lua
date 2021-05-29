-- Controls shaman-related gameplay

local linkedlist = require("@mousetool/linkedlist")
local btRoom = require("entities.bt_room")
local api = btRoom.api
local tfmEvent = api.tfmEvent

--- @param pn string
--- @param objType integer
--- @param xPos integer
--- @param yPos integer
--- @param angle integer
--- @param objDesc TfmShamanObject
tfmEvent:onCrucial('SummoningEnd', function(pn, objType, xPos, yPos, angle, objDesc)
    -- Add on to the list of spawns
    local round = btRoom.currentRound
    if round then
        local pspawn = round.spawnedObjects[pn]
        if not pspawn then
            pspawn = linkedlist:new()
            round.spawnedObjects[pn] = pspawn
        end
        pspawn:push_back(objDesc.id)
    end
end)
