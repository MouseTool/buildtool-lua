--- String manipulations against A801 nicknames
--- @class nickname801
local nickname801 = {}

local NUMERIC_TAG = ("#"):byte()
local NUMERIC_PLUS = ("+"):byte()
local NUMERIC_ASTK = ("*"):byte()

--- Attempt to normalize an A801 nickname to the format used by TFM's Lua API `playerName`.
--- No error checking is performed.
--- @param pn string The player's nickname to normalize
--- @return string @The player's normalized name
nickname801.normalName = function(pn)
    if pn:byte(1) == NUMERIC_ASTK then
        return pn
    end

    if pn:byte(1) == NUMERIC_PLUS then
        pn = "+" .. pn:sub(2, 2):upper() .. pn:sub(3):lower()
    else
        pn = pn:sub(1, 1):upper() .. pn:sub(2):lower()
    end

    if pn:byte(-5) ~= NUMERIC_TAG then
        -- Has no tag
        pn = pn .. "#0000"
    end

    return pn
end

--- Attempt to normalize an A801 nickname to be used across the module as an identifier. Focus on performance and consistency.
--- Changes name to lowercase and adds #0000 where omitted.
--- No error checking is performed.
--- @param pn string The player's nickname to normalize
--- @return string @The player's normalized name
nickname801.idName = function(pn)
    if pn:byte(1) ~= NUMERIC_ASTK and pn:byte(-5) ~= NUMERIC_TAG then
        -- Has no tag
        pn = pn .. "#0000"
    end

    return pn:lower()
end

--- Check if the A801 nickname is of souris (guest) format.
--- @param pn string The player's nickname
--- @return boolean
nickname801.isSouris = function(pn)
    return pn:byte(1) == NUMERIC_ASTK
end

return nickname801
