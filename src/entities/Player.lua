--- Player class.
--- @class Player:EventEmitter
local Player = require("base.EventEmitter"):extend("Player")

--- @function Player
--- @tparam string name The name of the player
--- @treturn Player The instance of the Class
Player._init = function(self, name)
    Player._parent._init(self)

    self.name = name
end

return Player
