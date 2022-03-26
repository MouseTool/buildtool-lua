local ComponentController = require("ComponentController")

local exports = {}

-- ! Start component interface !



--- @class cookie-ui.IComponent : mousebase.EventEmitter
--- Controller for the component created by `controlFor()`. \
--- Available in all ops methods except in the constructor.
--- @field controller? cookie-ui.ComponentController
--- @field draw? fun() # Defines the layout and positioning of UI elements
--- @field render? fun() # Displays the actual UI artifact based on the drawn elements
--- @field destroy? fun()
--- @field unfocus? fun()
--- @field restore? fun()
local IComponent   = require("@mousetool/mousebase").EventEmitter:extend("IComponent")
exports.IComponent = IComponent

--- Creates a controller for a player and starts drawing the layout.
--- @param playerName string
--- @return cookie-ui.ComponentController
function IComponent:controlFor(playerName)
    if self.controller ~= nil then
        return
    end

    local controller = ComponentController:new(playerName, self)
    self.controller = controller
    controller:draw() -- draw once
    return controller
end

--- ! Start default component !

--- Implements a default component.
--- @class cookie-ui.DefaultComponent : cookie-ui.IComponent
local DefaultComponent = IComponent:extend("DefaultComponent")
exports.DefaultComponent = DefaultComponent

return exports
