
local mousexml = require("@mousetool/mousexml")
local linkedlist = require("@mousetool/linkedlist")
local roomGet = tfm.get.room

--- @class BtXmlMapProp
--- @field wind number
--- @field gravity number
--- @field mgoc number

--- Represents a BuildTool round
--- @class BtRound:CommonRound
--- @field new fun(mapCode:number, isMirrored?:boolean, author?:string, permCode?:string, xml?:string):BtRound
--- @field author string # The map's author
--- @field xmlDoc XmlDoc|nil # The map's XML document object
--- @field mapProp BtXmlMapProp|nil # Map properties from the XML
--- @field spawnedObjects table<string, LinkedList<number, number>> # Keeps track of all objects IDs spawned in the round per player
local BtRound = require("entities.CommonRound"):extend("BtRound")

local _parseXml

--- @param mapCode number
--- @param isMirrored boolean
--- @param author? string
--- @param permCode? number
--- @param xml? string
BtRound._init = function(self, mapCode, isMirrored, author, permCode, xml)
    BtRound._parent._init(self, mapCode, isMirrored, author, permCode, xml)
    self.author = author or "Tigrounette#0001"

    -- Parse XML
    xpcall(_parseXml, function(err)
        print(("Failed to parse XML on map @%s:\n%s"):format(mapCode, debug.traceback(nil, 2)))
    end, self, xml)

    self.spawnedObjects = {}
end

--- @param self BtRound
--- @param xml string
_parseXml = function(self, xml)
    if not xml then
        return
    end

    local xmlDoc = mousexml.parse(xml)
    local mapProp = {}
    self.xmlDoc = xmlDoc
    self.mapProp = mapProp

    --- @type XmlNode
    local prop_node = xmlDoc('C')('P')
    local prop_attr = prop_node.attributes

    local wind, grav = 0, 10
    if prop_attr['G'] then
        wind, grav = prop_attr['G']:match("(%-?%S+),(%-?%S+)")
        wind = tonumber(wind) or wind
        grav = tonumber(grav) or grav
    end
    mapProp.wind = wind
    mapProp.gravity = grav

    mapProp.mgoc = tonumber(prop_attr['mgoc']) or 0
end

--- Removes all objects spawned
--- @param playerName? string # The player to target. If this is `nil`, will target all players.
BtRound.clearAllObjects = function(self, playerName)
    if not playerName then
        -- Target all
        for name, pspawned in pairs(self.spawnedObjects) do
            for _, obj_id in pspawned:ipairs() do
                tfm.exec.removeObject(obj_id)
            end
        end
        self.spawnedObjects = {}
    else
        -- Target player
        local pspawned = self.spawnedObjects[playerName]
        if not pspawned then return end
        for _, obj_id in pspawned:ipairs() do
            tfm.exec.removeObject(obj_id)
        end
        self.spawnedObjects[playerName] = linkedlist:new()
    end
end

--- Instantiate a BT round from the current `TfmRoom`
--- @return BtRound
BtRound.fromRoom = function()
    local map_code = tonumber(roomGet.currentMap:match("@?(%d+)")) or 0
    local xmlMapInfo = roomGet.xmlMapInfo

    if xmlMapInfo and map_code ~= xmlMapInfo.mapCode then
        -- Map has no XML map info
        xmlMapInfo = nil
    end

    return BtRound:new(map_code,
        roomGet.mirroredMap,
        xmlMapInfo and xmlMapInfo.author,
        xmlMapInfo and xmlMapInfo.permCode,
        xmlMapInfo and xmlMapInfo.xml)
end

return BtRound
