--- @alias cookie-ui.ComponentController.Events
---| '"drawn"'
---| '"rendered"'
---| '"destroyed"'
---| '"unfocused"'
---| '"restored"'

--- @class cookie-ui.ComponentController : mousebase.EventEmitter
--- @field new fun(self:cookie-ui.ComponentController, playerName:string, component:cookie-ui.IComponent):cookie-ui.ComponentController
--- @field state? '"drawn"' | '"rendered"' | '"unfocused"' | '"destroyed"'
--- @field children cookie-ui.ComponentController[]
--- @field component cookie-ui.IComponent
--- @field playerName string
--- @field on fun(self: cookie-ui.ComponentController, eventName: cookie-ui.ComponentController.Events, listener: fun()): cookie-ui.ComponentController
--- @field emit fun(self: cookie-ui.ComponentController, eventName: cookie-ui.ComponentController.Events)
local ComponentController = require("@mousetool/mousebase").EventEmitter:extend("ComponentController")

ComponentController._init = function(self, playerName, component)
    ComponentController._parent._init(self)

    self.playerName = playerName
    self.component = component
    self.children = {}
end

--- Adds a child component to the controller. Automatically creates a controller for the child and returns it. \
--- A child component will listen to the same set of render/destroy events as its parent component,
--- in order of addition.
--- @param component cookie-ui.IComponent
--- @return cookie-ui.ComponentController # The child component's controller.
function ComponentController:addComponent(component)
    if self.state ~= nil then
        error("Can only call addComponent while drawing.")
    end

    local controller = component:controlFor(self.playerName)
    self.children[#self.children + 1] = controller
    return controller
end

--- Draws the component layout. Also better known as the pre-rendering stage.
function ComponentController:draw()
    if self.state ~= nil then
        error("Cannot call draw after already drawn.")
    end
    if self.component.draw then
        self.component:draw()
    end
    self.state = "drawn"
    self:emit("drawn")
end

--- Renders the component group.
function ComponentController:render()
    if self.component.render then
        self.component:render()
    end
    for i = 1, #self.children do
        local c = self.children[i]
        c:render()
    end
    self.state = "rendered"
    self:emit("rendered")
end

--- Destroys the component group.
function ComponentController:destroy()
    if self.component.destroy then
        self.component:destroy()
    end
    for i = 1, #self.children do
        local c = self.children[i]
        -- Don't double destroy
        if c.state ~= "destroyed" then
            c:destroy()
        end
    end
    self.state = "destroyed"
    self:emit("destroyed")
end

--- Unfocus the component group.
function ComponentController:unfocus()
    if self.component.unfocus then
        self.component:unfocus()
    end
    for i = 1, #self.children do
        local c = self.children[i]
        c:unfocus()
    end
    self.state = "unfocused"
    self:emit("unfocused")
end

--- Restores the component group after it was unfocused.
function ComponentController:restore()
    if self.state == "rendered" then return end -- already focused
    if self.component.restore then
        self.component:restore()
    end
    for i = 1, #self.children do
        local c = self.children[i]
        if c.restore then
            c:restore()
        end
    end
    self.state = "rendered"
    self:emit("restored")
end

return ComponentController
