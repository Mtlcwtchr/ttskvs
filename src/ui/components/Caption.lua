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
  font = "CormorantSC",
  color = Theme.labelGold,
  width = "fill",
  height = "auto",
  -- true — длинный текст переносится по словам (описания способностей,
  -- заметки). false — одна строка; влезть ей помогает автоподбор кегля.
  wrap = false,
}

function Caption.render(props)
  local p = Component.props(Caption.defaults, props)
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

return Caption
