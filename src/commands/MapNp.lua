local tfmcmd = require("commands.tfmcmd")

tfmcmd.initCommands({
    tfmcmd.Main {
        name = "map",
        aliases = {"np"},
        args = {
            tfmcmd.ArgString { lower = true, optional = true },
            tfmcmd.ArgString { lower = true, optional = true },
        },
        func = function( pn , w2 , w3 )
            if w2 == 'history' then
            elseif w2 == 'back' then
            else
                local T = {p4='#4',p8='#8'}
                if w2 then
                    tfm.exec.newGame(T[w2] or w2, w3=='mirror' and true or false)
                else
                    --mapsched.load(settings.maps.leisure[math.random(1,#settings.maps.leisure)]) roundvars.maptype = 'leisure'
                end
            end
        end
    }
})
