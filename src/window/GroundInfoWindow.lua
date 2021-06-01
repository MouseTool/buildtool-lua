--- Shows the properties of a ground
--- @class GroundInfoWindow : Window
--- @field gInfoId integer # The main textarea ID of the window
local GroundInfoWindow = require("Window"):extend("MouseSpawnWindow")

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")

local COLOR_BG = 0x402A1D

GroundInfoWindow.UNFOCUS_BEHAVIOR = require("bt-enums").WindowUnfocus.NONE
GroundInfoWindow.ON_FOCUS_BEHAVIOR = require("bt-enums").WindowOnFocus.NONE

GroundInfoWindow.doRender = function(self)
end

--- Displays a ground info.
--- @param ground TfmGround
--- @param x integer
--- @param y integer
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
    local text = "<textformat tabstops='[80,150]'>" ..
        btp:tlGet("ui_ginfo_properties",
            ground.zIndex, ground.type,
            ground.x, ground.y,
            ground.width, ground.height,
            ground.friction, ground.restitution,
            ground.angle, ground.vanish or T_FALSE,
            ground.color, ground.dynamic and T_TRUE or T_FALSE,
            ground.mass)

    self.gInfoId = self:addTextArea(nil, text, 200, 200, nil, nil, COLOR_BG,
        nil, 0.9, false)
end

return GroundInfoWindow
