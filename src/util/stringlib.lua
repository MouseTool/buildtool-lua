--- Stringlib extensions
local string_ext = {}

--- Splits a string with the given delimiter pattern
--- @param str string # The string to split
--- @param delimiter? string # The delimiter pattern (same format used by `string.match`) (default "%s")
--- @return string[]
string_ext.split = function(str, delimiter)
    delimiter = delimiter or '%s'
    local parts, sz = {}, 0
    for part in str:gmatch("[^" .. delimiter .. "]+") do
        sz = sz + 1
        parts[sz] = part
    end
    return parts
end

return string_ext
