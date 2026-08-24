-- Пилюля со значением: модификатор под плиткой характеристики (4A).
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Badge = {}

Badge.defaults = {
  value = "",
  content = "",
  width = "fill",
  height = 16,
  at = "center",
  color = Theme.bgTileDeep,
  borderColor = Theme.gold,
  textColor = Theme.textCream,
  fontSize = 13,
}

function Badge.render(props)
  local p = Component.props(Badge.defaults, props)
  return Component.render(Templates.Badge, {
    VALUE = (tostring(p.value) ~= "" and p.value) or p.content,
    WIDTH = p.width,
    HEIGHT = p.height,
    AT = p.at,
    COLOR = Component.color(p.color),
    BORDER_COLOR = Component.color(p.borderColor),
    TEXT_COLOR = Component.color(p.textColor),
    FONT_SIZE = p.fontSize,
  })
end

return Badge
