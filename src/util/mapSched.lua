
local timedTask = require("timed_task")
local btEnums = require("bt-enums")

local queue_task = nil
local call_after = nil
local NEWGAME_COOLDOWN = 3000

local awaiting_mapcode = nil
local awaiting_mapmode = nil

local function load(code, mirror, mode)
    if timedTask.exists(queue_task) then
        timedTask.remove(queue_task)
    end
    local call_in = call_after and (call_after - os.time()) or 0
    if call_in > 0 then
        queue_task = timedTask.add(call_in, function()
            tfm.exec.newGame(code, mirror)
            call_after = os.time() + NEWGAME_COOLDOWN
        end)
    else
        tfm.exec.newGame(code, mirror)
        call_after = os.time() + NEWGAME_COOLDOWN
    end
    awaiting_mapcode = code
    awaiting_mapmode = mode
end

--- Called when a new game loads. Serveral checks are put in place and returned:
--- - Mapcode previously queued by load() matches the current
--- - Map mode
--- @return { isCodeAwaited?: boolean, mode: MapModeEnum  }
local function onNewGameCheck()
    local map_code = tonumber(tfm.get.room.currentMap:match("@?(%d+)")) or 0
    local code_awaited = nil
    if map_code ~= nil then
        code_awaited = map_code == awaiting_mapcode
    end
    local ret = {
        codeAwaited = code_awaited,
        mode = awaiting_mapmode or btEnums.MapModeEnum.UNKNOWN
    }
    awaiting_mapcode = nil
    awaiting_mapmode = nil
    return ret
end

return {
    load = load,
    onNewGameCheck = onNewGameCheck,
}
