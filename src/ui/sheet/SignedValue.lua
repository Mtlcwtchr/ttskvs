local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SignedValue = {}

SignedValue.defaults = {
  name = "",
  fontSize = 14,
  color = "textBody",
  width = "fill",
  height = "auto",
}

function SignedValue.render(props)
  local p = Component.props(SignedValue.defaults, props)
  return Component.render(Templates.SignedValue, {
    VALUE = Common.signed(Common.value(p.name)),
    FONT_SIZE = p.fontSize,
    COLOR = Component.color(p.color),
    WIDTH = p.width,
    HEIGHT = p.height,
  })
end

return SignedValue
