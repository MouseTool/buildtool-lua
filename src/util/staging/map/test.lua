local Map = require("init")

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

--- @type Map<string, integer>
local myMap = Map:new()
myMap:set("One", 1)
myMap:set("Two", 2)
myMap:set("Three", 3)

assert(myMap:get("Two") == 2)

myMap:set("Two", 22)

assert(myMap:get("One") == 1)
assert(myMap:get("Two") == 22)

-- Test front insert
myMap:set("Zero", 0, true)
assert(myMap:get("Zero") == 0)

assert(myMap:size() == 4)

-- assert order
do
    local order = {
        "Zero",
        "One",
        "Two",
        "Three"
    }

    local i = 1
    for key, v in myMap:pairs() do
        print(key, v)
        assert(key == order[i])
        i = i + 1
    end

    i = #order
    for key, v in myMap:reverseKeysIter() do
        assert(key == order[i])
        i = i - 1
    end
end
