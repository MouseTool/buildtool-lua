local OrderedTable = require("@mousetool/ordered-table")
local ComponentWrapper = require("ComponentWrapper")
--local ComponentWrapper = require("ComponentWrapper")
--- @module "ComponentWrapper"

local exports = {}

-- ! Start component interface !

--- @alias cookie-ui.IComponent.Events
---| '"prerendered"'
---| '"rendered"'
---| '"destroyed"'
---| '"unfocused"'
---| '"restored"'

--- @class cookie-ui.IComponent : mousebase.EventEmitter
--- Wrapper used to attach text areas and images. \
--- Available in all ops methods except in the constructor.
--- @field wrapper? cookie-ui.ComponentWrapper
--- @field state? '"prerendered"' | '"rendered"' | '"unfocused"' | '"destroyed"'
--- @field prerender? fun()
--- @field render? fun()
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
