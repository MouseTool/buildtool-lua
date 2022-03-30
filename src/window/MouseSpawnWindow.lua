local cookieUi          = require("@mousetool/cookie-ui")
local btIds             = require("modules.btIds")
local btRoom            = require("modules.btRoom")
local ImageComponent    = cookieUi.ImageComponent
local TextAreaComponent = cookieUi.TextAreaComponent


-- Sprites are scaled at 2x their actual size
local IMG_MOUSE = "179bc76e7eb.png"
local IMG_SHAMAN = "179bcd80032.png"

--- @class MouseSpawnWindow : cookie-ui.DefaultComponent
local MouseSpawnWindow = cookieUi.DefaultComponent:extend("MouseSpawnWindow")

function MouseSpawnWindow:draw()
    local round = btRoom.currentRound
    if not (round and round.mapProp) then return end

    local mouse_spawns = round.mapProp.mouseSpawns
    local shaman_spawns = round.mapProp.shamanSpawns

    for i = 1, math.min(#shaman_spawns, 10) do
        local s = shaman_spawns[i]
        self.controller:addComponent(
            TextAreaComponent:new(
                btIds.getNewTextAreaId(),
                "<font size='12'><R><b>S</b>",
                s.x - 5, s.y - 5, nil, nil, nil, nil, 0, false
            )
        )
        self.controller:addComponent(
            ImageComponent:new(IMG_SHAMAN, "!0", s.x, s.y,
                .5, .5, 0, 1, 0.62631578947, 0.73461538461)
        )
    end

    for i = 1, math.min(#mouse_spawns, 10) do
        local s = mouse_spawns[i]
        self.controller:addComponent(
            TextAreaComponent:new(
                btIds.getNewTextAreaId(),
                "<font size='12'><R><b>M</b>",
                s.x - 5, s.y - 5, nil, nil, nil, nil, 0, false
            )
        )
        self.controller:addComponent(
            ImageComponent:new(IMG_SHAMAN, "!0", s.x, s.y,
                .5, .5, 0, 1, 0.58641975308, 0.63131313131)
        )
    end
end

return MouseSpawnWindow
