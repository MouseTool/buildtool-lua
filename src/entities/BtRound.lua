local mousexml = require("@mousetool/mousexml")
local linkedlist = require("@mousetool/linkedlist")
local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")
local string_split = require("util.stringlib").split
local TfmGround = require("entities.TfmGround")

local roomGet = tfm.get.room

--- Represents an X-Y coordinate
--- @class BtXmlMapProp.XY
--- @field x number # X coordinate
--- @field y number # Y coordinate

--- Represents an optional X-Y coordinate
--- @class BtXmlMapProp.XYOptional
--- @field x number|nil # X coordinate
--- @field y number|nil # Y coordinate

--- @class BtXmlMapProp
--- @field length integer
--- @field height integer
--- @field wind number
--- @field gravity number
--- @field mgoc number
--- @field mouseSpawns BtXmlMapProp.XY[]
--- @field shamanSpawns BtXmlMapProp.XY[]
--- @field mouseSpawnAxis BtXmlMapProp.XYOptional # Mice are spawned randomly across the given axis. Valid when `x` and `y` are mutually exclusive.

--- Represents a BuildTool round
--- @class BtRound:CommonRound
--- @field new fun(mapCode:number, isMirrored?:boolean, author?:string, permCode?:string, xml?:string):BtRound
--- @field author string # The map's author
--- @field xmlDoc XmlDoc|nil # The map's XML document object
--- @field mapProp BtXmlMapProp|nil # Map properties from the XML
--- @field grounds TfmGround[]|nil # The map's XML grounds
--- @field spawnedObjects table<string, LinkedList<number, number>> # Keeps track of all objects IDs spawned in the round per player
--- @field _cacheMapInfoBuilder LocalisBuilder|nil # Caches the mapinfo localization builder
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

    -- Parse XML and grounds
    xpcall(_parseXml, function(err)
        print(("Failed to parse XML on map @%s:\n%s"):format(mapCode, debug.traceback(nil, 2)))
    end, self, xml)

    self.spawnedObjects = {}
end

