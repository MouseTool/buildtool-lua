--- BuildTool specific player
--- @class BtPlayer:EventEmitter
--- @field new fun(self:BtPlayer, mbPlayer:MbPlayer, inRoom:boolean|nil):BtPlayer
--- @field name string @The player's A801 name
--- @field mbp MbPlayer @The MouseBase player object tied to the player
--- @field inRoom boolean @Whether the player is currently in the room
--- @field capabilities Capabilities @The player's capabiltiies
--- @field language string @The player's language
local BtPlayer = require("@mousetool/mousebase").EventEmitter:extend("BtPlayer")

local Capabilities = require("permissions.Capabilities")
local btPerms = require("permissions.bt_perms")
local BT_ROLE = btPerms.ROLE

local localis = require("LocalisManager")

--- @param mbPlayer MbPlayer The MouseBase player object tied to the player
--- @param inRoom boolean|nil Whether the player is in the room (default true)
BtPlayer._init = function(self, mbPlayer, inRoom)
    BtPlayer._parent._init(self)

    self.name = mbPlayer.name
    self.mbp = mbPlayer
    self.inRoom = inRoom or true
    self.capabilities = Capabilities:new()
    self.language = "en"

    self.capabilities:addCaps(BT_ROLE.OWNER)  -- tmp test
end

--- Displays a chat message to the player.
--- @param messsge string
BtPlayer.chatMsg = function(self, messsge)
    tfm.exec.chatMessage(messsge, self.name)
end

--- Sends a translated chat message to the player. If the `keyName` supplied is not found in the translations, the `keyName` will be displayed instead.
--- @param keyName string The key name of the translation string
--- @vararg string Translation string parameters
BtPlayer.tlChatMsg = function(self, keyName, ...)
    tfm.exec.chatMessage(localis.get(self.language, keyName):format(...), self.name)
end

return BtPlayer
