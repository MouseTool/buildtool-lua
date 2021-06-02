--- Shows the properties of a ground
--- @class GroundInfoWindow : Window
--- @field gInfoId integer # The main textarea ID of the window
local GroundInfoWindow = require("Window"):extend("MouseSpawnWindow")

local TfmGround = require("entities.TfmGround")
local btRoom = require("entities.bt_room")
local btEnums = require("bt-enums")
local WindowEnum = btEnums.Window
local GroundType = TfmGround.GroundType
local groundTypeNames = TfmGround.typeNames

local COLOR_BG = 0x402A1D
local MAX_TA_WIDTH = 168
local MAX_TA_HEIGHT = 198

-- used for performing space calculations
local NORMAL_OFFSET = 8  -- left, right, bottom
local TOP_OFFSET = 28    -- accounts for map title bar interface

GroundInfoWindow.TYPE_ID = WindowEnum.GROUND_INFO
GroundInfoWindow.UNFOCUS_BEHAVIOR = btEnums.WindowUnfocus.NONE
GroundInfoWindow.ON_FOCUS_BEHAVIOR = btEnums.WindowOnFocus.NONE

--- Displays a ground info.
--- @param ground TfmGround
--- @param x? integer (default 200)
--- @param y? integer (default 200)
GroundInfoWindow.displayGInfo = function(self, ground, x, y)
    if self.gInfoId then
        self:removeTextArea(self.gInfoId)
        self.gInfoId = nil
    end

    local btp = btRoom.players[self.pn]
    if not btp then return end

    local T_TRUE = btp:tlGet("ui_ginfo_true")
    local T_FALSE = btp:tlGet("ui_ginfo_false")
    local T_INVISIBLE = btp:tlGet("ui_ginfo_invisible")
    local T_MOUSE = btp:tlGet("ui_ginfo_mouse")
    local T_OBJECT = btp:tlGet("ui_ginfo_object")

    local color = "-"
    if ground:isColoredGround() then
        if ground:isColorInvisible() then
            color = T_INVISIBLE
        elseif ground.color then
            color = ("<J>#%06x"):format(ground.color)
        end
    end

    local collision = (ground.miceCollision and T_MOUSE)
            or (ground.objectCollision and T_OBJECT)
            or T_FALSE

    local text = "<p><textformat tabstops='[4,145]'>" .. self:closifyContent(
        ("\t<b>%s (ID: %s)</b> \t %s"):format(
            btp:tlGet("ground_" .. groundTypeNames[ground.type] or groundTypeNames[GroundType.Wood]),
            ground.type,
            "×\n"
        )
    ) .. "</p>"

    -- <N>Z-Index: \t %s
    -- <N>Position (X,Y): \t %s,%s
    -- <N>Length: \t %s
    -- <N>Height: \t %s
    -- <N>Friction: \t %s
    -- <N>Restitution: \t %s
    -- <N>Angle: \t %s
    -- <N>Disappear: \t %s
    -- <N>Collision: \t %s
    -- <N>Color: \t %s
    -- <N>Dynamic: \t %s
    -- <N>Mass: \t %s
    text = text .. "<TG><textformat tabstops='[88]'>" ..
        btp:tlGet("ui_ginfo_properties",
            ground.zIndex,
            ground.x, ground.y,
            ground.width, ground.height,
            ground.friction, ground.restitution,
            ground.angle, ground.vanish or T_FALSE,
            collision, color, ground.dynamic and T_TRUE or T_FALSE,
            ground.mass)

    local map_width, map_height = 800, 400
    if btRoom.currentRound and btRoom.currentRound.mapProp then
        local map_prop = btRoom.currentRound.mapProp
        map_width = map_prop.length
        map_height = map_prop.height
    end

    x = x or 200
    y = y or 200

    -- Ensure window is within boundaries
    x = (x + MAX_TA_WIDTH + NORMAL_OFFSET <= map_width and x > NORMAL_OFFSET and x)  -- is within boundaries
        or (x < NORMAL_OFFSET and NORMAL_OFFSET)  -- keep within left boundary
        or (map_width - MAX_TA_WIDTH - NORMAL_OFFSET)  -- keep within right boundary

    y = (y + MAX_TA_HEIGHT + NORMAL_OFFSET <= map_height and y > TOP_OFFSET and y) -- is within boundaries
        or (y < TOP_OFFSET and TOP_OFFSET)  -- keep within top boundary
        or (map_height - MAX_TA_HEIGHT - NORMAL_OFFSET)  -- keep within bottom boundary

    self.gInfoId = self:addTextArea(nil, text, x, y, MAX_TA_WIDTH, MAX_TA_HEIGHT, COLOR_BG,
        nil, 0.9, false)
end

return GroundInfoWindow
