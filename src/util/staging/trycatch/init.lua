
--- Synchronously calls a function `try`, If `try` throws, call `catch` synchronously with the
--- @generic T
---@param try fun(): T
---@param catch any
--- @return T
return function(try, catch, ...)
    local status, result = pcall()
end
