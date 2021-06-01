local enums = {}

--- Window ID
--- @class WindowEnum
enums.Window = {
    HELP = 1,
    SETTINGS = 2,
    MOUSE_SPAWN = 3,
    GROUND_INFO = 4,
}

--- Window unfocus behavior - describes what the window should do when a
--- new window is layered over
--- @class WindowUnfocusEnum
enums.WindowUnfocus = {
    --- Nothing.
    NONE = 0,
    --- Simple partial unfocus.
    UNFOCUS = 1,
    --- Full unfocus.
    MINIMIZE = 2,
}

--- Window on-focus behavior - describes the behavior when a window is in focus
--- @class WindowOnFocusEnum
enums.WindowOnFocus = {
    --- Nothing.
    NONE = 0,
    --- Partially unfocus the top window.
    UNFOCUS_TOP = 1,
    --- Fullly unfocus all the other windows.
    --MINIMIZE_ALL = 2,
}

--- AS3 key codes
--- @class KeyEnum
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
