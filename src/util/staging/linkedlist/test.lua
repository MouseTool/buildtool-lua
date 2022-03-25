local DoublyLinkedList = require("init").DoublyLinkedList

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


--- @type linkedlist.DoublyLinkedList<string | number | { e: number }, nil>
local t = DoublyLinkedList:new()

t:fromArray({
    "i'm gone",
    "hahaha",
    34,
    {e=3},
    5.4
})

t:pushBack(6.6)
assert(t:back() == 6.6)
assert(t:getAt(t.size) == 6.6)

t:popBack()
assert(t:back() ~= 6.6)
assert(t:getAt(t.size) ~= 6.6)

t:pushFront(7.7)
assert(t:front() == 7.7)
assert(t:getAt(1) == 7.7)

t:popFront()
assert(t:front() ~= 7.7)
assert(t:getAt(1) ~= 7.7)

assert(t:popFront() == "i'm gone")

t:insertAfter(1, ":Oo")
assert(t:getAt(2) == ":Oo")

t:insertAfter(t.size, ":u")
assert(t:getAt(t.size) == ":u")
assert(t:back() == ":u")

t:pushBack(":P")
t:pushBack(":8")
assert(t:getAt(t.size - 1) == ":P")
t:popAt(t.size - 1)
assert(t:getAt(t.size - 1) == ":u")
assert(t:popBack() == ":8")
assert(t:back() == ":u")

dumptbl(t:toArray())
assert(#t:toArray() == #t:toReverseArray())

do
    local l = t:toArray()
    for i, v in t:pairs() do
        assert(v == l[i])
    end

    for i, v in t:reversePairs() do
        assert(v == l[i])
    end
end

do
    local ts = DoublyLinkedList:new():fromArray({"one", "two"})
    ts:popAt(1)
    assert(ts:front() == "two")
    assert(ts:back() == "two")

    ts = DoublyLinkedList:new():fromArray({"one", "two"})
    ts:popAt(2)
    assert(ts:front() == "one")
    assert(ts:back() == "one")
end
