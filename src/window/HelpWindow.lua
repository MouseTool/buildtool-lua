local cookieUi          = require("util.staging.cookie-ui.init")
local btIds             = require("modules.btIds")
local ImageComponent    = cookieUi.ImageComponent
local TextAreaComponent = cookieUi.TextAreaComponent

-- interface/help_menu/bg.png 615x316
local IMG_BG = "1786a49a66a.png"
-- interface/help_menu/tab.png 100x36
local IMG_TAB_NORMAL = "177dd78b1e8.png"
-- interface/help_menu/tab_active.png 100x36
local IMG_TAB_ACTIVE = "177dd78e605.png"

--- Tabs enum
local TAB_ID = {
}

--- @class HelpWindow : cookie-ui.DefaultComponent
local HelpWindow = cookieUi.DefaultComponent:extend("HelpWindow")

function HelpWindow:render()
    self.wrapper:addComponent(
        ImageComponent:new(IMG_BG, nil, 90, 49)
    )
    self.wrapper:addComponent(
        ImageComponent:new(IMG_TAB_NORMAL, nil, 120, 78)
    )
    self.wrapper:addComponent(
        TextAreaComponent:new(
            btIds.getNewTextAreaId(),
            "<font size='2'><a href='event:'>\n<font size='12'><p align='center'>Welcome\n</a>",
            120, 84, 100, 24, 0x222222, 0x000000, .1, true
        )
    )
end

return HelpWindow
