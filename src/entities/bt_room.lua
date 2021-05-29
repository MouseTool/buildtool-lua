--- BuildTool Room single instance module
--- @class BtRoom
--- @field currentRound BtRound|nil
local bt_room = {}

local localis = require("localisation.localis_manager")

--- Chat prefix
local C_PRE = "<V>[&#926;] <N>"

--- Sends a global chat message in the module context.
--- @param message string # The module message to display
--- @param playerName? string # The player who will get the message (if nil, applies to all players)
bt_room.moduleMsgDirect = function(message, playerName)
    tfm.exec.chatMessage(C_PRE .. message, playerName)
end

local directMsg = bt_room.moduleMsgDirect

--- Sends a module message to a capabilities group.
--- @param message string # The module message to display
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
bt_room.chatMsg = function(message, group)
    if group == nil then
        directMsg(message)
        return
    end
    for name, btp in pairs(bt_room.players) do
        if btp.capabilities:hasCaps(group) then
            directMsg(message, name)
        end
    end
end

--- Sends a translated module message to a capabilities group. If the `keyName` supplied is not found in the translations, the `keyName` will be displayed instead.
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
--- @param keyName string # The key name of the translation string
--- @vararg string # Translation string parameters
bt_room.tlChatMsg = function(group, keyName, ...)
    local evaluator = localis.evaluator:new(keyName, ...)
    for _, btp in pairs(bt_room.players) do
        if not group or btp.capabilities:hasCaps(group) then
            btp:tlbChatMsg(evaluator)
        end
    end
end

--- Sends a translated module message to a capabilities group. Similar to `tlChatMsg`, but accepts a localisation builder and caches the language string.
--- @see bt_room.tlChatMsg
--- @param builder LocalisBuilder
--- @param group? Capabilities # The players whom have the set group will get the message (if nil applies to all players)
bt_room.tlbChatMsg = function(builder, group)
    for _, btp in pairs(bt_room.players) do
        if not group or btp.capabilities:hasCaps(group) then
            btp:tlbChatMsg(builder)
        end
    end
end

--- [[Module vars]]

bt_room.api = require("@mousetool/mousebase").MbApi()

--- @type table<string, BtPlayer>
bt_room.players = {}

return bt_room
