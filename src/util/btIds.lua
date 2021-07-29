-- Reserved from 32768 onwards
local curr_ta_id = 32767

local MAX_INT32 = 2147483647

return {
    --- Generate a unique ID from 32768 onwards
    --- @treturn Number
    getNewTextAreaId = function()
        curr_ta_id = curr_ta_id + 1
        if curr_ta_id > MAX_INT32 then curr_ta_id = 32767 end
        return curr_ta_id
    end
}
