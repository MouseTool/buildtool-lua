--- Stringlib extensions
local string_ext = {}

--- Splits a string with the given delimiter pattern
--- @param str string # The string to split
--- @param delimiter? string # The delimiter pattern (same format used by `string.match`) (default "%s")
--- @return string[]
string_ext.split = function(str, delimiter)
    local delimiter, a = delimiter or ',', {}
	for part in str:gmatch('[^'..delimiter..']+') do
		a[#a+1] = part
	end
	return a
end

return string_ext
