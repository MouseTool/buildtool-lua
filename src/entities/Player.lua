--- BT player class.
--- @class Player:EventEmitter
--- @field public name string @The player's A801 name
--- @field public inRoom boolean @Whether the player is currently in the room
local Player = require("base.EventEmitter"):extend("Player")

local roomGet = tfm.get.room

--- @param name string The name of the player
--- @param inRoom boolean|nil Whether the player is in the room
Player._init = function(self, name, inRoom)
    Player._parent._init(self)

    self.name = name
    self.inRoom = inRoom or false
end

--- Retrieves the indexed playerList of the player.
--- @return TfmPlayer
Player.getTfmPlayer = function(self)
    return roomGet.playerList[self.name]
end

return Player
