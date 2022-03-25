local cookieUi          = require("util.staging.cookie-ui.init")
local btIds             = require("modules.btIds")
local ImageComponent    = cookieUi.ImageComponent
local TextAreaComponent = cookieUi.TextAreaComponent

-- interface/settings/settings_bg.png 280x316
local IMG_BG = "1786a49d034.png"

--- Tabs enum
local TAB_ID = {
}

--- @class SettingsWindow : cookie-ui.DefaultComponent
local SettingsWindow = cookieUi.DefaultComponent:extend("SettingsWindow")

function SettingsWindow:draw()
    self.wrapper:addComponent(
        ImageComponent:new(IMG_BG, nil, 233, 45)
    )
    self.wrapper:addComponent(
        TextAreaComponent:new(
            btIds.getNewTextAreaId(),
            "<font size='2'><a href='event:'>\n<font size='12'><p align='center'>eee\n</a>",
            300, 84, 100, 24, 0x222222, 0x000000, .1, true
        )
    )
end

return SettingsWindow
