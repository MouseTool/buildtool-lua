-- Controls shaman-related gameplay

local DoublyLinkedList = require("util.staging.linkedlist.init").DoublyLinkedList
local btRoom = require("modules.btRoom")
local ShamObj = require("btEnums").ShamObj
local tfmEvent = btRoom.api.tfmEvent

--- @param pn string
--- @param objType integer
--- @param xPos integer
--- @param yPos integer
--- @param angle integer
--- @param objDesc tfm.ShamanObject
tfmEvent:onCrucial('SummoningEnd', function(pn, objType, xPos, yPos, angle, objDesc)
    -- Add on to the list of spawns
    local round = btRoom.currentRound
    local baseType = objDesc.baseType
    if round and baseType ~= ShamObj.Arrow
    and baseType ~= ShamObj.Spirit
    and baseType ~= ShamObj.Portal then
        local pspawn = round.spawnedObjects[pn]
        if not pspawn then
            pspawn = DoublyLinkedList:new()
            round.spawnedObjects[pn] = pspawn
        end
        pspawn:pushBack(objDesc.id)
    end
end)
