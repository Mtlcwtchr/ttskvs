local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Slot = {}

Slot.defaults = {
  width = 196,
  height = 30,
  color = Theme.bgPanelLight,
  content = "",
}

function Slot.render(props)
  local p = Component.props(Slot.defaults, props)
  return Component.render(Templates.Slot, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    CONTENT = p.content,
  })
end

return Slot
