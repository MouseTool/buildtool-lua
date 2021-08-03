local tfmcmd = require("commands.tfmcmd")
local perms = require("commands.perms")
local ROLE = require("permissions.btPerms").ROLE

local btRoom = require("modules.btRoom")
local localis = require("localisation.localis")
local string_split = require("util.stringlib").split

-- Silly micro optimization experiment (TODO)
local LOCBUILDER_CHANGED_LANG
do
    local _joins = {
        "<BL>Language set:",
        localis.evaluator:new("language_native")
    }
    LOCBUILDER_CHANGED_LANG = localis.joiner:new(_joins, " ")
end

tfmcmd.registerCommand(tfmcmd.Main {
    name = "langue",
    allowed = true,
    args = {
        tfmcmd.ArgString { lower = true, default = "en" },
    },
    --- @param ctx tfmcmd.CmdContext
    --- @param language? string
    func = function(ctx, language)
        local btp = btRoom.players[ctx.playerName]
        if localis.getLanguageData(language) == nil then
            btp:chatMsg("<R>Warning: there is currently no translation for the chosen language")
        end

        btp:once('languageChanged', function()
            btp:tlbChatMsg(LOCBUILDER_CHANGED_LANG)
        end)

        btp:setLanguage(language)
    end
})

tfmcmd.registerCommand(tfmcmd.Main {
    name = "exec",
    allowed = perms.IS_DEV,
    args = tfmcmd.ALL_WORDS,
    visible = ROLE.DEV,
    --- @param ctx tfmcmd.CmdContext
    func = function(ctx , ...)
        local pn = ctx.playerName
        local argv = {...}
        if argv[1] and tfm.exec[argv[1]]~=nil then
            local args, sz = {}, 0
            local buildstring = {false}
            for i = 2, #argv do
                arg = argv[i]
                if arg=='true' then sz=sz+1 args[sz]=true
                elseif arg=='false' then sz=sz+1 args[sz]=false
                elseif arg=='nil' then sz=sz+1 args[sz]=nil
                elseif tonumber(arg) ~= nil then sz=sz+1 args[sz]=tonumber(arg)
                elseif arg:find('{(.-)}') then
                    local params = {}
                    for _,p in pairs(string_split(arg:match('{(.-)}'), ',')) do
                        local prop = string_split(p, '=')
                        local attr,val=prop[1],prop[2]
                        if val=='true' then val=true
                        elseif val=='false' then val=false
                        elseif val=='nil' then val=nil
                        elseif tonumber(val) ~= nil then val=tonumber(val)
                        end
                        params[attr] = val
                    end
                    sz = sz + 1
                    args[sz] = params
                elseif arg:find('^"(.*)"$') then
                    sz = sz + 1
                    args[sz] = arg:match('^"(.*)"$'):gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&amp;', '&')
                elseif arg:find('^"(.*)') then
                    buildstring[1] = true
                    buildstring[2] = arg:match('^"(.*)'):gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&amp;', '&')
                elseif arg:find('(.*)"$') then
                    buildstring[1] = false
                    sz = sz + 1
                    args[sz] = buildstring[2] .. " " .. arg:match('(.*)"$'):gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&amp;', '&')
                elseif buildstring[1] then
                    buildstring[2] = buildstring[2] .. " " .. arg:gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&amp;', '&')
                else
                    sz = sz + 1
                    args[sz] = arg
                end
            end
            tfm.exec[argv[1]](table.unpack(args, 1, sz))
        else
            local btp = btRoom.players[ctx.playerName]
            btp:chatMsg('no such exec '..(argv[1] and argv[1] or 'nil'))
        end
    end
})