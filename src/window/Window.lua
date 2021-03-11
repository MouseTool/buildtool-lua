local idGen = require("bt-ids")
local OrderedTable = require("utils.OrderedTable")
local WindowOverlayEnums = require("bt-enums").WindowOverlay

-- A basic window.
local Window = require("base.EventEmitter"):extend("Window")

Window.OVERLAY = WindowOverlayEnums.UNFOCUS

Window._init = function(self, pn, state)
    Window._parent._init(self)
    self.pn = pn

    -- Whether or not the window is running (false if not yet created/destroyed)
    self.running = false

    -- Whether or not the window is focused
    self.focused = false

    -- Persistent state stored by WindowManager before the old instance was
    -- destroyed.
    self.state = state or {}

    --- The following are arguments of window elements stored in order of
    --- insertion, used for recreation / refocus.
    -- Ordered dictionary of images added ([imageId] = {args...})
    self.images = OrderedTable:new()
    -- Ordered dictionary of text areas added ([textAreaId] = {args...})
    self.textAreas = OrderedTable:new()

end

--- Adds an image bound to the window.
--- @return Number The image ID created from tfm.exec.addImage
Window.addImage = function(self, imageUid, target, xPosition, yPosition)
    local imageId = tfm.exec.addImage(imageUid, target, xPosition, yPosition, self.pn)
    self.images[imageId] = {imageUid, target, xPosition, yPosition}
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
    self.textAreas[textAreaId] = {textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos}
    return textAreaId
end

--- Updates the content of a text area bound to the window.
--- @treturn bool Whether the text area was updated
Window.updateTextArea = function(self, textAreaId, text)
    if not self.textAreas[textAreaId] then return false end
    ui.updateTextArea(textAreaId, text, self.pn)
    self.textAreas[textAreaId][2] = text  -- Update text
    return true
end

Window.removeTextArea = function(self, textAreaId)
    ui.removeTextArea(textAreaId, self.pn)
    self.textArea[textAreaId] = nil
end

-- Removes all text areas and images bound to the window
Window.removeAllElements = function(self)
    -- Remove all images
    for img_id in OrderedTable.iterkeys(self.images) do
        tfm.exec.removeImage(img_id)
    end
    self.images = OrderedTable:new()

    -- Remove all text areas
    for ta_id in OrderedTable.iterkeys(self.textAreas) do
        ui.removeTextArea(ta_id, self.pn)
    end
    self.textAreas = OrderedTable:new()
end

--- Called on create before `created` event is emitted. 
--- @virtual
Window.doCreate = function(self) end

--- Called on destroy before `destroyed` event is emitted. Default behavior
--- is to call removeAllElements.
--- @virtual
Window.doDestroy = function(self)
    self:removeAllElements()
end

Window.create = function(self)
    self:doCreate()
    self.running = true
    self.focused = true
    self:emit("created")
end

Window.destroy = function(self)
    self:doDestroy()
    self.destroyed = true
    self.running = nil
    self.focused = nil
    self:emit("destroyed", self.state)
end

--- Called on focus before `focused` event is emitted. Default behavior
--- does nothing.
--- @virtual
Window.doFocus = function(self)
end

--- Called on unfocus before `unfocused` event is emitted. Default behavior
--- is to remove all textareas, and stage them for readdition for the next
--- focus() call.
--- @virtual
Window.doUnfocus = function(self)
    local cached_textArea, ctalen = {}, 0

    -- Cache and remove all text areas
    for ta_id, args in OrderedTable.pairs(self.textAreas) do
        ctalen = ctalen + 1
        cached_textArea[ctalen] = args
        ui.removeTextArea(ta_id, self.pn)
    end

    self._should_refocus_next = true
    cached_textArea.length = ctalen
    self._cached_textAreas = cached_textArea
    self.textAreas = OrderedTable:new()
end

--- Focus on the window. Will emit the `focused` event when successfully
--- transitioned from unfocused --> focused.
Window.focus = function(self)
    if self.focused then return end  -- already focused
    self:doFocus()

    -- Text area elements staged for readdition by doUnfocus()
    if self._should_refocus_next then
        for i = 1, self._cached_textAreas.length do
            self:addTextArea(table.unpack(self._cached_textAreas[i], 1, 10))
        end
        self._should_refocus_next = nil
        self._cached_textAreas = nil
    end

    self.focused = true
    self:emit("focused")
end

--- Unfocus the window. Will emit the `unfocused` event when successfully
--- transitioned from focused --> unfocused.
Window.unfocus = function(self)
    if not self.focused then return end  -- already unfocused
    self:doUnfocus()
    self.focused = false
    self:emit("unfocused")
end

return Window
