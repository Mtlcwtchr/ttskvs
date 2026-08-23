-- Приписка: модификатор под характеристикой, пояснение под значением.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Note = {}

Note.defaults = {
  text = "",
  content = "",
  alignment = "MiddleCenter",
  fontSize = 11,
  color = Theme.textMuted,
}

function Note.render(props)
  local p = Component.props(Note.defaults, props)
  return Component.render(Templates.TextLine, {
    CONTENT = (p.text ~= "" and p.text) or p.content,
    ALIGNMENT = p.alignment,
    FONT_SIZE = p.fontSize,
    COLOR = Component.color(p.color),
  })
end

return Note
