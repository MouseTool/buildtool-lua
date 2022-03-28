--- Map implementation. Preserves order in the insertion of keys when traversing through the table, similar to the
--- [JavaScript Map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map).
---
--- @example
--- Example usage:
--- ```lua
--- --- @type Map<string, boolean>
--- local myMap = Map:new()
--- myMap:set("One", true)
--- myMap:set("Two", true)
--- myMap:set("Three", true)
--- myMap:set("Two", true)
---
--- print(myMap:get("One"))
--- for key, v  in myMap:pairs() do
---   print(key, v)
--- end
--- ```
---
--- If you only need to manipulate the keys and not the item value, keys() and
--- keysIter() will perform better than pairs() due to no indexing involved.
--- ```lua
--- for key in myMap:keysIter() do
---   print(key)
--- end
--- ```
--- @class Map : Class
--- @field _keyNodes table<Map.KeyType, Map.KeyNode> # A fast reference to a key's internal node.
--- @field _keys { _back: Map.KeyNode, _front: Map.KeyNode, length: number } # A mini doubly linked list of key nodes
--- @field _items table<string, any> # A fast reference to a key's value.
local Map = require("@mousetool.class"):extend("Map")

--- @class Map.KeyNode
--- @field _item string @The key
--- @field _next? Map.KeyNode @The next linked node
--- @field _prev? Map.KeyNode @The previous linked node

--- @alias Map.KeyType string|number|table

function Map:_init()
    self._items = {}
    self._keys = { _front = nil, _back = nil, length = 0 }
    self._keyNodes = {}
end

--- @param tbl Map
--- @param index Map.KeyType
local _next = function(tbl, index)
    local next_key
    if not index then
        -- First item
        local front = tbl._keys._front
        if not front then return nil end
        next_key = front._item
    else
        local node = tbl._keyNodes[index]
        if not node then return nil end
        local next_node = node._next
        if not next_node then return nil end
        next_key = next_node._item
    end
    return next_key, tbl._items[next_key]
end

--- @param tbl Map
--- @param index Map.KeyType
local _nextKey = function(tbl, index)
    local next_key
    if not index then
        -- First item
        local front = tbl._keys._front
        if not front then return nil end
        next_key = front._item
    else
        local node = tbl._keyNodes[index]
        if not node then return nil end
        local next_node = node._next
        if not next_node then return nil end
        next_key = next_node._item
    end
    return next_key
end

--- @param tbl Map
--- @param index Map.KeyType
local _reverseNext = function(tbl, index)
    local prev_key
    if not index then
        -- First item
        local back = tbl._keys._back
        if not back then return nil end
        prev_key = back._item
    else
        local node = tbl._keyNodes[index]
        if not node then return nil end
        local prev_node = node._prev
        if not prev_node then return nil end
        prev_key = prev_node._item
    end
    return prev_key, tbl._items[prev_key]
end

--- @param tbl Map
--- @param index Map.KeyType
local _reverseNextKey = function(tbl, index)
    local prev_key
    if not index then
        -- First item
        local back = tbl._keys._back
        if not back then return nil end
        prev_key = back._item
    else
        local node = tbl._keyNodes[index]
        if not node then return nil end
        local prev_node = node._prev
        if not prev_node then return nil end
        prev_key = prev_node._item
    end
    return prev_key
end

--- @generic T : Map, K : Map.KeyType, V
--- @param self T # T<K, V>
--- @param key K
--- @param val V
--- @return T
function Map:set(key, val)
    if not self._keyNodes[key] then
        -- Add new key
        local keys = self._keys
        local node = {
            _next = nil,
            _prev = keys._back,
            _item = key
        }
        if keys._back then
            keys._back._next = node
            keys._back = node
        end
        if not keys._front then
            keys._front = node
            keys._back = node
        end
        self._keyNodes[key] = node
        keys.length = keys.length + 1
        self._items[key] = val
    end
    return self
end

--- @generic T : Map, K : Map.KeyType, V
--- @param self T # T<K, V>
--- @param key K
--- @return boolean # `true` if an element in the Map object existed and has been removed, or `false` if the element does not exist.
function Map:delete(key)
    -- Remove existing key
    local node = self._keyNodes[key]
    if not node then
        return false
    end

    local keys = self._keys
    if node._prev then
        node._prev._next = node._next
    else
        -- This node is the front, set the front to the next
        keys._front = node._next
    end
    if node._next then
        node._next._prev = node._prev
    else
        -- This node is the back, set the back to the prev
        keys._back = node._prev
    end
    self._keyNodes[key] = nil
    keys.length = keys.length - 1
    self._items[key] = nil

    return true
end

--- @generic T : Map, K : Map.KeyType, V
--- @param self T<K, V>
--- @param key K
--- @return V?
function Map:get(key)
    return self._items[key]
end

--- @generic T : Map, K : Map.KeyType, V
--- @param self T<K, V>
--- @param key K
--- @return boolean
function Map:has(key)
    return self._keyNodes[key] ~= nil
end

--- Returns an iterator of the key-value pair.
--- @generic T: Map, K : Map.KeyType, V
--- @param self T
--- @return fun(map: Map<K, V>, index?: K):K, V
--- @return T
function Map:pairs()
    -- if not (self and self._keys) then
    --     error("Exepected table of type Map, got " .. type(self))
    --     return
    -- end
    return _next, self, nil
end

--- Returns a list of keys within the table, and a `length` property within it to expose the number
--- of keys efficiently.
--- @generic T : Map, K : Map.KeyType
--- @param self T
--- @return K[]
function Map:keys()
    -- if not (self and self._keys) then
    --     error("Expected table of type Map, got " .. type(self))
    --     return
    -- end
    local curr = self._keys._front
    local keys, klen = {}, 0
    while curr do
        klen = klen + 1
        keys[klen] = curr._item
        curr = curr._next
    end
    keys.length = klen
    return keys
end

--- Returns an iterator of the keys.
--- Similar to `Map.pairs()` but does not provide the value of the item.
--- @generic T : Map, K : Map.KeyType, V
--- @param self T
--- @return fun(map: Map<K, V>, index?: K):K
--- @return T
function Map:keysIter()
    -- if not (self and self._keys) then
    --     error("Expected table of type Map, got " .. type(self))
    --     return
    -- end
    return _nextKey, self, nil
end

--- @generic T: Map, K : Map.KeyType, V
--- @param self T
--- @return fun(map: Map<K, V>, index?: K):K, V
--- @return T
function Map:reversePairs()
    -- if not (self and self._keys) then
    --     error("Expected table of type Map, got " .. type(self))
    --     return
    -- end
    return _reverseNext, self, nil
end

--- @generic T : Map, K : Map.KeyType, V
--- @param self T
--- @return fun(map: Map<K, V>, index?: K):K
--- @return T
function Map:reverseKeysIter(self)
    -- if not (self and self._keys) then
    --     error("Expected table of type Map, got " .. type(self))
    --     return
    -- end
    return _reverseNextKey, self, nil
end

return Map
