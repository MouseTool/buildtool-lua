--- `EventEmitterSet` is an implementation of `IEventEmitter` that is similar in functionality to
--- the default `EventEmitter`. It is recommended to be used if you remove listeners, prepend
--- listeners, or use `once()` very often.
---
--- The difference between this and the default implentation, being that its underlying listeners
--- collection utilises advanced data structures such as linked lists and maps to efficiently
--- find and remove listeners in O(1) time.
---
--- Because of this, `on()` will only allow the same listener object to be added once, unlike in
--- the default implementation.
--- @class EventEmitterSet
local EventEmitterSet

return EventEmitterSet
