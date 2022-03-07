--- Component for managing clickables with self-managed events.
--- @class Linkify : mousebase.EventEmitter
--- @field id integer
--- @field callbackLink string
--- @field cachedApiCb function[]
local Linkify = require("@mousetool/mousebase").EventEmitter:extend("Linkify")

local current_id = 0
local MAX_INT32 = 2147483647

function Linkify:_init()
    self.id = current_id
    current_id = current_id + 1
    if current_id > MAX_INT32 then current_id = 0 end

    self.callbackLink = "event:linkify@" .. self.id
end

function Linkify:on(eventName, listener, options)
    self._parent:on(eventName, listener, options)
end

--- Called when the reference to the link is destroyed.
function Linkify.close()

end

return Linkify
