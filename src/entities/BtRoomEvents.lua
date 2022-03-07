--- Emits BT-specific room events
--- @class BtRoomEvents:mousebase.EventEmitter
--- Emitted when a keyboard event is fired for a player
--- @field on fun(eventName:"'keyboard'", listener:fun(btp:BtPlayer, key:number, down:boolean))
local BtRoomEvents = require("@mousetool/mousebase").EventEmitter:extend("BtRoomEvents")

return BtRoomEvents
