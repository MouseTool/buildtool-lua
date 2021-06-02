--- Represents a XML map ground in Transformice.
--- @class TfmGround : Class
--- @field type integer # The ground type ID.
--- @field x integer # Initial horizontal position.
--- @field y integer # Initial vertical position.
--- @field width integer # Ground width. When a circle, this refers to the radius.
--- @field height integer # Ground height.
--- @field foreground boolean
--- @field friction float
--- @field restitution float
--- @field angle integer
--- @field miceCollision boolean
--- @field objectCollision boolean
--- @field dynamic boolean
--- @field fixedRotation boolean
--- @field mass integer
--- @field linearDamping float
--- @field angularDamping float
--- @field color integer|nil # The color of the ground. When `nil` and a colored ground, it by convention means invisible.
--- @field vanish integer|nil # The time in milliseconds after which the ground will disappear
--- @field zIndex integer|nil # The Z-Index of the ground in the map
--- @field luaId integer|nil # The Lua ID of the ground.
local TfmGround = require("@mousetool/mousebase").Class:extend("TfmGround")

local TfmGroundEnum = require("TfmGroundEnum")
local mathGeometry = require("util.math_geometry")
local string_split = require("util.stringlib").split
local GroundType = TfmGroundEnum.GroundType

-- todo types enum
-- Set default properties
do
    local _DEFAULT_PROPS = {
        { "type", 0 }, { "x", 0 }, { "y", 0 },
        { "width", 10 }, { "height", 10 }, { "foreground", false },
        { "friction", 0.3 }, { "restitution", 0.2 }, { "angle", 0 },
        { "miceCollision", true }, { "objectCollision", true }, { "dynamic", false },
        { "fixedRotation", 0 }, { "mass", 0 }, { "linearDamping", 0 },
        { "angularDamping", 0 }
    }
    for i = 1, #_DEFAULT_PROPS do
        local def = _DEFAULT_PROPS[i]
        TfmGround[def[1]] = def[2]
    end
end

local TYPE_CIRCLE = 13

--- Checks if given point is within the ground.
--- @param pointX integer
--- @param pointY integer
--- @return boolean
TfmGround.isPointInside = function(self, pointX, pointY)
    if self.type == TYPE_CIRCLE then
        return mathGeometry.isPointInCircle(self.x, self.y, self.width, pointX, pointY)
    end
    return mathGeometry.isPointInRect(self.x, self.y, self.width, self.height, self.angle, pointX, pointY)
end

--- Checks if the ground is a rectangle or circle.
--- @return boolean
TfmGround.isColoredGround = function(self)
    return self.type == GroundType.Rectangle
        or self.type == GroundType.Circle
end

--- Checks if the ground's color is invisible.
--- Note that this refers to the color property, and is different from the generic invisible property.
--- @return boolean
TfmGround.isColorInvisible = function(self)
    return self.color == nil
        or self.color == 0xffffffff
end

--- Instantiate an array of grounds from the map XML document.
--- @param xmlDoc XmlDoc
--- @return TfmGround[]
TfmGround.fromXmlDoc = function(xmlDoc)
    --- @type TfmGround[]
    local result = {}
    --- @type XmlNode[]
    local s_nodes = xmlDoc('C')('Z')('S'):findChildren('S')
    for i = 1, #s_nodes do
        local attr = s_nodes[i].attributes
        local ground = TfmGround:new()
        ground.type = tonumber(attr['T'])
        ground.x = tonumber(attr['X'])
        ground.y = tonumber(attr['Y'])
        ground.width = tonumber(attr['L'])
        ground.height = tonumber(attr['H'])
        ground.foreground = attr['N'] ~= nil
        ground.vanish = tonumber(attr['v'])
        ground.zIndex = i - 1

        if attr['c'] then
            local c = tonumber(attr['c'])
            if c == 0 or c == 1 then
                ground.miceCollision = true
                ground.objectCollision = true
            elseif c == 2 then
                ground.miceCollision = false
                ground.objectCollision = true
            elseif c == 3 then
                ground.miceCollision = true
                ground.objectCollision = false
            end
            ground.miceCollision = false
            ground.objectCollision = false
        end

        -- Set color for colored grounds
        if ground.type == GroundType.Rectangle
        or ground.type == GroundType.Circle then
            ground.color = attr['o'] and (tonumber(attr['o'], 16) or true)
        end

        -- Read P attribute
        if attr['P'] then
            local props = string_split(attr['P'], ',')
            ground.dynamic = tonumber(props[1]) == 1
            ground.mass = tonumber(props[2])
            ground.friction = tonumber(props[3])
            ground.restitution = tonumber(props[4])
            ground.angle = tonumber(props[5])
            ground.fixedRotation = tonumber(props[6])
            ground.linearDamping = tonumber(props[7])
            ground.angularDamping = tonumber(props[8])
        end

        result[i] = ground
    end

    return result
end

TfmGround.GroundType = GroundType
TfmGround.typeNames = TfmGroundEnum.typeNames

return TfmGround
