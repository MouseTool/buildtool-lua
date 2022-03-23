local componentOps = require("componentOps")
local ImageTextComponents = require("ImageTextComponents")

return {
    DefaultComponent = componentOps.DefaultComponent,
    ImageComponent = ImageTextComponents.ImageComponent,
    TextAreaComponent = ImageTextComponents.TextAreaComponent,
    IComponentOps = componentOps.IComponentOps,
    WindowRegistry = require("windowRegistry").WindowRegistry
}
