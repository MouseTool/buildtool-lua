--- BuildTool Room single instance module
--- @class BtRoom
--- @field currentRound BtRound|nil
local btRoom = {}

local BtRoomEvents = require("entities.BtRoomEvents")
local BtTaEvents = require("entities.BtTaEvents")
local localis = require("localisation.localis")

--- Chat prefix
local C_PRE = "<V>[&#926;] <N>"

--- Sends a global chat message in the module context.
--- @param message string # The module message to display
--- @param playerName? string # The player who will get the message (if nil, applies to all players)
btRoom.moduleMsgDirect = function(message, playerName)
    tfm.exec.chatMessage(C_PRE .. message, playerName)
end

local directMsg = btRoom.moduleMsgDirect

--- Sends a module message to a capabilities group.
--- @param message string # The module message to display
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
btRoom.chatMsg = function(message, group)
    if group == nil then
        directMsg(message)
        return
    end
    for name, btp in pairs(btRoom.players) do
        if btp.capabilities:hasCaps(group) then
            directMsg(message, name)
        end
    end
end

--- Sends a translated module message to a capabilities group. If the `keyName` supplied is not found in the translations, the `keyName` will be displayed instead.
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
--- @param keyName BtTranslationKeys # The key name of the translation string
--- @vararg string # Translation string parameters
btRoom.tlChatMsg = function(group, keyName, ...)
    local evaluator = localis.evaluator:new(keyName, ...)
    for _, btp in pairs(btRoom.players) do
        if not group or btp.capabilities:hasCaps(group) then
            btp:tlbChatMsg(evaluator)
        end
    end
end

--- Sends a translated module message to a capabilities group. Similar to `tlChatMsg`, but accepts a localisation builder and caches the language string.
--- @see btRoom.tlChatMsg
--- @param builder LocalisBuilder
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
btRoom.tlbChatMsg = function(builder, group)
    for _, btp in pairs(btRoom.players) do
        if not group or btp.capabilities:hasCaps(group) then
            btp:tlbChatMsg(builder)
        end
    end
end

--- [[Module vars]]

btRoom.api = require("@mousetool/mousebase").MbApi()

--- @type table<string, BtPlayer>
btRoom.players = {}

btRoom.events = BtRoomEvents:new()

btRoom.textAreaEvents = BtTaEvents:new()

return btRoom
