local Map = require "util.staging.map.init"

-- TODO: Watch LLS [#980](https://github.com/sumneko/lua-language-server/issues/980)
-- class Reactive<T> // actualVar: T
-- alias Reactive.SubscriberFn<T> fun(newValue: T, oldValue: T)

--- @alias Reactive.SubscriberFn fun(newValue: any, oldValue: any)

--- Reactive variable with update hooks.
---
--- @example Example usage:
--- ```lua
---
--- ```
--- @class Reactive : Class
--- @field value any
--- @field subscribers Map<Reactive.SubscriberFn, boolean>
--- @field new fun(self: Reactive, value: any)
local Reactive = require("@mousetool.class"):extend("Reactive")

function Reactive:_init(value)
    self.value = value
    self.subscribers = Map:new()
end

--- Gets the current value of the reactive.
--- @generic T : Reactive, V, _
--- @param self T<V, _>
--- @return V
function Reactive:get()
    return self.value
end

--- Subscribes a listener to reactive variable updates. Returns an unsubscriber function.
--- @generic T : Reactive, V, _
--- @param self T<V, _>
--- @param listener fun(value: V)
--- @return fun() unsubscribe
function Reactive:subscribe(listener)
    self.subscribers:set(listener, true)
    return function ()
        self.subscribers:delete(listener)
    end
end

--- Updates the value of the reactive. Informs all subscribers about the update.
--- @generic T : Reactive, V, _
--- @param self Reactive #T<V, _>
--- @param value V
function Reactive:update(value)
    local oldVal = self.value
    self.value = value
    -- Inform subscribers
    for s, _ in self.subscribers:pairs() do
        s(value, oldVal)
    end
end

return Reactive
