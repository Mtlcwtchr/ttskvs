local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SheetButton = {}

SheetButton.defaults = {
  id = "",
  label = "",
  color = "buttonNeutral",
  onClick = "",
  width = 160,
  height = 32,
}

function SheetButton.render(props)
  local p = Component.props(SheetButton.defaults, props)
  return Component.render(Templates.SheetButton, {
    ID = p.id,
    LABEL = Component.escape(p.label),
    COLOR = p.color,
    ON_CLICK = p.onClick,
    WIDTH = p.width,
    HEIGHT = p.height,
  })
end

return SheetButton
