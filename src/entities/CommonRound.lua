--- Represents a generic game round
--- @class CommonRound:mousebase.EventEmitter
--- @field new fun(mapCode:number, isMirrored?:boolean, author?:string, permCode?:string, xml?:string):CommonRound
--- @field mapCode number Map
--- @field isMirrored boolean
--- @field author string|nil # The map's author
--- @field permCode number|nil # The map's perm code
--- @field xml string|nil # The map's XML string
--- @field isActive boolean # Whether the round is currently being played
local CommonRound = require("@mousetool/mousebase").EventEmitter:extend("CommonRound")

--- @param mapCode number
--- @param isMirrored boolean
--- @param author? string
--- @param permCode? number
--- @param xml? string
CommonRound._init = function(self, mapCode, isMirrored, author, permCode, xml)
    CommonRound._parent._init(self)

    self.mapCode = mapCode
    self.isMirrored = isMirrored
    self.author = author
    self.permCode = permCode
    self.xml = xml
    self.isActive = false
end

--- Sets the round as active
CommonRound.activate = function(self)
    self.isActive = true
    self:emit('ready')
end

--- Sets the round as inactive
CommonRound.deactivate = function(self)
    self.isActive = false
    self:emit('ended')
end

return CommonRound
