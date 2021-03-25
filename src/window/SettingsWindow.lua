------- Images enum --------
-- interface/settings/settings_bg.png 280x316
local IMG_BG = "1786a49d034.png"

------- Tabs enum --------
local TAB_ID = {
    
}

------- Class defs --------
--- @class SettingsWindow:Window
local SettingsWindow = require("Window"):extend("SettingsWindow")

SettingsWindow.doRender = function(self)
    self:addImage(IMG_BG, ":1", 233, 45)
    self:addTextArea(nil, "<font size='2'><a href='event:'>\n<font size='12'><p align='center'>eee\n</a>", 300, 84, 100, 24, 0x222222, 0x000000, .1, true)
end

return SettingsWindow
