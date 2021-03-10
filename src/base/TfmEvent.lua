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

local TfmEvents = require("EventEmitter"):extend("TfmEvents")

local hookedEvs = {}

TfmEvents.on = function(self, eventName, ...)
    if not hookedEvs[eventName] then
        _G["event" .. eventName] = function(...)
            self:emit(eventName, ...)
        end
    end
    hookedEvs[eventName] = true

    return TfmEvents._parent.on(self, eventName, ...)
end

TfmEvents.addListener = TfmEvents.on

TfmEvents.onCrucial = function(self, eventName, ...)
    if not hookedEvs[eventName] then
        _G["event" .. eventName] = function(...)
            self:emit(eventName, ...)
        end
    end
    hookedEvs[eventName] = true

    return TfmEvents._parent.onCrucial(self, eventName, ...)
end

TfmEvents.addCrucialListener = TfmEvents.onCrucial

return TfmEvents:new()
