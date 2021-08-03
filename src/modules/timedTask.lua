--- Task scheduler.
--- Serves as a wrapper for system.newTimer(), adding a failsafe method to run
--- tasks via eventLoop if system.newTimer does not work
local timed_task = {}

local TIMER_OFFSET_MS = 400
local tasks = {}
local last_id = 0

local add_task = function(use_timer, id, time_ms, cb, a1, a2, a3, a4)
    if id == nil then
        last_id = last_id + 1
        id = last_id
    end

    -- "A timer interval must be superior than 1000 ms."
    if not use_timer or time_ms < 1000 then
        -- Back to good ol' eventLoop
        tasks[id] = { nil, os.time() + time_ms, cb, {a1, a2, a3, a4} }
    else
        local timer_id = system.newTimer(function(_, a1, a2, a3, a4)
                if not tasks[id] then return end
                tasks[id] = nil
                cb(a1, a2, a3, a4)
            end, time_ms, false, a1, a2, a3, a4)
        tasks[id] = { timer_id, os.time() + time_ms + TIMER_OFFSET_MS, cb, {a1, a2, a3, a4} }
    end

    return id
end

--- Schedules a timed task to run after the specified time.
--- @param time_ms number
--- @param cb function
--- @param a1 any # Calls `cb` with this as the first argument
--- @param a2 any
--- @param a3 any
--- @param a4 any
--- @return number id
timed_task.add = function(time_ms, cb, a1, a2, a3, a4)
    return add_task(true, nil, time_ms, cb, a1, a2, a3, a4)
end

--- Schedules a timed task to run after the specified time.
--- Similar to `TimedTask.add`, but enforces that the `cb` be run only on `eventLoop`.
--- @see TimedTask.add
--- @param time_ms number
--- @param cb function
--- @param a1 any # Calls `cb` with this as the first argument
--- @param a2 any
--- @param a3 any
--- @param a4 any
--- @return number id
timed_task.addUseLoop = function(time_ms, cb, a1, a2, a3, a4)
    return add_task(false, nil, time_ms, cb, a1, a2, a3, a4)
end

--- Removes a timed task scheduled by `TimedTask.add`.
--- @param id number
timed_task.remove = function(id)
    if not id or not tasks[id] then return end
    if tasks[id][1] then
        system.removeTimer(tasks[id][1])
    end
    tasks[id] = nil
end

--- Checks if the timed task is still being scheduled.
--- @param id number
timed_task.exists = function(id)
    return id ~= nil and tasks[id]
end

--- Overrides a timed task scheduled by `TimedTask.add`.
--- Similar to `TimedTask.add`, but allows the timer ID to be reused.
--- @see TimedTask.add
--- @param time_ms number
--- @param cb function
--- @param a1 any # Calls `cb` with this as the first argument
--- @param a2 any
--- @param a3 any
--- @param a4 any
--- @return number id
timed_task.override = function(id, time_ms, cb, a1, a2, a3, a4)
    if id and tasks[id] then
        if tasks[id][1] then
            system.removeTimer(tasks[id][1])
        end
        tasks[id] = nil
    end
    return add_task(true, id, time_ms, cb, a1, a2, a3, a4)
end

--- Overrides a timed task scheduled by `TimedTask.add`, enforces that the `cb` be run only on `eventLoop`.
--- Similar to `TimedTask.addUseLoop`, but allows the timer ID to be reused.
--- @see TimedTask.addUseLoop
--- @param time_ms number
--- @param cb function
--- @param a1 any # Calls `cb` with this as the first argument
--- @param a2 any
--- @param a3 any
--- @param a4 any
--- @return number id
timed_task.overrideUseLoop = function(id, time_ms, cb, a1, a2, a3, a4)
    if id and tasks[id] then
        if tasks[id][1] then
            system.removeTimer(tasks[id][1])
        end
        tasks[id] = nil
    end
    return add_task(false, id, time_ms, cb, a1, a2, a3, a4)
end

--- Called on each event loop tick.
timed_task.onEventLoop = function()
    local done, sz = {}, 0
    for id, task in pairs(tasks) do
        if os.time() >= task[2] then
            if task[1] then
                -- timer did not execute in time
                system.removeTimer(task[1])
            end
            task[3](table.unpack(task[4]))
            sz = sz + 1
            done[sz] = id
        end
    end
    for i = 1, sz do
        tasks[done[i]] = nil
    end
end

return timed_task
