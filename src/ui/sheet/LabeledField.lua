-- Подпись + поле. Обёрнуто в Col (разметка LabeledField.xml): без обёртки
-- подпись и поле — два соседних элемента, и внутри Row они выстроились бы в
-- линию [подпись][поле][подпись][поле] вместо двух пар.
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")

local LabeledField = {}

LabeledField.defaults = {
  label = "",
  name = "",
  width = "fill",
  height = "auto",
  fieldHeight = 26,
  fieldColor = "bgPanelLight",
  labelHeight = 12,
  labelFontSize = 10,
  labelColor = "textMuted",
}

function LabeledField.render(props)
  local p = Component.props(LabeledField.defaults, props)
  return Component.render(Templates.LabeledField, {
    LABEL = Component.escape(p.label),
    WIDTH = p.width,
    HEIGHT = p.height,
    LABEL_HEIGHT = p.labelHeight,
    LABEL_FONT_SIZE = p.labelFontSize,
    LABEL_COLOR = Component.color(p.labelColor),
    FIELD_HEIGHT = p.fieldHeight,
    FIELD_COLOR = Component.color(p.fieldColor),
    FIELD = Field.render({ name = p.name, height = "fill" }),
  })
end

return LabeledField
