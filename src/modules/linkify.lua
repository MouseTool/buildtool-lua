local btRoom = require("modules.btRoom")
local api    = btRoom.api

local exports = {}

--- @alias util.linkify.callbackFn fun(textAreaID: integer, playerName: string)
--- @alias util.linkify.idType integer

local isNotInited = true
local current_id = 0
local MAX_INT32 = 2147483647

--- @type table<util.linkify.idType, util.linkify.callbackFn>
local idToLinkfyObj = {}

--- Creates new link ID.
--- @return util.linkify.idType id
--- @return string href # The href link to insert
exports.newLink = function()
    if isNotInited then
        error("Must call linkify.btInit() first.")
    end

    local id = current_id
    current_id = current_id + 1
    if current_id > MAX_INT32 then current_id = 0 end

    return id, "event:linkify?" .. id
end

--- Creates a new link listener.
--- @param id util.linkify.idType
--- @param onClickCb util.linkify.callbackFn
exports.refLink = function(id, onClickCb)
    -- Ref listener
    idToLinkfyObj[id] = onClickCb
end

--- Destroys reference to the link listener.
--- @param id util.linkify.idType
exports.unrefLink = function(id)
    -- Unref listener
    idToLinkfyObj[id] = nil
end

--- Listens to TextAreaCallback event to successfully trigger link callbacks
exports.btInit = function()
    ---@param textAreaID integer
    ---@param playerName string
    ---@param callback string
    api.tfmEvent:on("TextAreaCallback", function(textAreaID, playerName, callback)
        local id = callback:match("^linkify%?(%d+)$")
        if not id then return end

        local cb = idToLinkfyObj[tonumber(id)]
        if not cb then return end
        cb(textAreaID, playerName)
    end)
    isNotInited = nil
end

return exports
