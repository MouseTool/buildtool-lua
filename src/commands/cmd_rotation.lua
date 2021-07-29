local tfmcmd = require("commands.tfmcmd")
local btRoom = require("entities.bt_room")

local leisure = {'1564662', '1655932', '2845278', '2852771', '3078425', '3173473', '3178265', '3257261', '3361756', '3412288', '3601296', '4000002', '4942685', '4983947', '4994050', '5008162', '5025621', '5070570', '7427860', '5139956', '5165396', '5316685', '5365803', '5523036', '5820213', '5841255', '5859725', '5912389', '5917728', '5917786', '5918763','5927750', '5982865', '6009181', '6023878', '6026172', '6030416', '6157962','6168087', '6168097','6179809', '6672295', '6712216', '7029015', '7131514', '7426069', '7491094', '7492815', '988050'}

tfmcmd.registerCommand(
    tfmcmd.Main {
        name = "map",
        aliases = {"np"},
        args = {
            tfmcmd.ArgString { lower = true, optional = true },
            tfmcmd.ArgString { lower = true, optional = true },
        },
        --- @param ctx tfmcmd.CmdContext
        --- @param w2? string
        --- @param w3? string
        func = function(ctx, w2, w3)
            if w2 == 'history' then
            elseif w2 == 'back' then
            else
                local T = {p4='#4',p8='#8'}
                if w2 then
                    btRoom.loadMap(T[w2] or w2, w3=='mirror' and true or false)
                else
                    btRoom.loadMap(leisure[math.random(1, #leisure)])
                end
            end
        end
    }
)

tfmcmd.registerCommand(
    tfmcmd.Main {
        name = "rst",
        --- @param ctx tfmcmd.CmdContext
        func = function(ctx)
            local currentRound = btRoom.currentRound
            if not currentRound then
                local btp = btRoom.players[ctx.playerName]
                if btp then
                    btp:tlChatMsg("err_round_not_loaded")
                end
                return
            end
            tfm.exec.newGame(currentRound.mapCode)
        end
    }
)

tfmcmd.registerCommand(tfmcmd.Main {
    name = "score",
    args = {
        tfmcmd.ArgString { optional = true },
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param w2? string
    --- @param w3? string
    func = function(ctx, w2, w3)
        local invoker = btRoom.players[ctx.playerName]
        if not invoker then return end

        local score = tonumber(w2) or tonumber(w3) or 0
        local target = not tonumber(w2) and w2 or ctx.playerName
        if score < 0 or score > 999 then
            invoker:tlChatMsg("err_score_not_ranged", 0, 999)
        elseif w2 == "all" or w3 == "all" then
            for name, btp in pairs(btRoom.players) do
                tfm.exec.setPlayerScore(name, score)
            end
        elseif w2 == "me" or w3 == "me" then
            tfm.exec.setPlayerScore(ctx.playerName, score)
        else
            tfm.exec.setPlayerScore(target, score)
        end
    end
})
tfmcmd.registerCommand(tfmcmd.Main {
    name = "s",
    args = {
        tfmcmd.ArgString { optional = true },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param target? string
    func = function(ctx, target)
        local targetp = btRoom.players[target or ctx.playerName]
        if not targetp then return end

        local highest_score = nil
        for _, btp in pairs(btRoom.players) do
            local score = btp.mbp:getTfmPlayer().score
            if not highest_score or score > highest_score then
                highest_score = score
            end
        end

        tfm.exec.setPlayerScore(targetp.name, highest_score + 1)
    end
})
