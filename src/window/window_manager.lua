local globals = require("bt-vars")
local api = globals.api
local WindowEnums = require("bt-enums").Window
local HelpWindow = require("HelpWindow")

local windows = {}
local CLASS_MAP = {
    [WindowEnums.HELP] = HelpWindow
}

local window_manager = {}

window_manager.open = function(window_id, pn)
    if not globals.players[pn] then
        print("Tried to open window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to open non-existent window type " .. window_id)
        return
    end
    windows[pn] = windows[pn] or {}
    local player_windows = windows[pn]
    player_windows[window_id] = player_windows[window_id] or {}
    local window_data = player_windows[window_id]
    if window_data.isOpen then return end
    
    local window = CLASS_MAP[window_id]:new(pn, window_data.state)
    window:once("created", function()
        window_data.window = window
        window_data.isOpen = true
    end)
    window:once("destroyed", function(state)
        window_data.state = state
        window_data.window = nil
        window_data.isOpen = nil
    end)
    window:create()
    return window
end

window_manager.close = function(window_id, pn)
    if not globals.players[pn] then
        print("Tried to close window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to close non-existent window type " .. window_id)
        return
    end
    if not windows[pn] then return end

    local window_data = windows[pn][window_id]
    if not window_data then return end
    if window_data.isOpen then
        window_data.window:destroy()
    end
end

window_manager.isOpen = function(window_id, pn)
    if not globals.players[pn] then
        print("Tried to open window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to open non-existent window type " .. window_id)
        return
    end
    windows[pn] = windows[pn] or {}
    local player_windows = windows[pn]
    player_windows[window_id] = player_windows[window_id] or {}
    local window_data = player_windows[window_id]
    return window_data.isOpen
end

window_manager.toggle = function(window_id, pn)
    if window_manager.isOpen(window_id, pn) then
        return window_manager.close(window_id, pn)
    end
    return window_manager.open(window_id, pn)
end

api.tfmEvent:on("PlayerLeft", function(pn)
    windows[pn] = nil
end)

return window_manager
