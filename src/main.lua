local globals = require("bt-vars")
local api = globals.api
local tfmEvent = api.tfmEvent

local btRoom = require("entities.bt_room")
local localis = require("localisation.localis_manager")
local BtPlayer = require("entities.BtPlayer")
local BtRound = require("entities.BtRound")
local WindowManager = require("window.window_manager")
local roomSets = require("settings.RoomSettings")

local BtEnums = require("bt-enums")
local WindowEnums = BtEnums.Window

local btPerms = require("permissions.bt_perms")
local BT_CAP = btPerms.CAPFLAG

-- Poor man's micro optimization
local roomGet = tfm.get.room

-- Add custom globals
do
    dumptbl = function(tbl, indent, cb)
        if not indent then indent = 0 end
        if not cb then cb = print end
        if indent > 6 then
            cb(string.rep("  ", indent) .. "...")
            return
        end
        for k, v in pairs(tbl) do
            formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                cb(formatting)
                dumptbl(v, indent+1, cb)
            elseif type(v) == 'boolean' then
                cb(formatting .. tostring(v))
            elseif type(v) == "function" then
                cb(formatting .. "()")
            else
                cb(formatting .. v)
            end
        end
    end

    -- Apply patched globals
    require("@mousetool/mousebase").overloads.applyGlobal()
end

--[[ External Init ]]
require("commands.bt-init")
require("translations.bt-init")

--[[ Main Init ]]
tfmEvent:on('Keyboard', function(pn, k, down, x, y)
    if k == 72 then
        WindowManager.toggle(WindowEnums.HELP, pn)
    end
    if k==32 then  --tmp test
        WindowManager.refocus(WindowEnums.SETTINGS, pn)
    end
    if k == 79 then
        WindowManager.toggle(WindowEnums.SETTINGS, pn)
    end
end)

tfmEvent:onCrucial('PlayerLeft', function(pn)
    local btp = globals.players[pn]
    if not btp then return end

    globals.players[pn] = nil
end)

--- @param mbp MbPlayer
api:onCrucial('newPlayer', function(mbp)
    local btp = BtPlayer:new(mbp)
    globals.players[mbp.name] = btp
    btRoom.moduleMsgDirect("player ".. btp.name .. ";isAdmin:" .. tostring(btp.capabilities:hasFlag(BT_CAP.ADMIN)) )

    btp:tlChatMsg("player_welcome")

    system.bindKeyboard(btp.name, 72, true, true)
    system.bindKeyboard(btp.name, 32, true, true)  -- tmp
    system.bindKeyboard(btp.name, 79, true, true)

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
    local btp = globals.players[pn]
    if not btp then return end

    btp:normalRespawn()
end)

for _,v in ipairs({'AfkDeath','AllShamanSkills','AutoNewGame','AutoScore','AutoTimeLeft','PhysicalConsumables'}) do
    tfm.exec['disable'..v](true)
end
system.disableChatCommandDisplay(nil,true)

api:start()
