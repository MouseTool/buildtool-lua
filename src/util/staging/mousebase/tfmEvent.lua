--- @module "meta.eventEnum"

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
--- original name of events used in TFM API, except without the "event" keyword
--- in front.
--- @class mousebase.TfmEvent : EventEmitterSet
--- @field on fun(self:mousebase.TfmEvent, eventName:mousebase.TfmEvents.Events, listener:function)):mousebase.TfmEvents
--- @field on fun(self:mousebase.TfmEvent, eventName:'"ChatCommand"', listeners:fun(playerName:string, command:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"ChatMessage"', listeners:fun(playerName:string, message:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"EmotePlayed"', listeners:fun(playerName:string, emoteType:integer, emoteParam:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"FileLoaded"', listeners:fun(fileNumber:string, fileData:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"FileSaved"', listeners:fun(fileNumber:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"Keyboard"', listeners:fun(playerName:string, keyCode:integer, down:boolean, xPlayerPosition:integer, yPlayerPosition:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"Mouse"', listeners:fun(playerName:string, xMousePosition:integer, yMousePosition:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"Loop"', listeners:fun(elapsedTime:integer, remainingTime:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"NewGame"', listeners:fun()):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"NewPlayer"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerDataLoaded"', listeners:fun(playerName:string, playerData:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerDied"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerGetCheese"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerBonusGrabbed"', listeners:fun(playerName:string, bonusId:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerLeft"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerVampire"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerWon"', listeners:fun(playerName:string, timeElapsed:integer, timeElapsedSinceRespawn:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerRespawn"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PlayerMeep"', listeners:fun(playerName:string, xPosition:integer, yPosition:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"PopupAnswer"', listeners:fun(popupId:integer, playerName:string, answer:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"SummoningStart"', listeners:fun(playerName:string, objectType:integer, xPosition:integer, yPosition:integer, angle:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"SummoningCancel"', listeners:fun(playerName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"SummoningEnd"', listeners:fun(playerName:string, objectType:integer, xPosition:integer, yPosition:integer, angle:integer, objectDescription:tfm.ShamanObject)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"TextAreaCallback"', listeners:fun(textAreaId:integer, playerName:string, eventName:string)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"ColorPicked"', listeners:fun(colorPickerId:integer, playerName:string, color:integer)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"ContactListener"', listeners:fun(playerName:string, groundId:integer, contactInfos:tfm.ContactDef)):mousebase.TfmEvent
--- @field on fun(self:mousebase.TfmEvent, eventName:'"TalkToNPC"', listeners:fun(playerName:string, npcName:string)):mousebase.TfmEvent
local TfmEvents = require("@mousetool/event-emitter").EventEmitterSet:extend("TfmEvents")

local hookedEvs = {}

local hookEvent = function(self, eventName)
    if not hookedEvs[eventName] then
        _G["event" .. eventName] = function(...)
            self:emit(eventName, ...)
        end
    end
    hookedEvs[eventName] = true
end

--- @param eventName mousebase.TfmEvents.Events
--- @param listener function
function TfmEvents:on(eventName, listener)
    hookEvent(self, eventName)
    return TfmEvents._parent.on(self, eventName, listener)
end

TfmEvents.reserve = hookEvent

-- Singleton
return TfmEvents:new()
