local Map = require("util.staging.map.init")

local exports = {}

--- Window on-focus behavior - describes the behavior when a window is in focus
--- @class cookie-ui.WindowOnFocusEnum
exports.WindowOnFocus = {
    --- Nothing.
    NONE = 0,
    --- Partially unfocus the top window.
    UNFOCUS_TOP = 1,
    --- Fullly unfocus all the other windows.
    --MINIMIZE_ALL = 2,
}

--- @alias cookie-ui.WindowRegistry.windowIdType integer | string

--- @class cookie-ui.WindowRegistry : Class
--- @field opened Map<cookie-ui.WindowRegistry.windowIdType, cookie-ui.ComponentWrapper>
local WindowRegistry = require("@mousetool/mousebase").Class:extend("WindowRegistry")
exports.WindowRegistry = WindowRegistry

function WindowRegistry:_init()
    self.opened = Map:new()
end

--- Opens a component wrapper as a window.
--- @param windowId cookie-ui.WindowRegistry.windowIdType
--- @param componentWrapper cookie-ui.ComponentWrapper
function WindowRegistry:open(windowId, componentWrapper)
    if self.opened:has(windowId) then
        print(("opening opened %s %s"):format(windowId, componentWrapper.playerName)) -- TODO: dbg
        return
    end

    componentWrapper:on("destroyed", function()
        print(("destroy id: %s, player %s"):format(windowId, componentWrapper.playerName))
        -- Remove ref to the wrapper unconditionally
        self.opened:delete(windowId)

        -- Restore the top if it isn't already focused.

        --- @type cookie-ui.ComponentWrapper|nil
        local top
        do
            for _, w in self.opened:reversePairs() do
                top = w
                break
            end
        end

        if top then
            top:restore()
        end
    end)

    componentWrapper:on("restored", function()
        -- Bring to front
        self.opened:delete(windowId)
        self.opened:set(windowId, componentWrapper)
    end)

    -- Unfocus old top

    --- @type cookie-ui.ComponentWrapper|nil
    local top
    do
        for _, w in self.opened:reversePairs() do
            top = w
            break
        end
    end

    if top then
        top:unfocus()
    end

    componentWrapper:render()
    self.opened:set(windowId, componentWrapper)
end

--- Closes a window.
--- @param windowId cookie-ui.WindowRegistry.windowIdType
function WindowRegistry:close(windowId)
    if not self.opened:has(windowId) then
        print(("closing closed %s %s"):format(windowId)) -- TODO: dbg
        return
    end

    local componentWrapper = self.opened:get(windowId)
    componentWrapper:destroy()
end

--- @param windowId cookie-ui.WindowRegistry.windowIdType
function WindowRegistry:isOpen(windowId)
    return self.opened:has(windowId) ~= nil
end

return exports
