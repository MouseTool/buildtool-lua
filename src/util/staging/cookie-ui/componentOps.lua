local ComponentWrapper = require("ComponentWrapper")

local exports = {}

-- ! Start component interface !

--- @alias cookie-ui.IComponent.Events
---| '"drawn"'
---| '"rendered"'
---| '"destroyed"'
---| '"unfocused"'
---| '"restored"'

--- @class cookie-ui.IComponent : mousebase.EventEmitter
--- Wrapper used to group multiple components. \
--- Available in all ops methods except in the constructor.
--- @field wrapper? cookie-ui.ComponentWrapper
--- @field state? '"drawn"' | '"rendered"' | '"unfocused"' | '"destroyed"'
--- @field draw? fun() # Defines the layout and positioning of UI elements
--- @field render? fun() # Displays the actual UI artifact based on the drawn elements
--- @field destroy? fun()
--- @field unfocus? fun()
--- @field restore? fun()
--- @field on fun(self: cookie-ui.IComponent, eventName: cookie-ui.IComponent.Events, listener:fun())
--- @field emit fun(self: cookie-ui.IComponent, eventName: cookie-ui.IComponent.Events)
local IComponent      = require("@mousetool/mousebase").EventEmitter:extend("IComponentOps")
exports.IComponentOps = IComponent

--- @param playerName string
function IComponent:wrapFor(playerName)
    if self.wrapper ~= nil then
        error("Cannot wrap component that was already wrapped - player " .. self.wrapper.playerName)
    end
    local wrapper = ComponentWrapper:new(playerName)
    wrapper:addComponent(self)

    return wrapper
end

--- ! Start default component !

--- Implements a default component.
--- @class cookie-ui.DefaultComponent : cookie-ui.IComponent
local DefaultComponent = IComponent:extend("DefaultComponent")
exports.DefaultComponent = DefaultComponent

return exports
