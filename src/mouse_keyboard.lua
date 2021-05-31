-- Controls mouse or keyboard-related events

local btRoom = require("entities.bt_room")
local WindowManager = require("window.window_manager")
local BtEnums = require("bt-enums")
local btPerms = require("permissions.bt_perms")

local api = btRoom.api
local tfmEvent = api.tfmEvent
local WindowEnums = BtEnums.Window
local Keys = BtEnums.Keys
local CAPFLAG = btPerms.CAPFLAG

local os_time = os.time

-- Key trigger types
local DOWN_ONLY = 1
local UP_ONLY = 2
local DOWN_UP = 3

local LOCK_TIMEOUT_MS = 10000
local CHECK_LOCK_INTERVAL_MS = 1000
--- { [playerName] = { [keyId] = expireAfterMs } }
--- @type table<string, table<number, number>>
local locked_keys = {}
--- After when the next loop can run to release keys
--- @type number|nil
local next_lock_check

--- @class mousekey.KeyDesc
--- @field cb fun(btp: BtPlayer, k: integer, down: boolean, x?: integer, y?: integer)|nil # The callback function triggered when the key is triggered
--- @field trigger "DOWN_ONLY" | "UP_ONLY" | "DOWN_UP"

--- @type table<number, mousekey.KeyDesc>
local KEY_EVENTS = {
    -- TODO: Testing only, to remove
    [Keys.SPACE] = {
        cb = function(btp, k)
            WindowManager.refocus(WindowEnums.SETTINGS, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Opens help menu
    [Keys.H] = {
        cb = function(btp, k)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Undo spawn
    [Keys.U] = {
        cb = function(btp, k)
            btp:undoObject()
        end,
        trigger = DOWN_ONLY
    },
    -- Opens room settings
    [Keys.O] = {
        cb = function(btp, k)
            WindowManager.toggle(WindowEnums.HELP, btp.name)
        end,
        trigger = DOWN_ONLY
    },
    -- Toggles mouse spawn
    [Keys.M] = {
        cb = function(btp, k, down)
            if down then
                WindowManager.open(WindowEnums.MOUSE_SPAWN, btp.name)
            else
                WindowManager.close(WindowEnums.MOUSE_SPAWN, btp.name)
            end
        end,
        trigger = DOWN_UP
    },
    [Keys.SHIFT] = {
        trigger = DOWN_UP
    },
}

tfmEvent:on('Keyboard', function(pn, k, down, x, y)
    local btp = btRoom.players[pn]
    if not btp then return end
    btp:triggerKey(k, down, x, y)
end)

btRoom.events:on('keyboard', function(btp, k, down, x, y)
    local key_ev = KEY_EVENTS[k]
    if not key_ev then return end

    if key_ev.trigger == DOWN_UP then
        local pn = btp.name
        if down then
            locked_keys[pn] = locked_keys[pn] or {}
            locked_keys[pn][k] = os_time() + LOCK_TIMEOUT_MS
        elseif locked_keys[pn] then
            locked_keys[pn][k] = nil
        end
    end

    local cb = key_ev.cb
    if cb then
        cb(btp, k, down, x, y)
    end
end)

-- Release locked keys after LOCK_TIMEOUT_MS
tfmEvent:on('Loop', function()
    if next_lock_check and os_time() <= next_lock_check then
        return
    end
    for name, keys in pairs(locked_keys) do
        local release, sz = {}, 0
        for k, expire_ms in pairs(keys) do
            if os_time() > expire_ms then
                sz = sz + 1
                release[sz] = k
            end
        end
        local btp = btRoom.players[name]
        if btp then
            for i = 1, sz do
                btp:triggerKey(release[i], false)
                locked_keys[release[i]] = nil
            end
        end
    end
end)

--- @param pn string # Player name
--- @param x number # Mouse click X
--- @param y number # Mouse click Y
tfmEvent:on('Mouse', function(pn, x, y)
    local btp = btRoom.players[pn]
    if not btp then return end

    local player_locked = locked_keys[pn]
    if btp.capabilities:hasFlag(CAPFLAG.ADMIN) and locked_keys then
        if player_locked[Keys.SHIFT] then
            tfm.exec.movePlayer(pn, x, y)
            -- Extend the timeout for shift
            player_locked[Keys.SHIFT] = os_time() + LOCK_TIMEOUT_MS
        end
    end
end)

tfmEvent:on('PlayerLeft', function(pn)
    locked_keys[pn] = nil
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
    system.bindMouse(mbp.name, true)
end)
