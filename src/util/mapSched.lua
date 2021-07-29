
local btUtil = require "util.btUtil"

local timedTask = require("timed_task")
local btEnums = require("bt-enums")

--- This module controls the rotation of BT.
local mapSched = {}

local queue_task = nil
local call_after = nil
local NEWGAME_COOLDOWN = 3000

local awaiting_mapcode = nil
local awaiting_mapmode = nil

--- Loads a new map or queues to load it after the cooldown. This will override any existing map being queued.
--- @param mapCode? string The map code or data.
--- @param flipped? boolean Whether the map should be flipped.
--- @param mode? MapModeEnum (default MapModeEnum.NORMAL)
--- @see tfm.exec.newGame
function mapSched.loadCode(mapCode, flipped, mode)
    if timedTask.exists(queue_task) then
        timedTask.remove(queue_task)
    end
    local call_in = call_after and (call_after - os.time()) or 0
    if call_in > 0 then
        queue_task = timedTask.add(call_in, function()
            tfm.exec.newGame(mapCode, flipped)
            call_after = os.time() + NEWGAME_COOLDOWN
        end)
    else
        tfm.exec.newGame(mapCode, flipped)
        call_after = os.time() + NEWGAME_COOLDOWN
    end
    awaiting_mapcode = btUtil.intMapCode(mapCode)
    awaiting_mapmode = mode
end

local leisure = {'1564662', '1655932', '2845278', '2852771', '3078425', '3173473', '3178265', '3257261', '3361756', '3412288', '3601296', '4000002', '4942685', '4983947', '4994050', '5008162', '5025621', '5070570', '7427860', '5139956', '5165396', '5316685', '5365803', '5523036', '5820213', '5841255', '5859725', '5912389', '5917728', '5917786', '5918763','5927750', '5982865', '6009181', '6023878', '6026172', '6030416', '6157962','6168087', '6168097','6179809', '6672295', '6712216', '7029015', '7131514', '7426069', '7491094', '7492815', '988050'}

function mapSched.loadLeisure()
    mapSched.loadCode(leisure[math.random(1, #leisure)], nil, btEnums.MapModeEnum.LEISURE)
end

--- Called when a new game loads. Serveral checks are put in place and returned:
--- - Mapcode previously queued by load() matches the current
--- - Map mode
--- @return { isCodeAwaited?: boolean, mode: MapModeEnum  }
function mapSched.onNewGameCheck()
    local map_code = btUtil.intMapCode(tfm.get.room.currentMap)
    local code_awaited = nil
    if awaiting_mapcode ~= nil then
        code_awaited = (awaiting_mapcode == map_code)
    end
    local ret = {
        codeAwaited = code_awaited,
        mode = awaiting_mapmode or btEnums.MapModeEnum.UNKNOWN
    }
    awaiting_mapcode = nil
    awaiting_mapmode = nil
    return ret
end

return mapSched
