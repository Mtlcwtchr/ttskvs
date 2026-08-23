-- Поле листа: в просмотре текст, в визарде InputField с тем же id. Значение,
-- тип и режим тег берёт сам — из core/CharacterFields и контекста рендера,
-- поэтому в разметке достаточно <Field name="field_name"/>.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local InputField = require("ui.components.InputField")
local Label = require("ui.components.Label")

local Field = {}

Field.defaults = {
  name = "",
  fontSize = 14,
  color = "textBody",
  alignment = "MiddleCenter",
  width = 180,
  height = 26,
  -- Чем заменить пустое значение в просмотре (в визарде пустое поле — это
  -- нормальное пустое поле, подставлять туда прочерк нельзя).
  placeholder = "",
  onEndEdit = "onCharacterFieldChanged",
}

function Field.render(props)
  local p = Component.props(Field.defaults, props)
  local value = Common.value(p.name)

  if not Common.isWizard() then
    local shown = tostring(value)
    if shown == "" then
      shown = p.placeholder
    end
    return Label.render({
      text = Component.escape(shown),
      fontSize = p.fontSize,
      color = p.color,
      alignment = p.alignment,
    })
  end

  local kind = Common.kind(p.name)
  return InputField.render({
    id = p.name,
    value = Component.escape(value),
    width = p.width,
    height = p.height,
    validation = (kind == "integer") and "Integer" or "None",
    lineType = (kind == "multiline") and "MultiLine" or "SingleLine",
    onEndEdit = p.onEndEdit,
  })
end

return Field
