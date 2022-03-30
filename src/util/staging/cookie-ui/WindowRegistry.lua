local Map = require("@mousetool/map")

--- @alias cookie-ui.WindowRegistry.WindowIdType integer | string

--- @param opened Map<cookie-ui.WindowRegistry.WindowIdType, cookie-ui.ComponentController>
--- @return cookie-ui.WindowRegistry.WindowIdType?
--- @return cookie-ui.ComponentController?
local function _getTopLayer(opened)
    local type
    local component
    do
        for id, w in opened:reversePairs() do
            type = id
            component = w
            break
        end
    end
    return type, component
end


--- @class cookie-ui.WindowRegistry : Class
--- @field opened Map<cookie-ui.WindowRegistry.WindowIdType, cookie-ui.ComponentController>
local WindowRegistry = require("@mousetool/mousebase").Class:extend("WindowRegistry")

function WindowRegistry:_init()
    self.opened = Map:new()
end

--- Opens a component wrapper as a window.
--- @param windowId cookie-ui.WindowRegistry.WindowIdType
--- @param controller cookie-ui.ComponentController
function WindowRegistry:open(windowId, controller)
    if self.opened:has(windowId) then
        print(("opening opened %s %s"):format(windowId, controller.playerName)) -- TODO: dbg
        return
    end

    controller:on("destroyed", function()
        print(("destroy id: %s, player %s"):format(windowId, controller.playerName)) -- TODO: dbg
        -- Remove ref to the wrapper unconditionally
        self.opened:delete(windowId)

        -- Restore the top if it isn't already focused.
        local _, top = _getTopLayer(self.opened)

        if top then
            top:restore()
        end
    end)

    controller:on("restored", function()
        -- Bring to front
        self.opened:delete(windowId)
        self.opened:set(windowId, controller)
    end)

    -- Unfocus old top
    local _, top = _getTopLayer(self.opened)

    if top then
        top:unfocus()
    end

    controller:render()
    self.opened:set(windowId, controller)
end

--- Closes a window.
--- @param windowId? cookie-ui.WindowRegistry.WindowIdType
function WindowRegistry:close(windowId)
    if not self.opened:has(windowId) then
        print(("closing closed %s"):format(windowId or "-")) -- TODO: dbg
        return
    end

    local componentWrapper = self.opened:get(windowId)
    componentWrapper:destroy()
end

--- @param windowId cookie-ui.WindowRegistry.WindowIdType
function WindowRegistry:isOpen(windowId)
    return self.opened:has(windowId)
end

--- Gets the focused window type on the highest layer, if any. \
--- Useful for cases like implementing an escape key shortcut to close a window.
--- @return cookie-ui.WindowRegistry.WindowIdType?
function WindowRegistry:focusedWindow()
    local type = _getTopLayer(self.opened)
    return type
end

return WindowRegistry
