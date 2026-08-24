local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Slot = {}

Slot.defaults = {
  width = "fill",
  height = "fill",
  color = Theme.bgPanelLight,
  padding = "6 6 4 4",
  gap = 2,
  content = "",
}

function Slot.render(props)
  local p = Component.props(Slot.defaults, props)
  return Component.render(Templates.Slot, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    PADDING = p.padding,
    GAP = p.gap,
    CONTENT = p.content,
  })
end

return Slot
