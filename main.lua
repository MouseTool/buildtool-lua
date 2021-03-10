local api = require("transformice").Api()

local KEY_E = 69

api:on("newPlayer", function(player)
    api.chatMessage("Welcome to buildtowol 2.5 very very super duper beta: " .. player.name)
    api.bindKeyboard(player.name, KEY_E, true)

    player:freeze()

    player:on("left", function()
        api.chatMessage("Left room: " .. player.name)
    end)

    player:on("keyboard", function(k, down, xPos, yPos)
        if k == KEY_E then
            local vx = 30
            vx = player.isFacingRight and vx or -vx
            local x = 10
            x = player.isFacingRight and xPos + x or xPos - x
            api.addShamanObject(34, x, yPos, 0, vx)
            api.chatMessage(player.name .. "threw a snowball.")
        end
    end)
end)

api:start()
