local cookieUi          = require("@mousetool/cookie-ui")
local btIds             = require("modules.btIds")
local TfmGround         = require("entities.TfmGround")
local btRoom            = require("modules.btRoom")
local LinkExporter      = require("components.LinkExporter")
local GroundType        = TfmGround.GroundType
local groundTypeNames   = TfmGround.typeNames
local TextAreaComponent = cookieUi.TextAreaComponent

--- Displays the properties of a ground
--- @class GroundInfoWindow : cookie-ui.DefaultComponent
--- @field linkifyId util.linkify.idType
local GroundInfoWindow = cookieUi.DefaultComponent:extend("GroundInfoWindow")

local COLOR_BG = 0x402A1D
local MAX_TA_WIDTH = 168
local MAX_TA_HEIGHT = 198

-- used for performing space calculations
local NORMAL_OFFSET = 8 -- left, right, bottom
local TOP_OFFSET = 28 -- accounts for map title bar interface


--- Displays a ground info.
--- @param ground TfmGround
--- @param x? integer (default 200)
--- @param y? integer (default 200)
function GroundInfoWindow:_init(ground, x, y)
    self.ground = ground
    self.x = x
    self.y = y
end

function GroundInfoWindow:draw()
    local btp = btRoom.players[self.controller.playerName]
    if not btp then
        print("Warning: Opening window for non btp ?" .. self.controller.playerName)
    end

    local T_TRUE = btp:tlGet("groundinfo.true")
    local T_FALSE = btp:tlGet("groundinfo.false")
    local T_INVISIBLE = btp:tlGet("groundinfo.invisible")
    local T_MOUSE = btp:tlGet("groundinfo.mouse")
    local T_OBJECT = btp:tlGet("groundinfo.object")
    local T_ALL = btp:tlGet("groundinfo.all")

    local ground, x, y = self.ground, self.x, self.y
    local color = "-"
    if ground:isColoredGround() then
        if ground:isColorInvisible() then
            color = T_INVISIBLE
        elseif ground.color then
            color = ("<J>#%06x"):format(ground.color)
        end
    end

    local collision = T_FALSE
    if ground.miceCollision then
        collision = ground.objectCollision and T_ALL or T_MOUSE
    elseif ground.objectCollision then
        collision = ground.miceCollision and T_ALL or T_OBJECT
    end

    -- Create a new close link
    local closeLink = LinkExporter:new()
        :on("click", function()
            self.controller:destroy()
        end)
    self.controller:addComponent(closeLink)

    local wrapInLink = function(content, link)
        return "<a href='" .. link .. "'>" .. content .. "</a>"
    end
    local text = "<p><textformat tabstops='[4,145]'>" .. wrapInLink(
        ("\t<b>%s (ID: %s)</b> \t %s"):format(
            btp:tlGet("ground." .. groundTypeNames[ground.type] or groundTypeNames[GroundType.Wood]),
            ground.type,
            "×\n"
        ),
        closeLink.href
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
        btp:tlGet("groundinfo.properties",
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
    x = (x + MAX_TA_WIDTH + NORMAL_OFFSET <= map_width and x > NORMAL_OFFSET and x) -- is within boundaries
        or (x < NORMAL_OFFSET and NORMAL_OFFSET) -- keep within left boundary
        or (map_width - MAX_TA_WIDTH - NORMAL_OFFSET) -- keep within right boundary

    y = (y + MAX_TA_HEIGHT + NORMAL_OFFSET <= map_height and y > TOP_OFFSET and y) -- is within boundaries
        or (y < TOP_OFFSET and TOP_OFFSET) -- keep within top boundary
        or (map_height - MAX_TA_HEIGHT - NORMAL_OFFSET) -- keep within bottom boundary

    self.controller:addComponent(
        TextAreaComponent:new(
            btIds.getNewTextAreaId(), text, x, y, MAX_TA_WIDTH, MAX_TA_HEIGHT,
            COLOR_BG, nil, 0.9, false
        )
    )
end

return GroundInfoWindow
