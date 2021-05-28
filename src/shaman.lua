-- Controls shaman-related gameplay

local linkedlist = require("@mousetool/linkedlist")

local globals = require("bt-vars")
local api = globals.api
local tfmEvent = api.tfmEvent

--- Keeps track of all objects IDs spawned in the round
--- @type LinkedList<number, number>
local spawned_objects = linkedlist:new()

--- @param pn string
--- @param objType integer
--- @param xPos integer
--- @param yPos integer
--- @param angle integer
--- @param objDesc TfmShamanObject
tfmEvent:onCrucial('SummoningEnd', function(pn, objType, xPos, yPos, angle, objDesc)
    spawned_objects:push_back(objDesc.id)
end)

tfmEvent:on('NewGame', function()
    spawned_objects = linkedlist:new()
end)
