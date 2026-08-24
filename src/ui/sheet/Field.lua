-- Поле листа: в просмотре текст, в визарде InputField с тем же id. Значение,
-- тип и режим тег берёт сам — из core/CharacterFields и контекста рендера,
-- поэтому в разметке достаточно <Field name="field_name"/>.
--
-- Размеров у поля нет намеренно: и текст, и InputField занимают ячейку, в
-- которую их положили (width="fill"). Геометрия — в разметке, у ячейки.
-- Кегль в обоих режимах одинаковый: лейаут не должен прыгать при переключении.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local InputField = require("ui.components.InputField")
local Label = require("ui.components.Label")

local Field = {}

Field.defaults = {
  name = "",
  fontSize = 13,
  color = "textCream",
  alignment = "MiddleLeft",
  -- "auto" — высота строки/поля по умолчанию, "fill" — на всю ячейку.
  height = "auto",
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
      height = p.height,
    })
  end

  local kind = Common.kind(p.name)
  return InputField.render({
    id = p.name,
    value = Component.escape(value),
    height = p.height,
    fontSize = p.fontSize,
    validation = (kind == "integer") and "Integer" or "None",
    lineType = (kind == "multiline") and "MultiLineNewLine" or "SingleLine",
    onEndEdit = p.onEndEdit,
  })
end

return Field
