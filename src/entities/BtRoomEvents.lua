--- Emits BT-specific room events
--- @class BtRoomEvents : EventEmitter
--- @field on fun(self, eventName:string, listener:function):BtRoomEvents
--- @field on fun(self, eventName:'"keyboard"', listener:fun(btp:BtPlayer, key:number, down:boolean)):BtRoomEvents # Emitted when a keyboard event is fired for a player
--- @field emit fun(self, eventName:'"keyboard"', btp:BtPlayer, key:number, down:boolean): boolean
local BtRoomEvents = require("@mousetool/event-emitter").EventEmitter:extend("BtRoomEvents")

return BtRoomEvents
