-- Строка текста. text и content — одно и то же: text удобнее из Lua,
-- content приходит, когда компонент использован тегом (<Label>текст</Label>).
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Label = {}

Label.defaults = {
  text = "",
  content = "",
  alignment = "MiddleCenter",
  fontSize = 12,
  color = Theme.textBody,
}

function Label.render(props)
  local p = Component.props(Label.defaults, props)
  return Component.render(Templates.TextLine, {
    CONTENT = (p.text ~= "" and p.text) or p.content,
    ALIGNMENT = p.alignment,
    FONT_SIZE = p.fontSize,
    COLOR = Component.color(p.color),
  })
end

return Label
