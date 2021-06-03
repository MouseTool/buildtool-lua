-- Controls shaman-related gameplay

local linkedlist = require("@mousetool/linkedlist")
local btRoom = require("entities.bt_room")
local ShamObj = require("bt-enums").ShamObj
local tfmEvent = btRoom.api.tfmEvent

--- @param pn string
--- @param objType integer
--- @param xPos integer
--- @param yPos integer
--- @param angle integer
--- @param objDesc TfmShamanObject
tfmEvent:onCrucial('SummoningEnd', function(pn, objType, xPos, yPos, angle, objDesc)
    -- Add on to the list of spawns
    local round = btRoom.currentRound
    local baseType = objDesc.baseType
    if round and baseType ~= ShamObj.Arrow
    and baseType ~= ShamObj.Spirit
    and baseType ~= ShamObj.Portal then
        local pspawn = round.spawnedObjects[pn]
        if not pspawn then
            pspawn = linkedlist:new()
            round.spawnedObjects[pn] = pspawn
        end
        pspawn:push_back(objDesc.id)
    end
end)
