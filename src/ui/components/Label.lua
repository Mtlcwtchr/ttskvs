-- Строка текста. text и content — одно и то же: text удобнее из Lua,
-- content приходит, когда компонент использован тегом (<Label>текст</Label>).
-- Размер по умолчанию — «вся ширина ячейки, высота по кеглю»: конкретные
-- пиксели считает ui/Layout.lua от того места, куда строку положили.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Label = {}

Label.defaults = {
  text = "",
  content = "",
  alignment = "MiddleCenter",
  fontSize = 12,
  font = "Arial",
  color = Theme.textBody,
  width = "fill",
  height = "auto",
  -- true — длинный текст переносится по словам (описания способностей,
  -- заметки). false — одна строка; влезть ей помогает автоподбор кегля.
  wrap = false,
}

function Label.render(props)
  local p = Component.props(Label.defaults, props)
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

return Label
