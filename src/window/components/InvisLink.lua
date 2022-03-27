local cookieUi          = require("util.staging.cookie-ui.init")
local btIds             = require("modules.btIds")
local linkify           = require("modules.linkify")
local TextAreaComponent = cookieUi.TextAreaComponent

--- @alias InvisLink.Events
---| '"click"'

--- Creates an invisible clickable text area of specified dimensions.
--- @class components.InvisLink : cookie-ui.DefaultComponent
--- @field linkifyId util.linkify.idType
--- @field href string
---
--- @field new fun(self: components.InvisLink, x: number, y: number, height: number, width: number, isFixed?: boolean, isDebug?: boolean)
--- @field on fun(self: components.InvisLink, eventName: InvisLink.Events, listener:fun()):components.InvisLink
--- @field emit fun(self: components.InvisLink, eventName: InvisLink.Events)
local Linkify = cookieUi.DefaultComponent:extend("Linkify")

---@param x number
---@param y number
---@param height number
---@param width number
---@param isFixed? boolean
---@param isDebug? boolean
function Linkify:_init(x, y, height, width, isFixed, isDebug)
    self._parent._init(self)

    self.x = x
    self.y = y
    self.height = height
    self.width = width
    self.isFixed = isFixed
    self.isDebug = isDebug
end

function Linkify:draw()
    self.linkifyId, self.href = linkify.newLink()

    -- Thx bolo!
    local component = TextAreaComponent:new(
        btIds.getNewTextAreaId(),
        "<textformat leftmargin='1' rightmargin='1'><a href='event:linkify@"
        .. self.href .. "'>" .. string.rep('\n', self.height / 10),
        self.x - 5, self.y - 5, self.width + 5, self.height + 5, 1, 1, 0,
        self.isFixed
    )

    if self.isDebug then
        component = TextAreaComponent:new(
            btIds.getNewTextAreaId(),
            "<textformat leftmargin='1' rightmargin='1'><a href='"
            .. self.href .. "'>InvisLink@" .. self.linkifyId .. string.rep('\n', self.height / 10),
            self.x - 5, self.y - 5, self.width + 5, self.height + 5, 1, 1, 0.7,
            self.isFixed
        )
    end

    self.controller:addComponent(component)
end

function Linkify:render()
    -- Start listening to events on render
    linkify.refLink(self.linkifyId, function(_textAreaID, playerName)
        -- Confirm correct player and not some hacker
        if self.controller.playerName ~= playerName then
            return
        end

        self:emit("click")
    end)
end

function Linkify:destroy()
    -- Destroy reference in listener
    linkify.unrefLink(self.linkifyId)
end

return Linkify
