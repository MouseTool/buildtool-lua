local DefaultComponent = require("componentOps").DefaultComponent

local exports = {}

-- TODO: Watch LLS [#449](https://github.com/sumneko/lua-language-server/issues/449)
-- Enhancement suggestion: mark function as class constructor #449

--- Implements an image component.
--- @class cookie-ui.ImageComponent : cookie-ui.IComponent
--- @field args any[]
--- @field imageId? integer
--- @field new fun(self: cookie-ui.ImageComponent, imageUid: integer, target?: string, xPosition: number, yPosition: number, xScale?: number, yScale?: number, angle?: number, alpha?: number, xAnchor?: number, yAnchor?: number)
local ImageComponent = DefaultComponent:extend("ImageComponent")
exports.ImageComponent = ImageComponent

function ImageComponent:_init(imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    ImageComponent._parent._init(self)

    target = target or "~0"
    self.args = { imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor }
end

local function _addImage(playerName, imageUid, target, xPosition, yPosition, xScale, yScale, angle, alpha, xAnchor, yAnchor)
    return tfm.exec.addImage(imageUid, target, xPosition, yPosition, playerName, xScale, yScale, angle, alpha, xAnchor, yAnchor)
end

function ImageComponent:render()
    self.imageId = _addImage(self.controller.playerName, table.unpack(self.args, 1, 10))
end

function ImageComponent:destroy()
    tfm.exec.removeImage(self.imageId)
    self.imageId = nil
end

function ImageComponent:restore()
    tfm.exec.removeImage(self.imageId)
    self:render()
end

--- @class cookie-ui.TextAreaComponent : cookie-ui.IComponent
--- @field args any[]
--- @field textAreaId integer
--- @field reactiveText? Reactive<string, nil>
--- @field reactiveUnsub? fun() # The reactive unsubscriber
---
--- @field new fun(self: cookie-ui.TextAreaComponent, textAreaId: number, text: string|Reactive<string, nil>, x?: number, y?: number, width?: number, height?: number, backgroundColor?: number, borderColor?: number, backgroundAlpha?: number, fixedPos?: boolean)
local TextAreaComponent = DefaultComponent:extend("TextAreaComponent")
exports.TextAreaComponent = TextAreaComponent

---@param textAreaId number
---@param text string|Reactive<string, nil>
---@param x? number
---@param y? number
---@param width? number
---@param height? number
---@param backgroundColor? number
---@param borderColor? number
---@param backgroundAlpha? number
---@param fixedPos? boolean
function TextAreaComponent:_init(textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    ImageComponent._parent._init(self)

    --- @type string
    local actualText
    if type(text) == "string" then
        actualText = text
    else
        --- @type Reactive<string, nil>
        local reactiveText = text
        actualText = reactiveText:get()
        self.reactiveText = reactiveText
    end


    self.args = { textAreaId, actualText, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos }
    self.textAreaId = textAreaId
end

local function _addTextArea(playerName, textAreaId, text, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
    ui.addTextArea(textAreaId, text, playerName, x, y, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos)
end

--- @param self cookie-ui.TextAreaComponent
local function _updateTextArea(self, text)
    ui.updateTextArea(self.textAreaId, text, self.controller.playerName)
    self.args[2] = text -- Update text
end

function TextAreaComponent:render()
    -- Start listening to reactive text updates, if any.
    if self.reactiveText then
        self.reactiveUnsub = self.reactiveText:subscribe(function(value)
            self:updateText(value)
        end)
    end
    _addTextArea(self.controller.playerName, table.unpack(self.args, 1, 10))
end

function TextAreaComponent:destroy()
    if (self.reactiveUnsub) then
        self.reactiveUnsub()
    end
    ui.removeTextArea(self.textAreaId, self.controller.playerName)
end

function TextAreaComponent:unfocus()
    -- Remove text area
    self:destroy()
end

function TextAreaComponent:restore()
    self:destroy()
    self:render()
end

--- Updates the text content of the text area.
--- However, it is recommended to use reactive strings with update hooks rather than having to
--- manually call this function.
--- @param text string
function TextAreaComponent:updateText(text)
    if self.controller.state ~= "rendered" then
        print("Warning: Tried to update text area when not rendered?")
        return
    end
    _updateTextArea(self, text)
end

return exports
