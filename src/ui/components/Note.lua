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
  font = "CormorantGaramond",
  color = Theme.textMuted,
  width = "fill",
  height = "auto",
  -- true — длинный текст переносится по словам (описания способностей,
  -- заметки). false — одна строка; влезть ей помогает автоподбор кегля.
  wrap = false,
}

function Note.render(props)
  local p = Component.props(Note.defaults, props)
  return Component.render(Templates.TextLine, {
    CONTENT = (p.text ~= "" and p.text) or p.content,
    ALIGNMENT = p.alignment,
    FONT_SIZE = p.fontSize,
    FONT = p.font,
    COLOR = Component.color(p.color),
    WIDTH = p.width,
    HEIGHT = p.height,
    OVERFLOW = (p.wrap == true or p.wrap == "true") and "Wrap" or "Overflow",
  })
end

return Note
