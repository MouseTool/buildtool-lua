local btIds = require("modules.btIds")
local btEnums = require("btEnums")
local OrderedTable = require("@mousetool/ordered-table")
local WindowUnfocus = btEnums.WindowUnfocus
local WindowOnFocus = btEnums.WindowOnFocus

--- @class Window.LenTable : table
--- @field length integer

--- @class Window.CachedImgs : table
--- @field args any[]
--- @field fakeId integer

--- A basic window.
--- @class Window:EventEmitter
--- @field new fun(self:Window, pn:string, state:table):Window
--- @field public running boolean @Whether or not the window is running (false if not yet rendered/destroyed)
--- @field public focused boolean @Whether or not the window is focused
--- @field protected state table @Persistent state stored by WindowManager before the old instance was destroyed.
--- @field protected images OrderedTable
--- @field protected textAreas OrderedTable
--- @field protected pn string @The player whom the window belongs to
--- @field private _should_refocus_next boolean
--- @field private _cached_textAreas Window.LenTable<integer, any[]>
--- @field private _cached_images Window.LenTable<integer, Window.CachedImgs>
local Window = require("@mousetool/mousebase").EventEmitter:extend("Window")

--- Specifies the behavior of the window when a new window is layered over it.
Window.UNFOCUS_BEHAVIOR = WindowUnfocus.UNFOCUS

--- Defines the behavior of other windows when the window is going to be in ultimate focus.
Window.ON_FOCUS_BEHAVIOR = WindowOnFocus.UNFOCUS_TOP

--- Whether the window should be closed when the Esc key is pressed, when it is the top window.
Window.DESTROY_ON_ESC = true

--- The window's type ID
Window.TYPE_ID = -99

Window._init = function(self, pn, state)
    Window._parent._init(self)
    self.pn = pn

    -- Whether or not the window is running (false if not yet rendered/destroyed)
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

