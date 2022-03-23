local enums = {}

--- Window ID
--- @class WindowEnum
enums.Window = {
    HELP = 1,
    SETTINGS = 2,
    MOUSE_SPAWN = 3,
    GROUND_INFO = 4,
}

--- AS3 key codes
--- @class KeyEnum
enums.Keys = {
    SHIFT = 16,
    CTRL = 17,
    ESC = 27,
    SPACE = 32,
    G = 71,
    H = 72,
    M = 77,
    O = 79,
    U = 85,
}

--- Shaman object types
--- @class ShamObjEnum
enums.ShamObj = {
    Arrow      = 0,
    SmallBox   = 1,
    LargeBox   = 2,
    SmallPlank = 3,
    LargePlank = 4,
    Ball       = 6,
    Anvil      = 10,
    Cannon     = 17,
    Spirit     = 24,
    Portal     = 26,
    Balloon    = 28,
    Rune       = 32,
}

--- BT Map modes
--- @class MapModeEnum
enums.MapModeEnum = {
    UNKNOWN = 0,
    NORMAL = 1,
    LEISURE = 2,
    DIVINITY = 3,
    SPIRITUAL = 4
}

return enums
