-- interface/help_menu/bg.png 615x316
local IMG_BG = "1786a49a66a.png"
-- interface/help_menu/tab.png 100x36
local IMG_TAB_NORMAL = "177dd78b1e8.png"
-- interface/help_menu/tab_active.png 100x36
local IMG_TAB_ACTIVE = "177dd78e605.png"

--- Tabs enum
local TAB_ID = {
}

--- @class HelpWindow:Window
local HelpWindow = require("Window"):extend("HelpWindow")

local WindowEnum = require("btEnums").Window
HelpWindow.TYPE_ID = WindowEnum.HELP

HelpWindow.doRender = function(self)
    self:addImage(IMG_BG, ":1", 90, 49)
    self:addImage(IMG_TAB_NORMAL, ":1", 120, 78)
    self:addTextArea(nil, "<font size='2'><a href='event:'>\n<font size='12'><p align='center'>Welcome\n</a>", 120, 84, 100, 24, 0x222222, 0x000000, .1, true)
end

return HelpWindow
