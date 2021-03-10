local HelpWindow = require("Window"):extend("HelpWindow")

------- Images enum --------
-- interface/help_menu/bg.png 622x321
local IMG_BG = "177b6c962b2.png"
-- interface/help_menu/tab.png 100x36
local IMG_TAB_NORMAL = "177dd78b1e8.png"
-- interface/help_menu/tab_active.png 100x36
local IMG_TAB_ACTIVE = "177dd78e605.png"

local TAB_ID = {
    
}

HelpWindow.doCreate = function(self)
    self:addImage(IMG_BG, ":1", 90, 49)
    self:addImage(IMG_TAB_NORMAL, ":1", 120, 78)
    
end

return HelpWindow
