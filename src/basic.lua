-- Controls the room's basic lifecycle

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")
local BtPlayer = require("entities.BtPlayer")
local BtRound = require("entities.BtRound")
local WindowManager = require("window.window_manager")

local api = btRoom.api
local tfmEvent = api.tfmEvent
local BtEnums = require("bt-enums")
local WindowEnums = BtEnums.Window
local Keys = BtEnums.Keys

local btPerms = require("permissions.bt_perms")
local BT_CAP = btPerms.CAPFLAG

-- Key trigger types
local DOWN_ONLY = 1
local UP_ONLY = 2
local DOWN_UP = 3

--- @class basic.KeyDesc
--- @field cb fun(btp: BtPlayer, k: integer, down: boolean, x: integer, y: integer) # The callback function triggered when the key is triggered
--- @field trigger "DOWN_ONLY" | "UP_ONLY" | "DOWN_UP"

--- @type table<number, basic.KeyDesc>
local KEY_EVENTS = {
    -- TODO: Testing only, to remove
    [Keys.SPACE] = {
        cb = function(btp, k, down, x, y)
            WindowManager.refocus(WindowEnums.SETTINGS, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    [Keys.H] = {
        cb = function(btp, k, down, x, y)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    [Keys.O] = {
        cb = function(btp, k, down, x, y)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
}

tfmEvent:on('Keyboard', function(pn, k, down, x, y)
    local btp = btRoom.players[pn]
    if not btp then return end
    if not KEY_EVENTS[k] then return end

    KEY_EVENTS[k].cb(btp, k, down, x, y)
end)

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

    for id, key in pairs(KEY_EVENTS) do
        local pn = btp.name
        if key.trigger == DOWN_ONLY then
            system.bindKeyboard(pn, id, true)
        elseif key.trigger == UP_ONLY then
            system.bindKeyboard(pn, id, false)
        elseif key.trigger == DOWN_UP then
            system.bindKeyboard(pn, id, true)
            system.bindKeyboard(pn, id, false)
        end
    end

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
