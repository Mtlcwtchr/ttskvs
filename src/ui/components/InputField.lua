local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local InputField = {}

InputField.defaults = {
  id = "",
  -- «Вся ячейка по ширине, высота поля по умолчанию» (Layout.metrics.InputField):
  -- геометрия задаётся тем блоком, в который поле положили, а не здесь.
  width = "fill",
  height = "auto",
  value = "",
  fontSize = 13,
  colors = Theme.inputStates,
  textColor = Theme.inputText,
  -- "None" — дефолтное валидное значение characterValidation у TTS, так что
  -- нечисловым полям ничего передавать не надо.
  validation = "None",
  -- Только SingleLine / MultiLineSubmit / MultiLineNewLine: другого значения у
  -- TTS нет, и невалидное он молча игнорирует.
  lineType = "SingleLine",
  onEndEdit = "",
}

function InputField.render(props)
  local p = Component.props(InputField.defaults, props)
  return Component.render(Templates.InputField, {
    ID = p.id,
    WIDTH = p.width,
    HEIGHT = p.height,
    FONT_SIZE = p.fontSize,
    VALUE = p.value,
    COLORS = Component.color(p.colors),
    TEXT_COLOR = Component.color(p.textColor),
    VALIDATION = p.validation,
    LINE_TYPE = p.lineType,
    ON_END_EDIT = p.onEndEdit,
  })
end

return InputField
