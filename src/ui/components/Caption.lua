-- Подпись: мелкий золотой капс над значением или заголовок секции.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Caption = {}

Caption.defaults = {
  text = "",
  content = "",
  alignment = "MiddleCenter",
  fontSize = 10,
  color = Theme.labelGold,
}

function Caption.render(props)
  local p = Component.props(Caption.defaults, props)
  return Component.render(Templates.TextLine, {
    CONTENT = (p.text ~= "" and p.text) or p.content,
    ALIGNMENT = p.alignment,
    FONT_SIZE = p.fontSize,
    COLOR = Component.color(p.color),
  })
end

return Caption
