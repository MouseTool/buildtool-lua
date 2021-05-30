--- Manager for UI windows.
--- Due to how text areas and images are positioned in TFM, it is neccessary to
--- ensure that windows render properly over one another when multiple layers
--- of elements coexist. This window manager serves to handle them.
local window_manager = {}

local btRoom = require("entities.bt_room")
local api = btRoom.api
local OrderedTable = require("@mousetool/ordered-table")
local WindowEnums = require("bt-enums").Window
local WindowOverlayEnums = require("bt-enums").WindowOverlay

local HelpWindow = require("HelpWindow")
local SettingsWindow = require("SettingsWindow")
local MouseSpawnWindow = require("MouseSpawnWindow")

--- @class WindowData
--- @field window Window
--- @field isOpen boolean
--- @field state table

--- @class PlayerWindows
--- @field all table<WindowEnum, WindowData> @Stores all windows opened and closed (with persistent data)
--- @field opened OrderedTable<WindowEnum, WindowData> @Stores an ordered table of windows (by Z index) rendered

--- @type table<string, PlayerWindows>
local windows = {}

--- @type table<WindowEnum, Window>
local CLASS_MAP = {
    [WindowEnums.HELP] = HelpWindow,
    [WindowEnums.SETTINGS] = SettingsWindow,
    [WindowEnums.MOUSE_SPAWN] = MouseSpawnWindow,
}

--- Called when a new window is going to be in ultimate focus, and the old top window (if any) has to be unfocused.
--- @param pn string
local function unfocusTop(pn)
    -- TODO: change to getTopWIndow
    if not windows[pn] or not windows[pn].opened then
        return
    end
    local top_window
    for _, wd in OrderedTable.revpairs(windows[pn].opened) do
        top_window = wd.window
        break
    end

    if top_window then
        top_window:unfocus()
    end
end

--- Opens the window associated with the type and player.
--- @param window_id WindowEnum Window type
--- @param pn string Player name
--- @return Window
window_manager.open = function(window_id, pn)
    if not btRoom.players[pn] then
        print("Tried to open window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to open non-existent window type " .. window_id)
        return
    end

    windows[pn] = windows[pn] or {all = {}, opened = OrderedTable:new()}
    local player_windows = windows[pn].all
    player_windows[window_id] = player_windows[window_id] or {}

    local window_data = player_windows[window_id]
    if window_data.isOpen then return end
    
    local window = CLASS_MAP[window_id]:new(pn, window_data.state)
    window:once("rendered", function()
        window_data.window = window
        window_data.isOpen = true
        windows[pn].opened[window_id] = window_data  -- reference back to window data
    end)
    window:on("refocused", function()
        -- Bring to front
        windows[pn].opened[window_id] = nil
        windows[pn].opened[window_id] = window_data
    end)
    window:once("destroyed", function(state)
        -- If this window is currently the top one, focus the next top if any
        do
            local top_window, new_top_window
            for _, wd in OrderedTable.revpairs(windows[pn].opened) do
                if not top_window then
                    top_window = wd.window
                else
                    new_top_window = wd.window
                    break
                end
            end

            if top_window == window and new_top_window then
                new_top_window:focus()
            end
        end

        window_data.state = state
        window_data.window = nil
        window_data.isOpen = nil
        windows[pn].opened[window_id] = nil
    end)
    unfocusTop(pn)
    window:render()
    return window
end

--- Closes the window associated with the type and player.
--- @param window_id WindowEnum Window type
--- @param pn string Player name
window_manager.close = function(window_id, pn)
    if not btRoom.players[pn] then
        print("Tried to close window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to close non-existent window type " .. window_id)
        return
    end
    if not windows[pn] then return end

    local window_data = windows[pn].opened[window_id]
    if not window_data then return end
    window_data.window:destroy()
end

--- Checks if the window associated with the type and player is opened.
--- @param window_id WindowEnum Window type
--- @param pn string Player name
--- @return boolean
window_manager.isOpen = function(window_id, pn)
    if not btRoom.players[pn] then
        print("Tried to check window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to check non-existent window type " .. window_id)
        return
    end
    if not windows[pn] then return end

    local window_data = windows[pn].opened[window_id]
    return window_data ~= nil
end

--- Refocuses an unfocused window associated with the type and player into view
--- @param window_id WindowEnum Window type
--- @param pn string Player name
window_manager.refocus = function(window_id, pn)
    if not btRoom.players[pn] then
        print("Tried to close window ID " .. window_id .." but player not registered:" .. pn)
        return
    end
    if not CLASS_MAP[window_id] then
        print("Tried to close non-existent window type " .. window_id)
        return
    end
    if not windows[pn] then return end

    local window_data = windows[pn].opened[window_id]
    if not window_data then return end

    local window = window_data.window
    if window.focused then return end  -- already focused

    unfocusTop(pn)
    window:refocus()
end

--- Convenience method to toggle open or close a window.
--- @param window_id WindowEnum Window type
--- @param pn string Player name
--- @return Window?
window_manager.toggle = function(window_id, pn)
    if window_manager.isOpen(window_id, pn) then
        return window_manager.close(window_id, pn)
    end
    return window_manager.open(window_id, pn)
end

--- Gets the opened `Window` associated with the type and player.
--- @param window_id WindowEnum Window type
--- @param pn string Player name
--- @return Window? The window, null if no such window is opened
window_manager.getWindow = function(window_id, pn)
    if not btRoom.players[pn] then
        print("Tried to get window ID " .. window_id .." but player not registered:" .. pn)
        return nil
    end
    if not CLASS_MAP[window_id] then
        print("Tried to get non-existent window type " .. window_id)
        return nil
    end
    if not windows[pn] then return nil end

    local window_data = windows[pn].opened[window_id]
    if not window_data then return nil end
    return window_data.window
end

api.tfmEvent:on("PlayerLeft", function(pn)
    windows[pn] = nil
end)

return window_manager
