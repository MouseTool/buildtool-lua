--- MouseBase player class.
--- @class mousebase.MbPlayer:mousebase.EventEmitter
--- @field public name string @The player's A801 name
--- @field public nameSid string @The player's stringified consistent name identifier
--- @field public isSouris boolean @Whether the player is a souris (guest)
local Player = require("EventEmitter"):extend("MbPlayer")

local nickname801 = require("@mousetool/nickname801")
local nickname801_isSouris = nickname801.isSouris
local nickname801_idName = nickname801.idName

local roomGet = tfm.get.room

--- @param name string The name of the player
Player._init = function(self, name)
    Player._parent._init(self)

    self.name = name
    self.nameSid = nickname801_idName(name)
    self.isSouris = nickname801_isSouris(name)
end

--- Retrieves the indexed playerList of the player.
--- @return tfm.Player
Player.getTfmPlayer = function(self)
    return roomGet.playerList[self.name]
end

--- Displays a chat message to the player.
--- @param messsge string
Player.chatMsg = function(self, messsge)
    tfm.exec.chatMessage(messsge, self.name)
end

return Player
