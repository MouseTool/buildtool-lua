--- Main API initializer for Transformice.
--- @class mousebase.MbApi:mousebase.EventEmitter
--- @field tfmEvent mousebase.MbTfmEvent

local MbPlayer = require("MbPlayer")

--- @return mousebase.MbApi
local createApi = function()
    -- Private vars
    local TfmEvent = require("MbTfmEvent")
    local players = {}

    --- @type mousebase.MbApi
    local Api = require("EventEmitter"):extend("MbApi")

    Api._init = function(self)
        Api._parent._init(self)
        self.tfmEvent = TfmEvent

        players = {}

        self:hookTfmEvents()
    end

    Api.hookTfmEvents = function(self)
        TfmEvent:onCrucial("NewPlayer", function(pn)
            local p = MbPlayer:new(pn)
            players[pn] = p

            self:emit("newPlayer", p)
        end)

        TfmEvent:onCrucial("PlayerLeft", function(pn)
            local p = players[pn]
            if not p then return end

            players[pn] = nil
        end)
    end

    Api.emitExistingPlayers = function(self)
        for name, rp in pairs(tfm.get.room.playerList) do
            local p = MbPlayer:new(name)
            players[name] = p

            self:emit("newPlayer", p)
        end
    end

    Api.start = function(self)
        self:emitExistingPlayers()
        self:emit("ready")
    end

    return Api:new()
end

--- @type mousebase.MbApi
local cached_api

if cached_api then
    error("Tried to create more than one Api instance! This should only be created in the main program file, and optionally cached for future use.")
    return nil
end

return function()
    cached_api = createApi()
    return cached_api
end
