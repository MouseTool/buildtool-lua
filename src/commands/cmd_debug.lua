local btcmd = require("commands.btcmd")
local tfmcmd = require("commands.tfmcmd")

local globals = require("bt-vars")
local localis = require("localisation.localis_manager")

-- Silly micro optimization experiment
local LOCBUILDER_CHANGED_LANG
do
    local _joins = {
        "<BL>Language set:",
        localis.evaluator:new("language_native")
    }
    LOCBUILDER_CHANGED_LANG = localis.joiner:new(_joins, " ")
end

btcmd.addCommand(tfmcmd.Main {
    name = "langue",
    allowed = true,
    args = {
        tfmcmd.ArgString { lower = true, default = "en" },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param language? string
    func = function(ctx, language)
        local btp = globals.players[ctx.playerName]
        if localis.getLanguageData(language) == nil then
            btp:chatMsg("<R>Warning: there is currently no translation for the chosen language")
        end

        btp:once('languageChanged', function()
            btp:tlbChatMsg(LOCBUILDER_CHANGED_LANG)
        end)

        btp:setLanguage(language)
    end
})
