local Reactive = require("init")

---@type Reactive<number, nil>
local store = Reactive:new(2)

do
    local t1 = store:get()
    store:subscribe(function (value, isInitial)
        t1 = value
    end)
end
