local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local InputField = {}

InputField.defaults = {
  id = "",
  width = 390,
  height = 28,
  value = "",
  -- "None" — дефолтное валидное значение characterValidation у TTS, так что
  -- нечисловым полям ничего передавать не надо.
  validation = "None",
  lineType = "SingleLine",
  onEndEdit = "",
}

function InputField.render(props)
  local p = Component.props(InputField.defaults, props)
  return Component.render(Templates.InputField, {
    ID = p.id,
    WIDTH = p.width,
    HEIGHT = p.height,
    VALUE = p.value,
    VALIDATION = p.validation,
    LINE_TYPE = p.lineType,
    ON_END_EDIT = p.onEndEdit,
  })
end

return InputField
