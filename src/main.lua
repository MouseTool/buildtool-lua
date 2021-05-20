local globals = require("bt-vars")
local api = globals.api
local tfmEvent = api.tfmEvent

local btRoom = require("entities.bt_room")

local BtPlayer = require("entities.BtPlayer")
local WindowManager = require("window.window_manager")

local BtEnums = require("bt-enums")
local WindowEnums = BtEnums.Window

local btPerms = require("permissions.bt_perms")
local BT_CAP = btPerms.CAPFLAG

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
tfmEvent:on("Keyboard", function(pn, k, down, x, y)
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

tfmEvent:onCrucial("PlayerLeft", function(pn)
    local btp = globals.players[pn]
    if not btp then return end

    globals.players[pn] = nil
end)

--- @param mbp MbPlayer
api:on("newPlayer", function(mbp)
    local btp = BtPlayer:new(mbp)
    globals.players[mbp.name] = btp
    btRoom.moduleMsgDirect("player ".. btp.name .. ";isAdmin:" .. tostring(btp.capabilities:hasFlag(BT_CAP.ADMIN)) )

    btp:tlChatMsg("player_welcome")

    system.bindKeyboard(btp.name, 72, true, true)
    system.bindKeyboard(btp.name, 32, true, true)  -- tmp
    system.bindKeyboard(btp.name, 79, true, true)
end)

for _,v in ipairs({'AfkDeath','AllShamanSkills','AutoNewGame','AutoScore','AutoTimeLeft','PhysicalConsumables'}) do
    tfm.exec['disable'..v](true)
end
system.disableChatCommandDisplay(nil,true)

api:start()
