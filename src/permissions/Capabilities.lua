--- Capabilities library: for roles and permissions managing.
---
--- Due to the implementation of the underlying bit32 library, only up to 32 flags
--- (or "capabilities") are supported by `getFlag(position)`, ranging from 0 to 31.
---
--- Example usage:
--- ```lua
--- local CAP_ADMIN = Capabilities.getFlag(0)
--- local CAP_ROOT = Capabilities.getFlag(1)
---
--- local ROOT_USER = Capabilities:new(CAP_ADMIN, CAP_ROOT) 
--- ```
--- @class Capabilities:Class
--- @field new fun(self:Capabilities, ...):Capabilities
--- @field private flag integer
local Capabilities = require("@mousetool/mousebase").Class:extend("Capabilities")

local bit    = bit32
local band   = bit.band
local bnot   = bit.bnot
local bor    = bit.bor
local lshift = bit.lshift
local MAX_POSITION_SIZE = 32  -- Maximum size supported by bit32 library

local bits = {}
for i = 0, MAX_POSITION_SIZE - 1 do
    bits[i] = lshift(1, i)
end

--- Adds supplied flags to the capabilities.
--- @vararg integer
Capabilities._init = function(self, ...)
    self.flag = 0
    local args, sz = {...}, select('#', ...)
    for i = 1, sz do
        self.flag = bor(self.flag, args[i])
    end
end

--- Adds supplied flags to the capabilities.
--- @vararg integer
--- @return Capabilities
Capabilities.add = function(self, ...)
    local args, sz = {...}, select('#', ...)
    for i = 1, sz do
        self.flag = bor(self.flag, args[i])
    end
    return self
end

--- Removes supplied flags from within.
--- @vararg integer
--- @return Capabilities
Capabilities.remove = function(self, ...)
    local args, sz = {...}, select('#', ...)
    for i = 1, sz do
        self.flag = band(self.flag, bnot(args[i]))
    end
    return self
end

--- Sets the integer representation of the flag.
--- @param flag integer
--- @return Capabilities
Capabilities.setFlag = function(self, flag)
    self.flag = flag
    return self
end

--- Gets the integer representation of the flags within.
--- @return integer
Capabilities.toFlag = function(self)
    return self.flag
end

--- Checks if the supplied capabilities has the same flags.
--- @param caps Capabilities
--- @return boolean
Capabilities.equals = function(self, caps)
    return self.flag == caps.flag
end

--- Checks if the supplied capabilities has its flags contained within (subset).
--- @param caps Capabilities
--- @return boolean
Capabilities.hasCaps = function(self, caps)
    return band(bnot(self.flag), caps.flag) == 0
end

--- Checks if a single flag is contained within (subset).
--- @param flag integer
--- @return boolean
Capabilities.hasFlag = function(self, flag)
    return band(self.flag, flag) ~= 0
end

--- Gets the flag based on the supplied position and mapped bits.
--- @param position integer position from 0 to 31
--- @return integer
Capabilities.getFlag = function(position)
    if position < 0 or position >= MAX_POSITION_SIZE then
        error(("Position is out of bounds (supported range is 0 to %s"):format(MAX_POSITION_SIZE - 1))
    end
    return bits[position]
end

--- Adds flags from the supplied capabilities.
--- Equivalent to: ``thisCaps:add(otherCaps:toFlag()) ``
--- @param caps Capabilities
--- @return Capabilities
Capabilities.addCaps = function(self, caps)
    self.flag = bor(self.flag, caps.flag)
    return self
end

--- Exports (or copies) over the capabilities within to a new instance.
--- Adds supplied flags to the new capabilities.
--- Equivalent to: ``Capabilities:new(oldCaps:toFlag(), ...) ``
--- 
--- @vararg integer
--- @return Capabilities @The new capabilities instance
Capabilities.export = function(self, ...)
    return Capabilities:new(self.flag, ...)
end

return Capabilities
