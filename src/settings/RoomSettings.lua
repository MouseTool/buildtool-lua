
--- @class RoomSettings:SettingsBase
local RoomSettings = require("settings.SettingsBase"):new()

RoomSettings:addBoolField("autorev", true)

return RoomSettings
