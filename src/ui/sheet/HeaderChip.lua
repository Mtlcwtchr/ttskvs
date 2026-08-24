-- Ячейка шапки листа: подпись капсом и значение под ней. Ширина приходит из
-- шапки долями (width="2fr"), поэтому чипы всегда делят строку и не наезжают.
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local HeaderChip = {}

HeaderChip.defaults = {
  label = "",
  name = "",
  width = "fill",
  fontSize = 13,
  color = Theme.transparent,
  valueColor = "textCream",
}

function HeaderChip.render(props)
  local p = Component.props(HeaderChip.defaults, props)
  return Component.render(Templates.HeaderChip, {
    LABEL = Component.escape(p.label),
    WIDTH = p.width,
    COLOR = Component.color(p.color),
    VALUE = Field.render({
      name = p.name,
      fontSize = p.fontSize,
      color = p.valueColor,
      alignment = "MiddleLeft",
      height = "fill",
      placeholder = "—",
    }),
  })
end

return HeaderChip
