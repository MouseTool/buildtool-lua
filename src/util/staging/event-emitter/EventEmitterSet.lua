local Map = require("@mousetool/map")

--- `EventEmitterSet` is an implementation of `IEventEmitter` that is similar in functionality to
--- the default `EventEmitter`. `EventEmitterSet` will only allow unique listener objects per
--- `eventName`.
---
--- It is recommended to be used if you remove listeners, prepend listeners, or use
--- `once()` very often.
---
--- The difference between this and the default implentation, being that its underlying listeners
--- collection utilises advanced data structures such as linked lists and maps to efficiently
--- find and remove listeners in O(1) time.
---
--- Because of this, `on()` will only allow the same listener object to be added once, unlike in
--- the default implementation.
--- @class EventEmitterSet : IEventEmitter
--- @field _eventListeners table<string, Map<function, boolean>>
local EventEmitterSet = require("IEventEmitter"):extend("EventEmitterSet")

function EventEmitterSet:_init()
    self._eventListeners = {}
end

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitterSet:on(eventName, listener)
    local events = self._eventListeners
    if not events[eventName] then
        events[eventName] = Map:new()
    end

    local listeners = events[eventName]
    listeners:set(listener, true)

    return self
end

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitterSet:once(eventName, listener)
    local onceListener
    onceListener = function(...)
        listener(...)
        self:off(eventName, onceListener)
    end
    return self:on(eventName, onceListener)
end

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitterSet:off(eventName, listener)
    local listeners = self._eventListeners[eventName]
    if not listeners then return end

    listeners:delete(listener)
    return self
end

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @return T
function EventEmitterSet:removeAllListeners(eventName)
    if not self._eventListeners[eventName] then return end
    self._eventListeners[eventName] = nil
    return self
end

--- Synchronously calls each of the listeners registered for the event named `eventName`, in the
--- order they were registered, passing the supplied arguments to each.
---
--- Errors thrown by listeners will be forwarded to the `error` event. If there are no listeners to
--- the `error` event, the exception will be carried forward per usual.
--- @generic T : EventEmitterSet
--- @param eventName string The name of the event
--- @return boolean # Returns `true` if the event had listeners, `false` otherwise.
function EventEmitterSet:emit(eventName, ...)
    local listeners = self._eventListeners[eventName]
    if not listeners then return end

    -- Do not allow any one of the listeners to break the loop by doing `off()` or `on()`
    --- @type function[]
    local toEmit = {}
    local toEmitCount = 0

    for listener, _ in listeners:pairs() do
        toEmitCount = toEmitCount + 1
        toEmit[toEmitCount] = listener
    end

    for i = 1, toEmitCount do
        local status, err = pcall(toEmit[i], ...)
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

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitterSet:prependListener(eventName, listener)
    local events = self._eventListeners
    if not events[eventName] then
        events[eventName] = Map:new()
    end

    local listeners = events[eventName]
    -- Reverse set
    listeners:set(listener, true, true)

    return self
end

--- @generic T : EventEmitterSet
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function EventEmitterSet:prependOnceListener(eventName, listener)
    local onceListener
    onceListener = function(...)
        listener(...)
        self:off(eventName, onceListener)
    end
    return self:prependListener(eventName, onceListener)
end

--- @param eventName string The name of the event
--- @return integer
function EventEmitterSet:listenerCount(eventName)
    local listeners = self._eventListeners[eventName]
    if not listeners then return 0 end
    return listeners:size()
end

return EventEmitterSet
