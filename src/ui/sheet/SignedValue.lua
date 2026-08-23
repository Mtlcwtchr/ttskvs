local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SignedValue = {}

SignedValue.defaults = {
  name = "",
  fontSize = 14,
  color = "textBody",
}

function SignedValue.render(props)
  local p = Component.props(SignedValue.defaults, props)
  return Component.render(Templates.SignedValue, {
    VALUE = Common.signed(Common.value(p.name)),
    FONT_SIZE = p.fontSize,
    COLOR = p.color,
  })
end

return SignedValue
