--- Main API initializer for Transformice.
--- @class Api:EventEmitter

local Player = require("entities.Player")

local cached_api

local createApi = function()
    -- Private vars
    local options
    local TfmEvent = require("TfmEvent")
    local players = {}

    local Api = require("EventEmitter"):extend("Api")

    Api._init = function(self)
        Api._parent._init(self)
        self.tfmEvent = TfmEvent

        players = {}

        self:hookTfmEvents()
        self:hookEvents()
    end

    Api.hookTfmEvents = function(self)
        TfmEvent:onCrucial("NewPlayer", function(pn)
            local p = Player:new(pn)
            players[pn] = p

            self:emit("newPlayer", p)
        end)

        TfmEvent:onCrucial("PlayerLeft", function(pn)
            local p = players[pn]
            if not p then return end

            players[pn] = nil
        end)

        TfmEvent:onCrucial("Keyboard", function(pn, k, down, xPos, yPos)
            local p = players[pn]
            if not p then return end

            self:emit("keyboard", p, k, down, xPos, yPos)
            p:emit("keyboard", k, down, xPos, yPos)
        end)
    end

    Api.hookEvents = function(self)
        self:onCrucial("newPlayer", function(player)
            system.bindKeyboard(player.name, 0, true)  -- left
            system.bindKeyboard(player.name, 2, true)  -- right

            player:onCrucial("keyboard", function(key, down)
                if down then
                    if key == 0 then player.isFacingRight = false
                    elseif key == 2 then player.isFacingRight = true
                    end
                end
            end)
        end)
    end

    Api.emitExistingPlayers = function(self)
        for name, rp in pairs(tfm.get.room.playerList) do
            local p = Player:new(name)
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

if cached_api then
    error("Tried to create more than one Api instance! This should only be created in the main program file, and optionally cached for future use.")
    return nil
end

return function()
    cached_api = createApi()
    return cached_api
end
