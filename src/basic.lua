-- Controls the room's basic lifecycle

local WindowManager = require("window.window_manager")
local WindowEnums = require("btEnums").Window
local BtPlayer = require("entities.BtPlayer")
local BtRound = require("entities.BtRound")
local btRoom = require("modules.btRoom")
local timedTask = require("modules.timedTask")
local mapSched = require("modules.mapSched")

local api = btRoom.api
local tfmEvent = api.tfmEvent

local btPerms = require("permissions.btPerms")
local BT_CAP = btPerms.CAPFLAG

api:on('ready', function()
    mapSched.loadLeisure()
end)

tfmEvent:onCrucial('PlayerLeft', function(pn)
    local btp = btRoom.players[pn]
    if not btp then return end

    btRoom.tlChatMsg(nil, "chat.player_left", btp.name)

    btRoom.players[pn] = nil
end)

--- @param mbp mousebase.MbPlayer
api:onCrucial('newPlayer', function(mbp)
    local btp = BtPlayer:new(mbp)
    btRoom.players[mbp.name] = btp
    print("player ".. btp.name .. ";isAdmin:" .. tostring(btp.capabilities:hasFlag(BT_CAP.ADMIN)) )

    btRoom.tlChatMsg(nil, "chat.player_entered", btp.name)
    btp:tlChatMsg("chat.player_welcome")

    btp:normalRespawn()
end)

tfmEvent:onCrucial('NewGame', function()
    if btRoom.currentRound then
        btRoom.currentRound:deactivate()
        btRoom.currentRound = nil
    end

    local round = BtRound.fromRoom()

    round:once('ready', function()
        btRoom.currentRound = round

        round:sendMapInfo()
    end)

    round:activate()

    for name, _ in pairs(btRoom.players) do
        WindowManager.close(WindowEnums.GROUND_INFO, name)
    end
end)

tfmEvent:on('PlayerDied', function(pn)
    local btp = btRoom.players[pn]
    if not btp then return end

    btp:normalRespawn()
end)

tfmEvent:on('PlayerWon', function(pn)
    local btp = btRoom.players[pn]
    if not btp then return end

    btp:normalRespawn()
end)

tfmEvent:on('Loop', timedTask.onEventLoop)