--- Same as `Window.addImage` but accepts a `fakeId` used as a constant image identifier.
--- @see Window.addImage
--- @param self Window
--- @param fakeId integer
local function _addImageFakeId(self, fakeId, imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    tfm.exec.addImage(imageUid, target, xPosition, yPosition, self.pn, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    self.images[fakeId] = {imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor}
    return fakeId
end

--- Adds an image bound to the window.
--- @param imageUid string # the image identifier
--- @param target string # the game element to attach the image to
---     - #mobileId
---     - $playerName (on the mouse sprite)
---     - %playerName (with the mouse sprite removed)
---     - ?backgroundLayerDepth
---     - _groundLayerDepth
---     - !foregroundLayerDepth
---     - &fixedLayerDepthBeforeLuaInterfaces
---     - :fixedLayerDepthBehindLuaInterfaces
--- @param xPosition integer # the horizontal offset of the anchor of the image, relative to the game element (0 being the middle of the game element) (default 0)
--- @param yPosition integer # the vertical offset of the anchor of the image, relative to the game element (0 being the middle of the game element) (default 0)
--- @param xScale number # the horizontal (width) scale of the image (default 1)
--- @param yScale number # the vertical (height) scale of the image (default 1)
--- @param angle number # the rotation angle about anchor of the image, in radians (default 0)
--- @param alpha number # the opacity of the image, from 0 (transparent) to 1 (opaque) (default 1)
--- @param xAnchor number # the horizontal offset (in 0 to 1 scale) of the image's anchor, relative to the image (0 being the left of the image) (default 0)
--- @param yAnchor number # the vertical offset (in 0 to 1 scale) of the image's anchor, relative to the image (0 being the top of the image) (default 0)
--- @return integer # The image ID created. This is different from the ID used by `tfm.exec.addImage` and will persist through refocusings.
Window.addImage = function(self, imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    local imageId = tfm.exec.addImage(imageUid, target, xPosition, yPosition, self.pn, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    self.images[imageId] = {imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor}
    return imageId
end

--- Removes an image bound to the window.
--- @param imageId integer # the image identifier from `Window.addImage`
Window.removeImage = function(self, imageId)
    tfm.exec.removeImage(imageId)
    self.images[imageId] = nil
end

--- Adds a text area bound to the window. If `nil` textAreaId, will use a generated ID.
--- @param textAreaId? integer # the identifier of the text area (if `nil`, generates a random ID)
--- @param text string # the text to display
--- @param x integer # the horizontal coordinate of the top-left corner (default 50)
--- @param y integer # the vertical coordinate of the top-left corner (default 50)
--- @param width integer # the width in pixels of the text area (if 0, it will be ajusted to the text width) (default 0)
--- @param height integer # the height in pixels of the text area (if 0, it will be ajusted to the text height) (default 0)
--- @param backgroundColor integer # the background color of the text area (default 0x324650)
--- @param borderColor integer # the border color of the text area (default 0)
--- @param backgroundAlpha number # the background's opacity, from 0 (transparent) to 1 (opaque) (default 1)
--- @param fixedPos boolean # whether the position is fixed or if it should follow the player's camera on long maps (default false)
--- @return integer # The ID of the text area created
Window.addTextArea = function(self, textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    textAreaId = textAreaId or btIds.getNewTextAreaId()
    ui.addTextArea(textAreaId, text, self.pn, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    self.textAreas[textAreaId] = {textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos}
    return textAreaId
end

--- Updates the content of a text area bound to the window.
--- @param textAreaId integer # the identifier of the text area
--- @param text string # the new text to display
--- @return boolean # Whether the text area was updated
Window.updateTextArea = function(self, textAreaId, text)
    if not self.textAreas[textAreaId] then return false end
    ui.updateTextArea(textAreaId, text, self.pn)
    self.textAreas[textAreaId][2] = text  -- Update text
    return true
end

--- Removes a text area bound to the window.
--- @param textAreaId integer # the identifier of the text area
Window.removeTextArea = function(self, textAreaId)
    ui.removeTextArea(textAreaId, self.pn)
    self.textAreas[textAreaId] = nil
end

--- Removes all text areas and images bound to the window.
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

--- Called on render before `rendered` event is emitted.
--- @virtual
--- @protected
Window.doRender = function(self) end

--- Called on destroy before `destroyed` event is emitted. Default behavior is to call removeAllElements.
--- @virtual
--- @protected
Window.doDestroy = function(self)
    self:removeAllElements()
end

--- Draws the window. Emits `rendered` event.
Window.render = function(self)
    self:doRender()
    self.running = true
    self.focused = true
    self:emit("rendered")
end

--- Destroys the window. Emits `destroyed` event with the window's persistent state.
Window.destroy = function(self)
    self:doDestroy()
    self.destroyed = true
    self.running = nil
    self.focused = nil
    self:emit("destroyed", self.state)
end

--- Called on focus before `focused` event is emitted. Default behavior does nothing.
--- @virtual
Window.doFocus = function(self)
end

--- Called on unfocus before `unfocused` event is emitted. Default behavior is to remove all textareas, and stage them for readdition for the next focus() call.
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

--- Called on unfocus before `unfocused` event is emitted. Default behavior is to remove all textareas AND images, and stage them for readdition for the next focus() call.
--- @virtual
Window.doFullUnfocus = function(self)
    self:doUnfocus()

    local cached_images, len = {}, 0

    -- Cache and remove all images
    for img_id, args in OrderedTable.pairs(self.images) do
        len = len + 1
        cached_images[len] = { fakeId = img_id, args = args }
        ui.removeTextArea(img_id, self.pn)
    end

    self._should_refocus_next = true
    cached_images.length = len
    self._cached_images = cached_images
    self.images = OrderedTable:new()
end

--- Partially focus on the window. Restores all text areas if doUnfocus was not overloaded (default behavior). Subsequently calls doFocus.
--- Will emit the `focused` event when successfully transitioned from unfocused --> focused.
Window.focus = function(self)
    if self.focused then return end  -- already focused
    self:doFocus()

    -- Text area elements staged for readdition by doUnfocus()
    if self._should_refocus_next then
        if self._cached_textAreas then
            for i = 1, self._cached_textAreas.length do
                self:addTextArea(table.unpack(self._cached_textAreas[i], 1, 10))
            end
        end
        if self._cached_images then
            for i = 1, self._cached_images.length do
                local cached_image = self._cached_images[i]
                _addImageFakeId(self, cached_image.fakeId, table.unpack(cached_image.args, 1, 10))
            end
        end
        self._should_refocus_next = nil
        self._cached_textAreas = nil
        self._cached_images = nil
    end

    self.focused = true
    self:emit("focused")
end

--- Unfocus the window. Calls doUnfocus(). Usually this means that the window will still be in view, but partially.
--- Will emit the `unfocused` event when successfully transitioned from focused --> unfocused.
Window.unfocus = function(self)
    self:doUnfocus()
    self.focused = false
    self:emit("unfocused")
end

--- Fully unfocus the window. Calls doFullUnfocus(). Usually this means that the window will be hidden from view (aka minimized).
--- Will emit the `unfocused` event when successfully transitioned from focused --> unfocused.
Window.fullUnfocus = function(self)
    self:doFullUnfocus()
    self.focused = false
    self:emit("unfocused")
end

--- Re-focus the window. Similar to focus(), except that it also readds all images.
--- The difference with focus() is that this is mostly used when the unfocused window needs to be re-rendered over other windows.
--- Will emit both `focused` and `refocused` events when successfully transitioned from unfocused --> focused.
Window.refocus = function(self)
    if self.focused then return end  -- already focused
    self:doFocus()

    -- Text area elements staged for readdition by doUnfocus()
    if self._should_refocus_next then
        if self._cached_textAreas then
            for i = 1, self._cached_textAreas.length do
                self:addTextArea(table.unpack(self._cached_textAreas[i], 1, 10))
            end
        end
        if self._cached_images then
            for i = 1, self._cached_images.length do
                local cached_image = self._cached_images[i]
                _addImageFakeId(self, cached_image.fakeId, table.unpack(cached_image.args, 1, 10))
            end
        end
        self._should_refocus_next = nil
        self._cached_textAreas = nil
        self._cached_images = nil
    else
        -- Readd all existing images.
        local cached_images, ci_len = {}, 0
        for img_id, args in OrderedTable.pairs(self.images) do
            ci_len = ci_len + 1
            cached_images[ci_len] = { fakeId = img_id, args = args }
            tfm.exec.removeImage(img_id)
        end
        self.images = OrderedTable:new()

        for i = 1, ci_len do
            _addImageFakeId(self, cached_images[i].fakeId, table.unpack(cached_images[i].args, 1, 10))
        end

        -- No action needed for text area.
    end

    self.focused = true
    self:emit("focused")
    self:emit("refocused")
end

--- Returns a hyperlinked string that triggers a closing event for the window.
--- @param content string # the content of the link
--- @return string
Window.closifyContent = function(self, content)
    return ("<a href='event:closeWin!%s'>%s</a>"):format(self.TYPE_ID, content)
end

Window.linkifyContent = function(self, content)

end

return Window
