--- BT player class.
--- @class Player:EventEmitter
--- @field public name string @The player's A801 name
--- @field public nameId string @The player's A801 name, transformed as a consistent name identifier
--- @field public isSouris boolean @Whether the player is a souris (guest)
--- @field public inRoom boolean @Whether the player is currently in the room
--- @field public capabilities Capabilities @The player's capabiltiies
--- @field public language string @The player's language
local Player = require("base.EventEmitter"):extend("Player")

local nickname801 = require("utils.nickname801")
local nickname801_isSouris = nickname801.isSouris
local nickname801_idName = nickname801.idName

local Capabilities = require("permissions.Capabilities")
local btPerms = require("permissions.bt_perms")
local BT_ROLE = btPerms.ROLE

local localis = require("LocalisManager")

local roomGet = tfm.get.room

--- @param name string The name of the player
--- @param inRoom boolean|nil Whether the player is in the room
Player._init = function(self, name, inRoom)
    Player._parent._init(self)

    self.name = name
    self.nameId = nickname801_idName(name)
    self.isSouris = nickname801_isSouris(name)
    self.inRoom = inRoom or false
    self.capabilities = Capabilities:new()
    self.language = "en"

    self.capabilities:addCaps(BT_ROLE.OWNER)  -- tmp test
end

--- Retrieves the indexed playerList of the player.
--- @return TfmPlayer
Player.getTfmPlayer = function(self)
    return roomGet.playerList[self.name]
end

--- Displays a chat message to the player.
--- @param messsge string
Player.chatMsg = function(self, messsge)
    tfm.exec.chatMessage(messsge, self.name)
end

--- Sends a translated chat message to the player. If the `keyName` supplied is not found in the translations, the `keyName` will be displayed instead.
--- @param keyName string The key name of the translation string
--- @vararg string Translation string parameters
Player.tlChatMsg = function(self, keyName, ...)
    tfm.exec.chatMessage(localis.get(self.language, keyName):format(...), self.name)
end

return Player
