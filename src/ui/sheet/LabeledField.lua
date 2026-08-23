-- Подпись + поле. Обёрнуто в Column с собственной шириной: без обёртки подпись
-- и поле — два соседних элемента, и внутри горизонтального ряда они
-- выстраивались в линию [подпись][поле][подпись][поле] вместо двух пар.
local Column = require("ui.components.Column")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")

local LabeledField = {}

LabeledField.defaults = {
  label = "",
  name = "",
  width = 180,
  height = 24,
  labelFontSize = 10,
  labelColor = "textMuted",
}

function LabeledField.render(props)
  local p = Component.props(LabeledField.defaults, props)
  return Column.render({
    width = p.width,
    -- подпись + зазор + поле
    height = p.height + 18,
    spacing = 2,
    childAlignment = "UpperLeft",
    content = Component.join({
      Label.render({
        text = Component.escape(p.label),
        alignment = "MiddleLeft",
        fontSize = p.labelFontSize,
        color = p.labelColor,
      }),
      Field.render({ name = p.name, width = p.width, height = p.height }),
    }),
  })
end

return LabeledField
