local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local EquipSlot = {}

EquipSlot.defaults = {
  slot = "",
  label = "",
  width = "fill",
  height = "fill",
  color = Theme.bgTile,
  borderColor = Theme.brass,
}

function EquipSlot.render(props)
  local p = Component.props(EquipSlot.defaults, props)
  return Component.render(Templates.EquipSlot, {
    LABEL = Component.escape(p.label),
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    BORDER_COLOR = Component.color(p.borderColor),
    VALUE = Field.render({
      name = "field_equip_" .. p.slot,
      fontSize = 9,
      color = "textCream",
      alignment = "MiddleCenter",
      height = "fill",
      placeholder = "—",
    }),
  })
end

return EquipSlot
