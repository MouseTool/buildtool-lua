-- Controls mouse or keyboard-related events

local btRoom = require("entities.bt_room")
local WindowManager = require("window.window_manager")
local BtEnums = require("bt-enums")

local api = btRoom.api
local tfmEvent = api.tfmEvent
local WindowEnums = BtEnums.Window
local Keys = BtEnums.Keys

-- Key trigger types
local DOWN_ONLY = 1
local UP_ONLY = 2
local DOWN_UP = 3

--- @class mousekey.KeyDesc
--- @field cb fun(btp: BtPlayer, k: integer, down: boolean, x: integer, y: integer) # The callback function triggered when the key is triggered
--- @field trigger "DOWN_ONLY" | "UP_ONLY" | "DOWN_UP"

--- @type table<number, mousekey.KeyDesc>
local KEY_EVENTS = {
    -- TODO: Testing only, to remove
    [Keys.SPACE] = {
        cb = function(btp, k, down, x, y)
            WindowManager.refocus(WindowEnums.SETTINGS, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Opens help menu
    [Keys.H] = {
        cb = function(btp, k, down, x, y)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Undo spawn
    [Keys.U] = {
        cb = function(btp, k, down, x, y)
            btp:undoObject()
        end,
        trigger = DOWN_ONLY
    },
    -- Opens room settings
    [Keys.O] = {
        cb = function(btp, k, down, x, y)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Toggles mouse spawn
    [Keys.M] = {
        cb = function(btp, k, down, x, y)
            if down then
                WindowManager.open(WindowEnums.MOUSE_SPAWN, btp.name)
            else
                WindowManager.close(WindowEnums.MOUSE_SPAWN, btp.name)
            end
        end,
        trigger = DOWN_UP
    },
}

tfmEvent:on('Keyboard', function(pn, k, down, x, y)
    local btp = btRoom.players[pn]
    if not btp then return end
    if not KEY_EVENTS[k] then return end

    KEY_EVENTS[k].cb(btp, k, down, x, y)
end)

--- @param mbp MbPlayer
api:onCrucial('newPlayer', function(mbp)
    -- Bind keys
    for id, key in pairs(KEY_EVENTS) do
        local pn = mbp.name
        if key.trigger == DOWN_ONLY then
            system.bindKeyboard(pn, id, true)
        elseif key.trigger == UP_ONLY then
            system.bindKeyboard(pn, id, false)
        elseif key.trigger == DOWN_UP then
            system.bindKeyboard(pn, id, true)
            system.bindKeyboard(pn, id, false)
        end
    end
end)
