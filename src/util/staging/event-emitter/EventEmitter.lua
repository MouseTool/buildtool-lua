--- @class EventEmitter._TableWithSize : table
--- @field size integer

--- Event emitter implementation.
--- @class EventEmitter : IEventEmitter
--- @field _eventListeners table<string, EventEmitter._TableWithSize<integer, function>>
local EventEmitter = require("IEventEmitter"):extend("EventEmitter")

--- Creates a new event emitter.
function EventEmitter:_init()
    self._eventListeners = {}
end

--- Adds the listener function to the end of the listeners array for the event named eventName.
--- No checks are made to see if the listener has already been added.
--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitter:on(eventName, listener)
    local events = self._eventListeners
    if not events[eventName] then
        events[eventName] = { size = 0 }
    end

    local listeners = events[eventName]
    listeners.size = listeners.size + 1
    listeners[listeners.size] = listener
    return self
end

--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitter:once(eventName, listener)
    local onceListener
    onceListener = function(...)
        listener(...)
        self:off(eventName, onceListener)
    end
    return self:on(eventName, onceListener)
end

--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitter:off(eventName, listener)
    local listeners = self._eventListeners[eventName]
    if not listeners then return end

    local oldSize = listeners.size

    for i = 1, oldSize do
        if listeners[i] == listener then
            -- A shame we can't break here, but that's according to spec.
            --table.remove(listeners, i)

            -- Will be compacted later
            listeners[i] = nil
            listeners.size = listeners.size - 1
        end
    end

    if listeners.size <= 0 then
        self._eventListeners[eventName] = nil
    else
        -- Compact listeners list
        local found_spot = false
        local last_empty = nil
        for i = 1, oldSize do
            if not found_spot then
                if listeners[i] == nil then
                    last_empty = i
                    found_spot = true
                end
            elseif listeners[i] then
                listeners[last_empty] = listeners[i]
                listeners[i] = nil
                last_empty = last_empty + 1
            end
        end
    end
    return self
end

--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @return T
function EventEmitter:removeAllListeners(eventName)
    if not self._eventListeners[eventName] then return end
    self._eventListeners[eventName] = nil
    return self
end

--- Synchronously calls each of the listeners registered for the event named `eventName`, in the
--- order they were registered, passing the supplied arguments to each.
---
--- Errors thrown by listeners will be forwarded to the `error` event. If there are no listeners to
--- the `error` event, the exception will be carried forward per usual.
--- @generic T : EventEmitter
--- @param eventName string The name of the event
--- @return boolean # Returns `true` if the event had listeners, `false` otherwise.
function EventEmitter:emit(eventName, ...)
    local listeners = self._eventListeners[eventName]
    if not listeners then return end

    -- Do not allow any one of the listeners to break the loop by doing `off()` or `on()`
    --- @type function[]
    local toEmit = {}
    local cachedCount = listeners.size
    for i = 1, cachedCount do
        toEmit[i] = listeners[i]
    end

    for i = 1, cachedCount do
        local listener = toEmit[i]

        local status, err = pcall(listener, ...)
        if not status then
            if eventName ~= "error"
                and self:listenerCount("error") > 0 then
                self:emit("error", err)
            else
                error(err, 2)
            end
        end
    end
end

--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitter:prependListener(eventName, listener)
    local events = self._eventListeners
    if not events[eventName] then
        events[eventName] = { size = 0 }
    end

    local listeners = events[eventName]
    listeners.size = listeners.size + 1

    -- Insert front
    table.insert(listeners, 1, listener)
    return self
end

--- @generic T : EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitter:prependOnceListener(eventName, listener)
    local onceListener
    onceListener = function(...)
        listener(...)
        self:off(eventName, onceListener)
    end
    return self:prependListener(eventName, onceListener)
end

--- @param eventName string The name of the event
--- @return integer
function EventEmitter:listenerCount(eventName)
    local listeners = self._eventListeners[eventName]
    if not listeners then return 0 end
    return listeners.size
end

return EventEmitter
