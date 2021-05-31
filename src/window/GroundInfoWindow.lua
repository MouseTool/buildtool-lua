--- Shows the properties of a ground
--- @class GroundInfoWindow : Window
--- @field gInfoId integer # The main textarea ID of the window
local GroundInfoWindow = require("Window"):extend("MouseSpawnWindow")

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")

local COLOR_BG = 0x402A1D

GroundInfoWindow.doRender = function(self)
end

--- Displays a ground info.
--- @param ground TfmGround
GroundInfoWindow.displayGInfo = function(self, ground)
    if self.gInfoId then
        self:removeTextArea(self.gInfoId)
        self.gInfoId = nil
    end

    local btp = btRoom.players[self.pn]
    if not btp then return end

    local T_TRUE = btp:tlGet("ui_ginfo_true")
    local T_FALSE = btp:tlGet("ui_ginfo_true")

    -- <N>Z-Index: \t%s\t <N>Type: \t%s
    -- <N>X: \t%s\t <N>Y: \t%s
    -- <N>Length: \t%s\t <N>Height: \t%s
    -- <N>Friction: \t%s\t <N>Restitution: \t%s
    -- <N>Angle: \t%s\t <N>Disappear: \t%s
    -- <N>Color: \t%s\t <N>Dynamic: \t%s
    -- <N>Mass: \t%s\t <N>Fixed Rotation: \t%s
    local text = "<textformat tabstops='[90,150,240]'>" ..
        btp:tlGet("ui_ginfo_properties",
            ground.zIndex, ground.type,
            ground.x, ground.y,
            ground.width, ground.height,
            ground.friction, ground.restitution,
            ground.angle, ground.vanish or T_FALSE,
            ground.color, ground.dynamic and T_TRUE or T_FALSE,
            ground.mass, ground.fixedRotation and T_TRUE or T_FALSE)

    self.gInfoId = self:addTextArea(nil, text, 200, 200, nil, nil, COLOR_BG,
        nil, 0.95, false)
end

return GroundInfoWindow
