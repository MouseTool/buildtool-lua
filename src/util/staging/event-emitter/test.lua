local eventEmitterModule = require("init")
local EventEmitter = eventEmitterModule.EventEmitter
local EventEmitterSet = eventEmitterModule.EventEmitterSet

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
            dumptbl(v, indent + 1, cb)
        elseif type(v) == 'boolean' then
            cb(formatting .. tostring(v))
        elseif type(v) == "function" then
            cb(formatting .. "()")
        else
            cb(formatting .. v)
        end
    end
end

do
    -- Normal evt emitter will call the same listener multiple times if asked
    do
        local evt = EventEmitter:new()

        local calledTimes = 0
        local function one(x)
            assert(x == true)
            calledTimes = calledTimes + 1
            evt:off("a", one)
        end

        evt:on("a", one)
        evt:on("a", one)

        evt:emit("a", true)
        assert(calledTimes == 2)
        assert(evt:listenerCount("a") == 0) -- bc one() removed
    end

    -- SetEvt only once
    do
        local evt = EventEmitterSet:new()

        local calledTimes = 0
        local function one(x)
            assert(x == true)
            calledTimes = calledTimes + 1
            evt:off("a", one)
        end

        evt:on("a", one)
        evt:on("a", one)

        evt:emit("a", true)
        assert(calledTimes == 1)
        assert(evt:listenerCount("a") == 0) -- bc one() removed
    end
end

-- test once()
do
    for _, E in ipairs({ EventEmitter, EventEmitterSet }) do
        local evt = E:new()

        local calledTimes = 0
        local function one()
            calledTimes = calledTimes + 1
        end

        evt:once("a", one)


        evt:emit("a")
        evt:emit("a")
        evt:emit("a")
        assert(calledTimes == 1)
    end
end

-- test prepend
do
    for _, E in ipairs({ EventEmitter, EventEmitterSet }) do
        local evt = E:new()

        local calledTimes = 0

        evt:on("a", function()
            -- should be +'d before
            assert(calledTimes == 2)
        end)

        evt:prependListener("a", function()
            calledTimes = calledTimes + 1
        end)

        evt:prependListener("a", function()
            calledTimes = calledTimes + 1
        end)

        evt:emit("a")
        assert(calledTimes == 2)
    end
end

print("Success")
