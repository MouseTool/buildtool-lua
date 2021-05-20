--- BuildTool Room module
--- @class BtRoom
--- @field currentRound BtRound|nil
local bt_room = {}

local globals = require("bt-vars")
local ROLE = require("permissions.bt_perms").ROLE

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
    for name, btp in pairs(globals.players) do
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
    for _, btp in pairs(globals.players) do
        if not group or btp.capabilities:hasCaps(group) then
            btp:tlChatMsg(keyName, ...)
        end
    end
end

return bt_room
