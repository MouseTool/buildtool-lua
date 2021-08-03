--- General BT utility functions
local btUtil = {}

--- Returns map code in integer type, nil if invalid
--- @param mapCode string The map code
--- @return integer?
function btUtil.intMapCode(mapCode)
    if type(mapCode) == "string" then
        return tonumber(mapCode:match("@?(%d+)"))
    elseif type(mapCode) == "number" then
        return mapCode
    else
        return nil
    end
end

return btUtil
