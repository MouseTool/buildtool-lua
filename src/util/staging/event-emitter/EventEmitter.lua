

--- Event emitter implementation.
--- @class EventEmitter : IEventEmitter
--- @field protected _crucialListeners table
--- @field protected _listeners table
local EventEmitter = require("IEventEmitter"):extend("EventEmitter")

local onFunc = function(events, eventName, listener, options)
    if not events[eventName] then
        events[eventName] = { _sz = 0 }
        events._sz = events._sz + 1
    end

    local event = events[eventName]
    event._sz = event._sz + 1
    event[event._sz] = { listener, options }
end

local emitFunc = function(listeners, eventName, ...)
    if not listeners then return end

    local listenersIndexToRemove = { _sz = 0 }

    for i = 1, listeners._sz do
        local listener, options = listeners[i][1], listeners[i][2]
        xpcall(listener, function(err)
            print("Runtime Error : Event " .. eventName .. ": ".. tostring(err) .. "\n" .. debug.traceback(nil, 2))
        end, ...)
        if options and options.once then
            listeners[i] = nil
        end
    end

    -- Compact listeners list
    do
        local found_spot = false
        local last_empty = nil
        for i = 1, listeners._sz do
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
        if last_empty then
            listeners._sz = last_empty - 1
        end
    end
end

--- Creates a new event emitter.
--- @return mousebase.EventEmitter @The instance of the EventEmitter
EventEmitter._init = function(self)
    self._listeners = { _sz = 0 }
    self._crucialListeners = { _sz = 0 }
end

--- Adds the listener function to the end of the listeners array for the event named eventName.
--- No checks are made to see if the listener has already been added.
--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @param options table
--- @return T
EventEmitter.on = function(self, eventName, listener, options)
    onFunc(self._listeners, eventName, listener, options)
    return self
end

EventEmitter.addListener = EventEmitter.on

--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @param options table
--- @return T
EventEmitter.once = function(self, eventName, listener, options)
    options = options or {}
    options.once = true
    return self:on(eventName, listener, options)
end

--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
EventEmitter.off = function(self, eventName, listener)
    local listeners = self._listeners[eventName]
    if not listeners then return end

    for i = 1, listeners._sz do
        if listeners[i][1] == listener then
            table.remove(listeners, i)
            listeners._sz = listeners._sz - 1
            break
        end
    end

    if listeners._sz <= 0 then
        self._listeners[eventName] = nil
    end

    return self
end

EventEmitter.removeListener = EventEmitter.off

--- @generic T : mousebase.EventEmitter
--- @param eventName string The name of the event
EventEmitter.emit = function(self, eventName, ...)
    -- Emit crucial events first
    emitFunc(self._crucialListeners[eventName], eventName, ...)
    emitFunc(self._listeners[eventName], eventName, ...)
end

--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @param options table
--- @return T
EventEmitter.onCrucial = function(self, eventName, listener, options)
    onFunc(self._crucialListeners, eventName, listener, options)
    return self
end

EventEmitter.addCrucialListener = EventEmitter.onCrucial

--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @param options table
--- @return T
EventEmitter.onceCrucial = function(self, eventName, listener, options)
    options = options or {}
    options.once = true
    return self:onCrucial(eventName, listener, options)
end

--- @generic T : mousebase.EventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
EventEmitter.offCrucial = function(self, eventName, listener)
    local listeners = self._crucialListeners[eventName]
    if not listeners then return end

    for i = 1, listeners._sz do
        if listeners[i][1] == listener then
            table.remove(listeners, i)
            listeners._sz = listeners._sz - 1
            break
        end
    end

    if listeners._sz <= 0 then
        self._crucialListeners[eventName] = nil
    end

    return self
end

EventEmitter.removeCrucialListener = EventEmitter.offCrucial

return EventEmitter
