local Class = require("@mousetool.class")

local exports = {}

--- Generic linked list implementation. \
--- All indexes and positions mentioned hereinafter start from `1`, corresponding to Lua table
--- array. This means that the first front element always has an index of `1`.
--- @class linkedlist.DoublyLinkedList : Class
--- @field protected _front? linkedlist.DoublyLinkedListNode @The front of the linked list
--- @field protected _back? linkedlist.DoublyLinkedListNode @The back of the linked list
--- @field public size integer @The length of the linked list
local DoublyLinkedList = Class:extend("DoublyLinkedList")
exports.DoublyLinkedList = DoublyLinkedList

-- TODO: Watch LLS [#980](https://github.com/sumneko/lua-language-server/issues/449)
-- May allow generics from classes to be used in fields, and don't require a second arg (currently no-op here)

-- TODO: Watch LLS [#911](https://github.com/sumneko/lua-language-server/issues/911)
-- May allow self:fromArray(array <- clear typing from generics)

-- TODO: watch LLS [#1000]((https://github.com/sumneko/lua-language-server/issues/1000)
-- May allow `--- @param self T<V, _>` and `@return T<V, _>`

--- @class linkedlist.DoublyLinkedListNode
--- @field value any @The value of the node
--- @field next? linkedlist.DoublyLinkedListNode @The next linked node
--- @field prev? linkedlist.DoublyLinkedListNode @The previous linked node

function DoublyLinkedList:_init()
    self.size = 0
end

--- Replaces the linked list with contents from an array
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T
--- @param array V[]
--- @return T
function DoublyLinkedList:fromArray(array)
    self:clear()
    for i = 1, #array do
        self:pushBack(array[i])
    end
    return self
end

--- @generic T : linkedlist.DoublyLinkedList
--- @param self T
--- @return T
function DoublyLinkedList:clear()
    self.size = 0
    self._front = nil
    self._back = nil
end

--- Inserts an element to the end
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T
--- @param value V Element value to insert
--- @return T
function DoublyLinkedList:pushBack(value)
    --- @type linkedlist.DoublyLinkedListNode
    local node = {
        value = value,
        prev = self._back
    }
    if not self._front then
        self._front = node
    end
    if self._back then
        self._back.next = node
    end
    self._back = node
    self.size = self.size + 1
    return self
end

--- Adds an element to the front
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T
--- @param value V Element value to insert
--- @return T
function DoublyLinkedList:pushFront(value)
    --- @type linkedlist.DoublyLinkedListNode
    local node = {
        value = value,
        next = self._front
    }
    if not self._back then
        self._back = node
    end
    if self._front then
        self._front.prev = node
    end
    self._front = node
    self.size = self.size + 1
    return self
end

--- Inserts an element after the specified position
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @param afterPosition integer Index before which the content will be inserted
--- @param value V Element value to insert
--- @return boolean success
function DoublyLinkedList:insertAfter(afterPosition, value)
    if afterPosition < 0 or afterPosition > self.size then
        return false
    end
    if afterPosition == 0 then
        self:pushFront(value)
        return true
    end

    local before_node = self._front
    for _ = 2, afterPosition do
        before_node = before_node.next
    end
    --- @type linkedlist.DoublyLinkedListNode
    local node = {
        value = value,
        prev = before_node,
        next = before_node.next,
    }
    before_node.next = node
    if node.next then
        node.next.prev = node
    else
        -- This node is the back
        self._back = node
    end
    self.size = self.size + 1
    return true
end

--- Inserts an element at the specified position
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @param position integer Index to insert the value in
--- @param value V Element value to insert
--- @return boolean success
function DoublyLinkedList:insertAt(position, value)
    return self:insertAfter(position - 1, value)
end

--- Removes and retrieves an element at the specified position
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @param position integer Index at which the content will be removed
--- @return V?
function DoublyLinkedList:popAt(position)
    if position <= 0 or position > self.size then
        return
    end
    --- @type linkedlist.DoublyLinkedListNode
    local target_node = self._front
    for _ = 2, position do
        target_node = target_node.next
    end
    if target_node.prev then
        target_node.prev.next = target_node.next
    else
        -- This node is the front
        self._front = target_node.next
    end
    if target_node.next then
        target_node.next.prev = target_node.prev
    else
        -- This node is the back
        self._back = target_node.prev
    end
    self.size = self.size - 1
    return target_node.value
end

--- Removes and retrieves the last element
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return V?
function DoublyLinkedList:popBack()
    if not self._back then
        return
    end
    local value = self._back.value
    self._back = self._back.prev
    if self._back then
        self._back.next = nil
    else
        self._front = nil
    end
    self.size = self.size - 1
    return value
end

--- Removes and retrieves the first element
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return V?
function DoublyLinkedList:popFront()
    if not self._front then
        return
    end
    local value = self._front.value
    self._front = self._front.next
    if self._front then
        self._front.prev = nil
    else
        self._back = nil
    end
    self.size = self.size - 1
    return value
end

--- Retrieves the last element
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return V?
function DoublyLinkedList:back()
    if not self._back then
        return
    end
    return self._back.value
end

--- Retrieves the first element
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return V?
function DoublyLinkedList:front()
    if not self._front then
        return
    end
    return self._front.value
end

--- Retreives the element at the specified position
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @param position integer Index of the element
--- @return V?
function DoublyLinkedList:getAt(position)
    if position <= 0 or position > self.size then
        return nil
    end
    local node = self._front
    for _ = 2, position do
        node = node.next
    end
    return node.value
end

--- Returns an iterator for the linked list
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return fun(_: T, i?: integer):integer, V
--- @return T
--- @return integer i
function DoublyLinkedList:pairs()
    local node = self._front
    local function iter(_, i)
        if not node then return nil end
        local val = node.value
        node = node.next
        return i + 1, val
    end

    return iter, node, 0
end

--- Returns an iterator for the linked list.
--- Similar to `ipairs()` but iterates in reverse (from back to front).
--- The index returned starts from the back instead of front.
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return fun(_: T, i?: integer):integer, V
--- @return T
--- @return integer i
function DoublyLinkedList:reversePairs()
    local node = self._back
    local function iter(_, i)
        if not node then return nil end
        local val = node.value
        node = node.prev
        return i - 1, val
    end

    return iter, node, self.size + 1
end

--- Retrieves the elements in raw table array form
--- @generic T : linkedlist.DoublyLinkedList, V, _
--- @param self T<V, _>
--- @return table<integer, V>
function DoublyLinkedList:toArray()
    local node, ret, size = self._front, {}, 0
    while node do
        size = size + 1
        ret[size] = node.value
        node = node.next
    end
    return ret
end

--- Retrieves the elements reversed, in raw table array form
--- @return any[]
function DoublyLinkedList:toReverseArray()
    local node, ret, size = self._back, {}, 0
    while node do
        size = size + 1
        ret[size] = node.value
        node = node.prev
    end
    return ret
end

return exports
