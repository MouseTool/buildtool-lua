local idGen = require("bt-ids")
local Window = require("base.EventEmitter"):extend("Window")

Window._init = function(self, pn, state)
    Window._parent._init(self)
    self.pn = pn
    self.images = {}
    self.textAreas = {}
    self.state = state or {}
end

--- Adds an image bound to the window.
--- @treturn Number The image ID created
Window.addImage = function(self, imageId, target, xPosition, yPosition)
    local imageId = tfm.exec.addImage(imageId, target, xPosition, yPosition, self.pn)
    self.images[imageId] = true
    return imageId
end

Window.removeImage = function(self, imageId)
    tfm.exec.removeImage(imageId)
    self.images[imageId] = nil
end

--- Adds a text area bound to the window. If nil textAreaId, will use a generated ID.
--- @treturn Number The ID of the text area created
Window.addTextArea = function(self, textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    textAreaId = textAreaId or idGen.getNewTextAreaId()
    ui.addTextArea(textAreaId, text, self.pn, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    self.textAreas[textAreaId] = true
    return textAreaId
end

--- Updates the content of a text area bound to the window.
--- @treturn bool Whether the text area was updated
Window.updateTextArea = function(self, textAreaId, text)
    if not self.textAreas[textAreaId] then return false end
    ui.updateTextArea(textAreaId, text, self.pn)
    return true
end

Window.removeTextArea = function(self, textAreaId)
    ui.removeTextArea(textAreaId, self.pn)
    self.textArea[textAreaId] = nil
end

-- abstract
Window.doCreate = function(self) end
-- abstract
Window.preDestroy = function(self) end

Window.create = function(self)
    self:doCreate()
    self:emit("created")
end

Window.destroy = function(self)
    self:preDestroy()

    for img_id in pairs(self.images) do
        tfm.exec.removeImage(img_id)
    end
    self.images = {}
    for ta_id in pairs(self.textAreas) do
        ui.removeTextArea(ta_id, self.pn)
    end
    self.textAreas = {}

    self:emit("destroyed", self.state)
end

return Window