--- @param self BtRound
--- @param xml string
_parseXml = function(self, xml)
    if not xml then return end
    local xmlDoc = mousexml.parse(xml)

    local mapProp = {
        mouseSpawns = {},
        shamanSpawns = {}
    }
    self.xmlDoc = xmlDoc
    self.mapProp = mapProp

    -- Capture any error while parsing XML fragments
    local ON_PCALL_ERR = function(err)
        print("Runtime Error : parseXml : " .. tostring(err) .. "\n" .. debug.traceback(nil, 2))
        btRoom.moduleMsgDirect(("<R>An error occurred while parsing. Please report the error with this map (@%s)"):format(self.mapCode))
    end

    -- Parse properties
    xpcall(function()
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

        mapProp.length = tonumber(prop_attr['L']) or 800
        mapProp.height = tonumber(prop_attr['H']) or 400
        mapProp.mgoc = tonumber(prop_attr['mgoc']) or 0
    end, ON_PCALL_ERR)

    -- Parse mouse spawns
    xpcall(function()
        -- Using ObjetSouris defs
        --- @type XmlNode
        local d_node = xmlDoc('C')('Z')('D')
        local ds_nodes = d_node:findChildren('DS')
        for i = 1, #ds_nodes do
            local ds = ds_nodes[i].attributes
            mapProp.mouseSpawns[i] = { x = ds['X'], y = ds['Y'] }
        end

        if #mapProp.mouseSpawns == 0 then
            -- Check using DS param property
            --- @type XmlNode
            local prop_node = xmlDoc('C')('P')
            local prop_attr = prop_node.attributes
            if prop_attr['DS'] then
                local spawns = prop_attr['DS']:match("^m;([,%d]*)$") or ""
                local spl = string_split(spawns, ',')
                for i = 1, #spl, 2 do
                    local x, y = spl[i], spl[i + 1]
                    if x and y then
                        mapProp.mouseSpawns[#mapProp.mouseSpawns + 1] = { x = x, y = y }
                    end
                end

                local axis, val = prop_attr['DS']:match("^([xy]);(%d*)$")
                if axis and val then
                    mapProp.mouseSpawnAxis[axis] = val
                end
            end
        end

        if #mapProp.mouseSpawns == 0 then
            -- Check using mouse hole
            local t_nodes = d_node:findChildren('T')
            for i = 1, #t_nodes do
                local t = t_nodes[i].attributes
                mapProp.mouseSpawns[i] = { x = t['X'], y = t['Y'] - 15 }
                if not self:isDualShaman() then
                    break
                end
            end
        end

        -- TODO: We could perhaps specifically separate DC and DC2 properties, since
        -- the array size is always expected to be 0 <= x <= 2

        local dc_nodes = d_node:findChildren('DC')
        for i = 1, #dc_nodes do
            local dc = dc_nodes[i].attributes
            mapProp.shamanSpawns[i] = { x = dc['X'], y = dc['Y'] }
        end

        if #dc_nodes > 0 then
            local dc2_nodes = d_node:findChildren('DC2')
            for i = 1, #dc2_nodes do
                local dc = dc2_nodes[i].attributes
                mapProp.shamanSpawns[#mapProp.shamanSpawns + 1] = { x = dc['X'], y = dc['Y'] }
            end
        end

        if #mapProp.shamanSpawns == 0 and self:isDualShaman() then
            -- Check using mouse hole
            local t_nodes = d_node:findChildren('T')
            for i = 1, #t_nodes do
                local t = t_nodes[i].attributes

                mapProp.shamanSpawns[#mapProp.shamanSpawns + 1] = { x = t['X'], y = t['Y'] - 15 }
                if #mapProp.shamanSpawns == 2 then break end
            end
        end
    end, ON_PCALL_ERR)

    -- Parse all grounds
    xpcall(function()
        self.grounds = TfmGround.fromXmlDoc(xmlDoc)
    end, ON_PCALL_ERR)
end

--- Sends the map info to everyone, or a specific player.
--- @param playerName? string
BtRound.sendMapInfo = function(self, playerName)
    local builder = self._cacheMapInfoBuilder
    if not builder then
        --- @type table<number, string|LocalisBuilder>
        local mapinfo_joins = {
            localis.evaluator:new("mapinfo_summary",
                -- @map, author
                "@" .. self.mapCode, self.author)
        }

        if self.isMirrored then
            mapinfo_joins[#mapinfo_joins + 1] = " "
            mapinfo_joins[#mapinfo_joins + 1] = localis.evaluator:new("mapinfo_mirrored")
        end

        local _props = self.mapProp
        if _props then
            mapinfo_joins[#mapinfo_joins + 1] = "\n"
            mapinfo_joins[#mapinfo_joins + 1] = localis.evaluator:new("mapinfo_summary_properties",
                -- wind, gravity
                _props.wind, _props.gravity,
                -- mgoc
                _props.mgoc)
        end

        builder = localis.joiner:new(mapinfo_joins)
        self._cacheMapInfoBuilder = builder
    end

    if playerName then
        local btp = btRoom.players[playerName]
        if btp then btp:tlbChatMsg(builder) end
    else
        btRoom.tlbChatMsg(builder)
    end
end

--- Undo the player's last spawned object in the round
--- @param playerName string # The player to target
BtRound.undoObject = function(self, playerName)
    local pspawned = self.spawnedObjects[playerName]
    if not pspawned or pspawned.size <= 0 then return end

    --- @type number
    local id = pspawned:pop_back()
    tfm.exec.removeObject(id)
end

--- Removes all objects spawned
--- @param playerName? string # The player to target. If this is `nil`, will target all players.
BtRound.clearAllObjects = function(self, playerName)
    if not playerName then
        -- Target all
        for _, pspawned in pairs(self.spawnedObjects) do
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

--- Checks if the map is of dual shaman perm
--- @return boolean
BtRound.isDualShaman = function(self)
    local perm_code = self.permCode
    if not perm_code then return false end

    return perm_code == 8
        or perm_code == 24
        or perm_code == 32
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
