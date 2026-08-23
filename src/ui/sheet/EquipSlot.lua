local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")

local EquipSlot = {}

EquipSlot.defaults = {
  slot = "",
  label = "",
  width = 196,
  height = 42,
}

function EquipSlot.render(props)
  local p = Component.props(EquipSlot.defaults, props)
  return Component.render(Templates.EquipSlot, {
    LABEL = Component.escape(p.label),
    WIDTH = p.width,
    HEIGHT = p.height,
    VALUE = Field.render({
      name = "field_equip_" .. p.slot,
      fontSize = 12,
      width = p.width - 10,
      height = 22,
      placeholder = "—",
    }),
  })
end

return EquipSlot
