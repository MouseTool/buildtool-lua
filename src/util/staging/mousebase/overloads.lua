--- Patched globals for Transformice LuaJ
local overloads = {}

local raw_xpcall = xpcall

--- Calls function `f` with the given arguments in protected mode with a new message handler.
--- @param f function
--- @param msgh function
--- @return boolean success
--- @return any result
--- @return ...
overloads.xpcall = function(f, msgh, ...)
    local args, nargs = {...}, select("#", ...)
    return raw_xpcall(function()
        return f(table.unpack(args, 1, nargs))
    end, msgh)
end

local raw_print = print

--- Receives any number of arguments and prints their values to `stdout`, converting each argument to a string following the same rules of [tostring](command:extension.lua.doc?["en-us/52/manual.html/pdf-tostring"]). \
--- The function print is not intended for formatted output, but only as a quick way to show a value, for instance for debugging. For complete control over the output, use [string.format](command:extension.lua.doc?["en-us/52/manual.html/pdf-string.format"]) and [io.write](command:extension.lua.doc?["en-us/52/manual.html/pdf-io.write"]).
---
--- [View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-print"])
overloads.print = function(...)
    local args = {...}
    local nargs = select('#', ...)
    local segments = {}
    for i = 1, nargs do
        segments[i] = tostring(args[i])
    end
    return raw_print(table.concat(segments, "\t"))
end

local _TO_ROOT = {
    "print", "xpcall"
}

--- Applies all the overloaded functions in this module to the global `_G` table
overloads.applyGlobal = function()
    for i = 1, #_TO_ROOT do
        local name = _TO_ROOT[i]
        _G[name] = overloads[name]
    end
end

return overloads
