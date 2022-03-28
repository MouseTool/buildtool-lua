-- EventEmitter extension to interact directly with Transformice events.
-- The eventName used in the methods on() and emit() are equivalent to the
-- original name of events used in TFM API, except
--   a. without the "event" keyword in front.
--
-- As an example, the TFM event "eventPlayerBonusGrabbed" is translated to
-- "PlayerBonusGrabbed" in here.
-- Therefore,
-- **Old**
-- ```
-- function eventPlayerBonusGrabbed(playerName, bonusId)
--   doSomething1()
--   doSomething2()
-- end
-- ```
-- **New**
-- ```
-- local TfmEvent = myApi.tfmEvent
-- TfmEvent:on("PlayerBonusGrabbed", function(playerName, bonusId)
--   doSomething1()
-- end)
-- TfmEvent:on("PlayerBonusGrabbed", function(playerName, bonusId)
--   doSomething2()
-- end)
-- ```
--
-- If you use the TfmEvent emitter to manage events, you **must not** override
-- the definition of the equivalent TFM event callback or it will fail to
-- function.
-- For example, this is **wrong**:
-- ```
-- TfmEvent:on("PlayerBonusGrabbed", function() ... end)
-- -- Do NOT do this.
-- function eventPlayerBonusGrabbed() ... end
-- ```
--
-- As TFM events at runtime are cached, registering new events after init (during
-- runtime) is **not possible**. Therefore if you must register an event at
-- runtime, do "hook" or reserve it during init time. Example in main file:
-- ```
-- TfmEvent:reserve("Loop")  -- Reserve at init: this is neccessary!
-- TfmEvent:on("PlayerLeft", function(pn)
--   -- Registering new event at runtime - only works if there were
--   -- other "Loop" events registered at init, or reserved at init.
--   TfmEvent:on("Loop", function() print("looping") end)
-- end)

--- EventEmitter extension to interact directly with Transformice events.
--- The eventName used in the methods on() and emit() are equivalent to the
--- original name of events used in TFM API, except
---   a. without the "event" keyword in front.
--- @class mousebase.MbTfmEvent:mousebase.EventEmitter
local MbTfmEvent = require("EventEmitter"):extend("MbTfmEvent")

local hookedEvs = {}

local hookEvent = function(self, eventName)
    if not hookedEvs[eventName] then
        _G["event" .. eventName] = function(...)
            self:emit(eventName, ...)
        end
    end
    hookedEvs[eventName] = true
end

MbTfmEvent.on = function(self, eventName, ...)
    hookEvent(self, eventName)
    return MbTfmEvent._parent.on(self, eventName, ...)
end

MbTfmEvent.addListener = MbTfmEvent.on

MbTfmEvent.onCrucial = function(self, eventName, ...)
    hookEvent(self, eventName)
    return MbTfmEvent._parent.onCrucial(self, eventName, ...)
end

MbTfmEvent.addCrucialListener = MbTfmEvent.onCrucial

MbTfmEvent.reserve = hookEvent

return MbTfmEvent:new()
