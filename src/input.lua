-- Controls user input events (mouse, keyboard, textarea, etc.)

local btRoom = require("modules.btRoom")
local WindowManager = require("window.window_manager")
local btEnums = require("btEnums")
local btPerms = require("permissions.btPerms")
local mathGeometry = require("util.mathGeometry")

local api = btRoom.api
local tfmEvent = api.tfmEvent
local WindowEnums = btEnums.Window
local Keys = btEnums.Keys
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
            WindowManager.toggle(WindowEnums.SETTINGS, btp.name)
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
    [Keys.G] = {
        trigger = DOWN_UP
    },
    [Keys.CTRL] = {
        trigger = DOWN_UP
    },
    [Keys.SHIFT] = {
        trigger = DOWN_UP
    },
    [Keys.ESC] = {
        trigger = DOWN_ONLY
    }
}

-- Trigger module keyboard event
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
    local ostime = os_time()
    if next_lock_check and ostime <= next_lock_check then
        return
    end
    next_lock_check = ostime + CHECK_LOCK_INTERVAL_MS
    for name, keys in pairs(locked_keys) do
        local release, sz = {}, 0
        for k, expire_ms in pairs(keys) do
            if ostime > expire_ms then
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

--- Searches all spawns and finds the matching object near `x, y` to delete
--- @param x integer
--- @param y integer
local function deleteObject(x, y)
    local round = btRoom.currentRound
    if round then
        local obj_list = tfm.get.room.objectList
        for _, pspawned in pairs(round.spawnedObjects) do
            for i, obj_id in pspawned:revipairs() do
                local object = obj_list[obj_id]
                if mathGeometry.isPointInCircle(object.x, object.y, 16, x, y) then
                    pspawned:remove(i)
                    tfm.exec.removeObject(obj_id)
                    return
                end
            end
        end
    end
end

--- @param pn string # Player name
--- @param x number # Mouse click X
--- @param y number # Mouse click Y
tfmEvent:on('Mouse', function(pn, x, y)
    local btp = btRoom.players[pn]
    if not btp then return end

    local player_locked = locked_keys[pn]
    local is_admin = btp.capabilities:hasFlag(CAPFLAG.ADMIN)
    local is_shaman = btp.mbp:getTfmPlayer().isShaman
    if player_locked then
        if player_locked[Keys.CTRL]
        and player_locked[Keys.SHIFT] then
            if is_shaman or is_admin then
                deleteObject(x, y)
            end
            -- Extend the timeout for ctrl and shift
            player_locked[Keys.CTRL] = os_time() + LOCK_TIMEOUT_MS
            player_locked[Keys.SHIFT] = os_time() + LOCK_TIMEOUT_MS
        elseif player_locked[Keys.SHIFT] then
            if is_admin then
                tfm.exec.movePlayer(pn, x, y)
            end
            -- Extend the timeout for shift
            player_locked[Keys.SHIFT] = os_time() + LOCK_TIMEOUT_MS
        elseif player_locked[Keys.G] then
            -- Extend the timeout for G
            player_locked[Keys.G] = os_time() + LOCK_TIMEOUT_MS

            local round = btRoom.currentRound
            if not round then
                btp:tlChatMsg("err_round_not_loaded")
                return
            end
            if not round.grounds then return end
            local found_g = nil
            for i = #round.grounds, 1, -1 do
                local ground = round.grounds[i]
                if ground:isPointInside(x, y) then
                    found_g = ground
                    break
                end
            end
            if found_g then
                WindowManager.open(WindowEnums.GROUND_INFO, btp.name)
                --- @type GroundInfoWindow
                local w_ginfo = WindowManager.getWindow(WindowEnums.GROUND_INFO, btp.name)
                if w_ginfo then
                    w_ginfo:displayGInfo(found_g, x, y)
                end
            else
                WindowManager.close(WindowEnums.GROUND_INFO, btp.name)
            end
        end
    end

    if btp.tpTarget and is_admin then
        local tp_target = btp.tpTarget
        if tp_target == true then
            for name in pairs(btRoom.players) do
                tfm.exec.movePlayer(name, x, y, false)
            end
        else -- type(tp_target) == "table"
            for i = 1, #tp_target do
                tfm.exec.movePlayer(tp_target[i], x, y, false)
            end
        end
        btp.tpTarget = nil
    end

    if btp.arrowMode and (is_admin or is_shaman) then
        tfm.exec.addShamanObject(0, x, y - 15)
        if btp.arrowMode == "single" then
            btp.arrowMode = nil
        end
    end
end)

--- Trigger module player callback event
--- @param textAreaId integer
--- @param playerName string
--- @param eventString string
tfmEvent:onCrucial('TextAreaCallback', function(textAreaId, playerName, eventString)
    local eventName, param_str = eventString:match('(%w+)!?(.*)')
    local btp = btRoom.players[playerName]
    if not (eventName and btp) then return end

    btRoom.textAreaEvents:emit(eventName, btp, param_str, textAreaId)
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
