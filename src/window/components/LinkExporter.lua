local cookieUi          = require("@mousetool/cookie-ui")
local btIds             = require("modules.btIds")
local linkify           = require("modules.linkify")
local TextAreaComponent = cookieUi.TextAreaComponent

--- @alias LinkExporter.Events
---| '"click"'

--- LinkExporter is not an actual display component, but a utility to help you streamline the
--- listening of link clicks in other components.
---
--- Example usage:
--- ```lua
--- -- Create a new close link
--- local closeLink = LinkExporter:new()
---     :on("click", function()
---         self.controller:destroy()
---     end)
--- self.controller:addComponent(closeLink)
---
--- -- Use LinkExporter.href to get the link.
--- local text = "<a href='" .. closeLink.href  .. "'>click to close</a>"
--- ```
--- @class components.LinkExporter : cookie-ui.DefaultComponent
--- @field linkifyId util.linkify.idType
--- @field href string
---
--- @field on fun(self: components.LinkExporter, eventName: LinkExporter.Events, listener:fun()):components.LinkExporter
--- @field emit fun(self: components.LinkExporter, eventName: LinkExporter.Events)
local LinkExporter = cookieUi.DefaultComponent:extend("Linkify")

function LinkExporter:draw()
    self.linkifyId, self.href = linkify.newLink()
end

function LinkExporter:render()
    -- Start listening to events on render
    linkify.refLink(self.linkifyId, function(_textAreaID, playerName)
        -- Confirm correct player and not some hacker
        if self.controller.playerName ~= playerName then
            return
        end

        self:emit("click")
    end)
end

function LinkExporter:destroy()
    -- Destroy reference in listener
    linkify.unrefLink(self.linkifyId)
end

return LinkExporter
