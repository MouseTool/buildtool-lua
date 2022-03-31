--- Event emitter interface. Based off the [Node EventEmitter](https://nodejs.org/docs/latest-v16.x/api/events.html#class-eventemitter),
--- this interface includes a subset of features to implement.
--- @class IEventEmitter : Class
local IEventEmitter = require("@mousetool/class"):extend("IEventEmitter")

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function IEventEmitter:on(eventName, listener) end

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function IEventEmitter:once(eventName, listener) end

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function IEventEmitter:off(eventName, listener) end

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @return T
function IEventEmitter:removeAllListeners(eventName) end

--- @generic T : IEventEmitter
--- @param eventName string The name of the event
--- @return boolean # Returns `true` if the event had listeners, `false` otherwise.
function IEventEmitter:emit(eventName, ...) end

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function IEventEmitter:prependListener(eventName, listener) end

--- @generic T : IEventEmitter
--- @param self T
--- @param eventName string The name of the event
--- @param listener function The callback function
--- @return T
function IEventEmitter:prependOnceListener(eventName, listener) end

--- @param eventName string The name of the event
--- @return integer
function IEventEmitter:listenerCount(eventName) end

return IEventEmitter
