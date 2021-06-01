--- Shows the properties of a ground
--- @class GroundInfoWindow : Window
--- @field gInfoId integer # The main textarea ID of the window
local GroundInfoWindow = require("Window"):extend("MouseSpawnWindow")

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")
local WindowEnum = require("bt-enums").Window

local COLOR_BG = 0x402A1D
local MAX_TA_WIDTH = 165
local MAX_TA_HEIGHT = 180

-- used for performing space calculations
local NORMAL_OFFSET = 8  -- left, right, bottom
local TOP_OFFSET = 28    -- accounts for map title bar interface

GroundInfoWindow.TYPE_ID = WindowEnum.GROUND_INFO
GroundInfoWindow.UNFOCUS_BEHAVIOR = require("bt-enums").WindowUnfocus.NONE
GroundInfoWindow.ON_FOCUS_BEHAVIOR = require("bt-enums").WindowOnFocus.NONE

GroundInfoWindow.doRender = function(self)
end

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
    local T_FALSE = btp:tlGet("ui_ginfo_true")

    -- <N>Z-Index: \t%s
    -- <N>Type: \t%s
    -- <N>X, Y: \t%s, %s
    -- <N>Length: \t%s
    -- <N>Height: \t%s
    -- <N>Friction: \t%s
    -- <N>Restitution: \t%s
    -- <N>Angle: \t%s
    -- <N>Disappear: \t%s
    -- <N>Color: \t#%x
    -- <N>Dynamic: \t%s
    -- <N>Mass: \t%s
    local text = ("<TD>%s<TG><textformat tabstops='[80,150]'>"):format(self:closifyContent("×\n")) ..
        btp:tlGet("ui_ginfo_properties",
            ground.zIndex, ground.type,
            ground.x, ground.y,
            ground.width, ground.height,
            ground.friction, ground.restitution,
            ground.angle, ground.vanish or T_FALSE,
            ground.color and ([[<J>#%x]]):format(ground.color) or "<R>None",
            ground.dynamic and T_TRUE or T_FALSE, ground.mass)

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
