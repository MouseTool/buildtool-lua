-- Controls the room's basic lifecycle

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")
local BtPlayer = require("entities.BtPlayer")
local BtRound = require("entities.BtRound")

local api = btRoom.api
local tfmEvent = api.tfmEvent

local btPerms = require("permissions.bt_perms")
local BT_CAP = btPerms.CAPFLAG

tfmEvent:onCrucial('PlayerLeft', function(pn)
    local btp = btRoom.players[pn]
    if not btp then return end

    btRoom.tlChatMsg(nil, "player_left", btp.name)

    btRoom.players[pn] = nil
end)

--- @param mbp MbPlayer
api:onCrucial('newPlayer', function(mbp)
    local btp = BtPlayer:new(mbp)
    btRoom.players[mbp.name] = btp
    print("player ".. btp.name .. ";isAdmin:" .. tostring(btp.capabilities:hasFlag(BT_CAP.ADMIN)) )

    btRoom.tlChatMsg(nil, "player_entered", btp.name)
    btp:tlChatMsg("player_welcome")

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

        --- @type table<number, string|LocalisBuilder>
        local mapinfo_joins = {
            localis.evaluator:new("mapinfo_summary",
                -- @map, author
                "@" .. round.mapCode, round.author)
        }

        if round.isMirrored then
            mapinfo_joins[#mapinfo_joins + 1] = " "
            mapinfo_joins[#mapinfo_joins + 1] = localis.evaluator:new("mapinfo_mirrored")
        end

        local _props = round.mapProp
        mapinfo_joins[#mapinfo_joins + 1] = "\n"
        mapinfo_joins[#mapinfo_joins + 1] = localis.evaluator:new("mapinfo_summary_properties",
            -- wind, gravity
            _props.wind, _props.gravity,
            -- mgoc
            _props.mgoc)

        btRoom.tlbChatMsg(localis.joiner:new(mapinfo_joins))
    end)

    round:activate()
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
