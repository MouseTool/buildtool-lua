--- Emits text area callback events
--- @class BtTaEvents:EventEmitter
--- @field on fun(eventName:string, listener:fun(btp:BtPlayer, paramStr:string, textAreaId:integer))
--- @field emit fun(eventName:string, btp:BtPlayer, parameter:string, textAreaId:integer)
local BtTaEvents = require("@mousetool/mousebase").EventEmitter:extend("BtTaEvents")

return BtTaEvents
