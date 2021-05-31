local enums = {}

--- Window ID
--- @class WindowEnum
enums.Window = {
    HELP = 1,
    SETTINGS = 2,
    MOUSE_SPAWN = 3,
    GROUND_INFO = 4,
}

--- Window overlay behavior - describes what the window should do when a
--- new window is layered over
--- @class WindowOverlayEnum
enums.WindowOverlay = {
    -- Mutually exclusive. Destroy the window.
    MUTUALLY_EXCLUSIVE = 0,
    -- Unfocus.
    UNFOCUS = 1,
}

--- AS3 key codes
enums.Keys = {
    SHIFT = 16,
    CTRL = 17,
    SPACE = 32,
    G = 71,
    H = 72,
    M = 77,
    O = 79,
    U = 85,
}

return enums
