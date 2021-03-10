-- Ordered table (dictionary) implementation
-- Preserves order in the insertion of keys when traversing through the table.
-- Example usage:
-- ```
-- local myOdt = OrderedTable:new()
-- myOdt["One"] = true
-- myOdt["Two"] = true
-- myOdt["Three"] = true
-- myOdt["Two"] = true
-- for key in myOdt:pairs() do
--   print(key)
-- end
-- -- One
-- -- Two
-- -- Three
-- ```
-- The table can accept any standard index key except the following which are
-- reserved:
-- a. pairs

local OrderedTable = {}
do
    local nextOdt = function(tbl, index)
        local next_key
        if not index then
            -- First item
            next_key = tbl._keys._front._item
        else
            local node = tbl._keyNodes[index]
            if not node then return nil end
            local next_node = node._next
            if not next_node then return nil end
            next_key = next_node._item
        end
        return next_key, tbl._items[next_key]
    end
    local odtPairs = function(tbl)
        return nextOdt, tbl, nil
    end

    local mt = {
        __newindex = function(tbl, index, val)
            if not tbl._items[index] then
                -- Add new key
                local keys = tbl._keys
                local node = {
                    _next = nil,
                    _prev = keys._back,
                    _item = index
                }
                if keys._back then
                    keys._back._next = node
                    keys._back = node
                end
                if not keys._front then
                    keys._front = node
                    keys._back = node
                end
                tbl._keyNodes[index] = node
                keys.length = keys.length + 1
            end
            if not val then
                -- Remove existing key
                local node = tbl._keyNodes[index]
                local keys = tbl._keys
                if node._prev then
                    node._prev._next = node._next
                else
                    -- This node is the front, set the front to the next
                    keys._front = node._next
                end
                if not node._next then
                    -- This node is the back, set the back to the prev
                    keys._back = node._prev
                end
                tbl._keyNodes[index] = nil
                keys.length = keys.length - 1
            end
            tbl._items[index] = val
        end,
        __index = function(tbl, index)
            if index == "pairs" then return odtPairs end
            return tbl._items[index]
        end,
        --__pairs = odtPairs
    }

    OrderedTable.new = function(odt)
        tbl = {}
        tbl._items = {}
        tbl._keys = { _front = nil, _back = nil, length = 0 }
        tbl._keyNodes = {}
        return setmetatable(tbl, mt)
    end
end

local myOdt = OrderedTable:new()
myOdt["One"] = true
 myOdt["Two"] = nil
 myOdt["Three"] = true
 myOdt["Two"] = true
 for key in myOdt:pairs() do
   print(key)
 end