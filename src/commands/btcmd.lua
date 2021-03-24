local tfmcmd = require("commands.tfmcmd")

--- @class btcmd.Options

local btcmd = {}

--- @param cmd tfmcmd.CmdType
--- @param options? btcmd.Options
btcmd.addCommand = function(cmd, options)
    tfmcmd.initCommand(cmd)
end

return btcmd
