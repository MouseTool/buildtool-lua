--- @alias cookie-ui.ComponentWrapper.Events
---| '"rendered"'
---| '"destroyed"'
---| '"unfocused"'
---| '"restored"'

--- A component wrapper is a group of components that go through a synchronised array of events
--- together, in insertion order of `ComponentWrapper.addComponent`.
--- All components in the wrapper end with the same state.
--- @class cookie-ui.ComponentWrapper : mousebase.EventEmitter
--- @field new fun(self:cookie-ui.ComponentWrapper, playerName:string):cookie-ui.ComponentWrapper
--- @field state '"inactive"' | '"rendering"' | "rendered"' | '"unfocused"' | '"destroyed"'
--- @field components cookie-ui.IComponent[]
--- @field playerName string
--- @field on fun(self: cookie-ui.ComponentWrapper, eventName: cookie-ui.ComponentWrapper.Events, listener:fun())
--- @field emit fun(self: cookie-ui.ComponentWrapper, eventName: cookie-ui.ComponentWrapper.Events)
local ComponentWrapper = require("@mousetool/mousebase").EventEmitter:extend("ComponentWrapper")

ComponentWrapper._init = function(self, playerName)
    ComponentWrapper._parent._init(self)

    self.playerName = playerName
    self.components = {}

    self.state = "inactive"
end

--- Adds a child component to the wrapper.
--- @param component cookie-ui.IComponent
function ComponentWrapper:addComponent(component)
    self.components[#self.components + 1] = component
    component.wrapper = self

    if component.prerender then
        component:prerender()
    end
    component.state = "prerendered"
    component:emit("prerendered")

    -- Late rendering
    if self.state == "rendering" then
        if component.render then
            component:render()
        end
        component.state = "rendered"
        component:emit("rendered")
    end
end

--- Renders the component group.
ComponentWrapper.render = function(self)
    self.state = "rendering"
    for i = 1, #self.components do
        local c = self.components[i]
        if c.render then
            c:render()
        end
        c.state = "rendered"
        c:emit("rendered")
    end
    self.state = "rendered"
    self:emit("rendered")
end

--- Destroys the component group.
ComponentWrapper.destroy = function(self)
    for i = 1, #self.components do
        local c = self.components[i]
        if c.destroy then
            c:destroy()
        end
        c.state = "destroyed"
        c:emit("destroyed")
    end
    self.state = "destroyed"
    self:emit("destroyed")
end

--- Unfocus the component group.
ComponentWrapper.unfocus = function(self)
    for i = 1, #self.components do
        local c = self.components[i]
        if c.unfocus then
            c:unfocus()
        end
        c.state = "unfocused"
        c:emit("unfocused")
    end
    self.state = "unfocused"
    self:emit("unfocused")
end

--- Restores the component group after it was unfocused.
ComponentWrapper.restore = function(self)
    if self.state == "rendered" then return end -- already focused
    for i = 1, #self.components do
        local c = self.components[i]
        if c.restore then
            c:restore()
        end
        c.state = "rendered"
        c:emit("restored")
    end
    self.state = "rendered"
    self:emit("restored")
end

return ComponentWrapper
