--- @class MouseSpawnWindow : Window
local MouseSpawnWindow = require("Window"):extend("MouseSpawnWindow")

local btRoom = require("entities.bt_room")

-- Sprites are scaled at 2x their actual size
local IMG_MOUSE = "179bc76e7eb.png"
local IMG_SHAMAN = "179bcd80032.png"

MouseSpawnWindow.doRender = function(self)
    local round = btRoom.currentRound
    if not (round and round.mapProp) then return end

    local mouse_spawns = round.mapProp.mouseSpawns
    local shaman_spawns = round.mapProp.shamanSpawns

    for i = 1, #shaman_spawns do
        local s = shaman_spawns[i]
        self:addImage(IMG_SHAMAN, "!1", s.x, s.y,
                .5, .5, 0, 1, 0.62631578947, 0.73461538461)
    end

    for i = 1, #mouse_spawns do
        local s = mouse_spawns[i]
        self:addImage(IMG_MOUSE, "!1", s.x, s.y,
                .5, .5, 0, 1, 0.58641975308, 0.63131313131)
    end
end

return MouseSpawnWindow
