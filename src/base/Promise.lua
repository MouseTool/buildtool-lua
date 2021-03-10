-- Promise implementation for TFM, based on https://github.com/rhysbrettbowen/promise_impl/blob/master/promise.js

-- State enums
local STATE_PENDING = 0
local STATE_FULFILLED = 1
local STATE_REJECTED = 2

--- Promise class
--- @class Promise:Class
local Promise = require("Class"):extend("Promise")

Promise._init = function(self, fn)
    self.state = STATE_PENDING
    self.queue = {};
    if fn then
        fn(function(value)
            resolve(self, value)
        end, function(reason)
            self:transition(STATE_REJECTED, reason);
        end)
    end

    return self
end

Promise.transition = function(self, state, value)
    if self.state == state
            or self.state ~= STATE_PENDING
            or (state ~= STATE_FULFILLED and state ~= STATE_REJECTED)
            or value == nil then
        return false
    end
  
    self.state = state
    self.value = value
    run(self)
end

Promise.next = function(self, on_fulfilled, on_rejected)
    local promise = Promise.new()
  
    self.queue[#self.queue + 1] = {
        fulfill = is_callable(on_fulfilled) and on_fulfilled or nil,
        reject = is_callable(on_rejected) and on_rejected or nil,
        promise = promise
    }

    run(self)
  
    return promise
end

Promise.andThen = Promise.next

Promise.catch = function()
end

return Promise
