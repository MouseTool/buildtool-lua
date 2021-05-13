-- Buildtool global vars
local globals = {}

globals.api = require("@mousetool/mousebase").MbApi()

--- @type table<string, BtPlayer>
globals.players = {}

return globals
